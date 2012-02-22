//
//  Bitlyzer.m
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "Bitlyzer.h"
#import "AFJSONRequestOperation.h"

#define kBitlyAPIURL             @"https://api-ssl.bitly.com/v3/shorten?login=%@&apiKey=%@&longUrl=%@&format=json"
#warning set your API keys here and remove this line
#define kBitlyAPIUsername        @""
#define kBitlyAPIKey             @""

@implementation Bitlyzer

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id <BitlyzerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

// Short a URL using Bitly API
- (void)shortURL:(NSString *)urlToBitly
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:kBitlyAPIURL, kBitlyAPIUsername, kBitlyAPIKey, urlToBitly];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSUInteger statusCode = [[JSON valueForKeyPath:@"status_code"] integerValue];
        if (statusCode != 200) {
            if ([_delegate respondsToSelector:@selector(bitlyReturnedErrorForURL:)]) {
                [_delegate bitlyReturnedErrorForURL:urlToBitly];
            }
        } else {
            NSString *shortenURL = [[JSON valueForKeyPath:@"data"] valueForKey:@"url"];
            if ([_delegate respondsToSelector:@selector(bitlyReturnedOkForURL:shortenURL:)]) {
                [_delegate bitlyReturnedOkForURL:urlToBitly shortenURL:shortenURL];
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ([_delegate respondsToSelector:@selector(bitlyUnreachableForURL:)]) {
            [_delegate bitlyUnreachableForURL:urlToBitly];
        }
    }];
    
    [operationQueue addOperation:operation];
}

@end
