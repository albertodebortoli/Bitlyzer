//
//  Bitlyzer.h
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSString *urlToBitly, NSString *shortenURL);
typedef void (^FailBlock)(NSString *urlToBitly, NSError *error);

@protocol BitlyzerDelegate <NSObject>
@optional
- (void)bitlyReturnedOkForURL:(NSString *)urlString shortenURL:(NSString *)shortenURL;
- (void)bitlyReturnedError:(NSError *)error forURL:(NSString *)urlString;
@end


@interface Bitlyzer : NSObject <NSURLConnectionDelegate>

#pragma mark - instance methods

- (id)initWithDelegate:(id <BitlyzerDelegate>)delegate;
- (void)shortURL:(NSString *)urlToBitly;
- (void)shortURL:(NSString *)urlToBitly succeeded:(SuccessBlock)success fail:(FailBlock)fail;

@property (nonatomic, unsafe_unretained) id <BitlyzerDelegate> delegate;

@end

