//
//  Bitlyzer.m
//  Bitlyzer
//  v1.0.0
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "Bitlyzer.h"

#warning set here your API login and key here, then remove this line
#define kBitlyAPIUsername        @""
#define kBitlyAPIKey             @""

#define kBitlyAPIURL             @"https://api-ssl.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json"

@interface Bitlyzer ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, copy) NSString *urlToBitly;
@property (nonatomic, strong) SuccessBlock successBlock;
@property (nonatomic, strong) FailBlock failBlock;
- (void)startRequest;
@end

@implementation Bitlyzer

#pragma mark - Designated initializer

- (id)initWithDelegate:(id <BitlyzerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Bitlyzer API

- (void)shortURL:(NSString *)urlToBitly
{
    self.urlToBitly = [urlToBitly copy];
    
    [self startRequest];
}

- (void)shortURL:(NSString *)urlToBitly succeeded:(SuccessBlock)success fail:(FailBlock)fail
{
    self.successBlock = success;
    self.failBlock = fail;
    self.urlToBitly = urlToBitly;
    
    [self startRequest];
}

#pragma mark - Private methods

- (void)startRequest
{
    NSString *urlString = [NSString stringWithFormat:kBitlyAPIURL, kBitlyAPIUsername, kBitlyAPIKey, self.urlToBitly];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (urlConnection) {
        self.receivedData = [NSMutableData data];
    } else {
        if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
            [_delegate bitlyReturnedError:nil forURL:self.urlToBitly];
        }
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if (self.failBlock) {
        // use blocks
        self.failBlock(self.urlToBitly, error);
    }
    else {
        // use delegation
        if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
            [_delegate bitlyReturnedError:error forURL:self.urlToBitly];
        }
    }
    
    self.successBlock = nil;
    self.failBlock = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:nil];
    
    NSUInteger statusCode = [[JSON valueForKeyPath:@"status_code"] integerValue];
    if (statusCode == 200) {
        NSString *shortenURL = [[JSON valueForKeyPath:@"data"] valueForKey:@"url"];
        
        if (self.successBlock) {
            // use blocks
            self.successBlock(self.urlToBitly, shortenURL);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyReturnedOkForURL:shortenURL:)]) {
                [_delegate bitlyReturnedOkForURL:self.urlToBitly shortenURL:shortenURL];
            }
        }
    } else {
        NSDictionary *errorDictionary = @{@"Bitly Error": [JSON valueForKeyPath:@"status_txt"]};
        NSError __block *error = [NSError errorWithDomain:@"BitlyzerDomain" code:500 userInfo:errorDictionary];
        
        if (self.failBlock) {
            // use blocks
            self.failBlock(self.urlToBitly, error);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
                [_delegate bitlyReturnedError:error forURL:self.urlToBitly];
            }
        }
    }
    
    self.successBlock = nil;
    self.failBlock = nil;
}

@end
