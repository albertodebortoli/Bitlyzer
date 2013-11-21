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
{
    NSInteger numberOfFailures;
    NSInteger numberOfSucceeds;
}

@property (nonatomic, strong) NSMutableDictionary *receivedDataHash;
@property (nonatomic, copy) NSArray *urlsToShorten;
@property (nonatomic, copy) BitlyzerSuccessBlock successBlock;
@property (nonatomic, copy) BitlyzerFailBlock failureBlock;
@property (nonatomic, copy) NSString *APIKey;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSMutableDictionary *shortenedURLHash;
@property (nonatomic, strong) NSMutableDictionary *urlsToShortenHash;

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
        _receivedDataHash = [NSMutableDictionary new];
        _shortenedURLHash = [NSMutableDictionary new];
        _urlsToShortenHash = [NSMutableDictionary new];
        numberOfFailures = numberOfSucceeds = 0;
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
        _receivedDataHash = [NSMutableDictionary new];
        _shortenedURLHash = [NSMutableDictionary new];
        _urlsToShortenHash = [NSMutableDictionary new];
        numberOfFailures = numberOfSucceeds = 0;
    }
    return self;
}

#pragma mark - Bitlyzer API

- (void)shortURL:(NSString *)urlToShorten
{
    self.urlsToShorten = [NSArray arrayWithObject:urlToShorten];
    
    [self _startRequest];
}

- (void)shortURLs:(NSArray *)urlsToShorten
{
    self.urlsToShorten = urlsToShorten.copy;
    
    [self _startRequest];
}

- (void)shortURL:(NSString *)urlToShorten succeeded:(BitlyzerSuccessBlock)success fail:(BitlyzerFailBlock)failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    self.urlsToShorten = [NSArray arrayWithObject:urlToShorten];
    
    [self _startRequest];
}

#pragma mark - Private methods

- (void)_startRequest
{
    for (NSString *aUrlToShorten in self.urlsToShorten) {
        
        NSString *urlString = [NSString stringWithFormat:[kBitlyzerBitlyAPIURL copy], self.username, self.APIKey, aUrlToShorten];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (urlConnection) {
            [self.receivedDataHash setObject:[NSMutableData data] forKey:urlConnection.originalRequest.URL.absoluteString];
            [self.urlsToShortenHash setObject:aUrlToShorten forKey:urlConnection.originalRequest.URL.absoluteString];
        } else {
            if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
                [_delegate bitlyzer:self didFailShorteningURL:aUrlToShorten error:nil];
            }
        }
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableData *receivedData = [self.receivedDataHash objectForKey:connection.originalRequest.URL.absoluteString];
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *receivedData = [self.receivedDataHash objectForKey:connection.originalRequest.URL.absoluteString];
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    numberOfFailures++;
    
    NSString *urlToShorten = [self.urlsToShortenHash objectForKey:connection.originalRequest.URL.absoluteString];
    
    if (self.failureBlock) {
        // use blocks
        self.failureBlock(urlToShorten, error);
    }
    else {
        // use delegation
        if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
            [_delegate bitlyzer:self didFailShorteningURL:urlToShorten error:error];
        }
    }
    
    self.successBlock = nil;
    self.failureBlock = nil;
    
    if (numberOfSucceeds + numberOfFailures == self.urlsToShortenHash.count)
    {
        [self.urlsToShortenHash removeAllObjects];
        [self.receivedDataHash removeAllObjects];
        [self.shortenedURLHash removeAllObjects];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableData *receivedData = [self.receivedDataHash objectForKey:connection.originalRequest.URL.absoluteString];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:nil];
    NSString *urlToShorten = [self.urlsToShortenHash objectForKey:connection.originalRequest.URL.absoluteString];
    
    NSUInteger statusCode = [[JSON valueForKeyPath:@"status_code"] integerValue];
    if (statusCode == 200) {
        numberOfSucceeds++;
        
        NSString *shortenURL = [[JSON valueForKeyPath:@"data"] valueForKey:@"url"];
        
        [self.shortenedURLHash setObject:shortenURL forKey:urlToShorten];
        
        if (self.successBlock) {
            // use blocks
            self.successBlock(urlToShorten, shortenURL);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyzer:didShortURL:toURL:)]) {
                [_delegate bitlyzer:self didShortURL:urlToShorten toURL:shortenURL];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(bitlyzer:didShortURLs:toURLs:)]) {
            
            if (numberOfSucceeds == self.receivedDataHash.allKeys.count) {
                [_delegate bitlyzer:self didShortURLs:self.shortenedURLHash.allKeys toURLs:self.shortenedURLHash.allValues];
            }
            
        }
        
    } else {
        numberOfFailures++;
        
        NSDictionary *errorDictionary = @{@"Bitly Error": [JSON valueForKeyPath:@"status_txt"]};
        NSError *error = [NSError errorWithDomain:BitlyzerErrorDomain code:500 userInfo:errorDictionary];
        
        if (self.failureBlock) {
            // use blocks
            self.failureBlock(urlToShorten, error);
        }
        else {
            // use delegation
            if ([_delegate respondsToSelector:@selector(bitlyzer:didFailShorteningURL:error:)]) {
                [_delegate bitlyzer:self didFailShorteningURL:urlToShorten error:error];
            }
        }
    }
    
    self.successBlock = nil;
    self.failureBlock = nil;
    
    if (numberOfSucceeds + numberOfFailures == self.urlsToShortenHash.count)
    {
        [self.urlsToShortenHash removeAllObjects];
        [self.receivedDataHash removeAllObjects];
        [self.shortenedURLHash removeAllObjects];
    }
}

@end
