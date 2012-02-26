//
//  Bitlyzer.m
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "Bitlyzer.h"

#define kBitlyAPIURL             @"https://api-ssl.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json"
#warning set here your API login and key here, then remove this line
#define kBitlyAPIUsername        @""
#define kBitlyAPIKey             @""

static SuccessBlock _successBlock;
static FailBlock _failBlock;

@interface Bitlyzer (Private)
- (void)startRequest;
@end

@implementation Bitlyzer

@synthesize delegate = _delegate;

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
    _urlToBitly = [urlToBitly copy];
    
    [self startRequest];
}

- (void)shortURL:(NSString *)urlToBitly succeeded:(SuccessBlock)success fail:(FailBlock)fail
{
    _successBlock = [success copy];
    _failBlock = [fail copy];
    _urlToBitly = [urlToBitly copy];
    
    [self startRequest];
}

#pragma mark - Private methods

- (void)startRequest
{
    NSString *urlString = [NSString stringWithFormat:kBitlyAPIURL, kBitlyAPIUsername, kBitlyAPIKey, _urlToBitly];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (urlConnection) {
        _receivedData = [NSMutableData data];
    } else {
        if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
            [_delegate bitlyReturnedError:nil forURL:_urlToBitly];
        }
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if (_failBlock) {
        // use blocks
        _failBlock(_urlToBitly, error);
    }
    else {
        // use delegation
        if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
            [_delegate bitlyReturnedError:error forURL:_urlToBitly];
        }
    }
    
    _successBlock = nil;
    _failBlock = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:nil];
    
    NSUInteger statusCode = [[JSON valueForKeyPath:@"status_code"] integerValue];
    if (statusCode == 200) {
        NSString *shortenURL = [[JSON valueForKeyPath:@"data"] valueForKey:@"url"];
        
        if (_successBlock) {
            // use blocks
            _successBlock(_urlToBitly, shortenURL);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyReturnedOkForURL:shortenURL:)]) {
                [_delegate bitlyReturnedOkForURL:_urlToBitly shortenURL:shortenURL];
            }
        }
    } else {
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:[JSON valueForKeyPath:@"status_txt"] forKey:@"Bitly Error"];
        NSError __block *error = [NSError errorWithDomain:@"BitlyzerDomain" code:500 userInfo:errorDictionary];
        
        if (_failBlock) {
            // use blocks
            _failBlock(_urlToBitly, error);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyReturnedError:forURL:)]) {
                [_delegate bitlyReturnedError:error forURL:_urlToBitly];
            }
        }
    }
    
    _successBlock = nil;
    _failBlock = nil;
}

@end
