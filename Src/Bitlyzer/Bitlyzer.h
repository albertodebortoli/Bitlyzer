//
//  Bitlyzer.h
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BitlyzerDelegate <NSObject>
@optional
- (void)bitlyReturnedOkForURL:(NSString *)urlString shortenURL:(NSString *)shortenURL;
- (void)bitlyReturnedErrorForURL:(NSString *)urlString;
- (void)bitlyUnreachableForURL:(NSString *)urlString;
@end


@interface Bitlyzer : NSObject {
    id <BitlyzerDelegate>  __unsafe_unretained _delegate;
}

#pragma mark - instance methods

- (id)initWithDelegate:(id <BitlyzerDelegate>)delegate;
- (void)shortURL:(NSString *)urlToBitly;

@property (nonatomic, unsafe_unretained) id <BitlyzerDelegate> delegate;

@end

