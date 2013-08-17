//
//  Bitlyzer.m
//  Bitlyzer
//  v2.0.1
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "Bitlyzer.h"

static const NSString *kBitlyzerBitlyAPIURL = @"https://api-ssl.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json";

NSString *const BitlyzerErrorDomain = @"BitlyzerErrorDomain";

@interface Bitlyzer ()

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, copy) NSString *urlToShorten;
@property (nonatomic, copy) BitlyzerSuccessBlock successBlock;
@property (nonatomic, copy) BitlyzerFailBlock failureBlock;
@property (nonatomic, copy) NSString *APIKey;
@property (nonatomic, copy) NSString *username;

- (void)_startRequest;

@end

@implementation Bitlyzer

#pragma mark - Initializers

- (id)initWithAPIKey:(NSString *)APIKey username:(NSString *)username
{
    if (APIKey.length == 0 || username.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Bitly API key and username must not be empty"
                                     userInfo:nil];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _APIKey = APIKey;
        _username = username;
    }
    return self;
}

- (id)initWithAPIKey:(NSString *)APIKey username:(NSString *)username delegate:(id <BitlyzerDelegate>)delegate
{
    if (APIKey.length == 0 || username.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Bitly API key and username must not be empty"
                                     userInfo:nil];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _APIKey = APIKey;
        _username = username;
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Bitlyzer API

- (void)shortURL:(NSString *)urlToShorten
{
    self.urlToShorten = [urlToShorten copy];
    
    [self _startRequest];
}

- (void)shortURL:(NSString *)urlToShorten succeeded:(BitlyzerSuccessBlock)success fail:(BitlyzerFailBlock)failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    self.urlToShorten = urlToShorten;
    
    [self _startRequest];
}

#pragma mark - Private methods

- (void)_startRequest
{
    NSString *urlString = [NSString stringWithFormat:[kBitlyzerBitlyAPIURL copy], self.username, self.APIKey, self.urlToShorten];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (urlConnection) {
        self.receivedData = [NSMutableData data];
    } else {
        if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
            [_delegate bitlyzer:self didFailShorteningURL:self.urlToShorten error:nil];
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
    if (self.failureBlock) {
        // use blocks
        self.failureBlock(self.urlToShorten, error);
    }
    else {
        // use delegation
        if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
            [_delegate bitlyzer:self didFailShorteningURL:self.urlToShorten error:error];
        }
    }
    
    self.successBlock = nil;
    self.failureBlock = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:nil];
    
    NSUInteger statusCode = [[JSON valueForKeyPath:@"status_code"] integerValue];
    if (statusCode == 200) {
        NSString *shortenURL = [[JSON valueForKeyPath:@"data"] valueForKey:@"url"];
        
        if (self.successBlock) {
            // use blocks
            self.successBlock(self.urlToShorten, shortenURL);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyzer:didShortURL:toURL:)]) {
                [_delegate bitlyzer:self didShortURL:self.urlToShorten toURL:shortenURL];
            }
        }
    } else {
        NSDictionary *errorDictionary = @{@"Bitly Error": [JSON valueForKeyPath:@"status_txt"]};
        NSError *error = [NSError errorWithDomain:BitlyzerErrorDomain code:500 userInfo:errorDictionary];
        
        if (self.failureBlock) {
            // use blocks
            self.failureBlock(self.urlToShorten, error);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
                [_delegate bitlyzer:self didFailShorteningURL:self.urlToShorten error:error];
            }
        }
    }
    
    self.successBlock = nil;
    self.failureBlock = nil;
}

@end
