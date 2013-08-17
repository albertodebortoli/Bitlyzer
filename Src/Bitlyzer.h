//
//  Bitlyzer.h
//  Bitlyzer
//  v2.0.1
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BitlyzerErrorDomain;

typedef void (^BitlyzerSuccessBlock)(NSString *urlToShorten, NSString *shortenedURL);
typedef void (^BitlyzerFailBlock)(NSString *urlToShorten, NSError *error);

@class Bitlyzer;

/** The delegate of a Bitlyzer object should adopt the BitlyzerDelegate protocol. */

@protocol BitlyzerDelegate <NSObject>

@optional
/**
 Delegate method to inform the delegant object upon shortening success
 
 @param bitlyzer the Bitlyzer object that requested the shortening
 @param urlToShorten the URL that was shortened
 @param shortenedURL the shortened URL
 */
- (void)bitlyzer:(Bitlyzer *)bitlyzer didShortURL:(NSString *)urlToShorten toURL:(NSString *)shortenedURL;

/**
 Delegate method to inform the delegant object upon shortening failure
 
 @param bitlyzer the Bitlyzer object that requested the shortening
 @param urlToShorten the URL that was attempted to shorten
 @param error the error occurred during the shortening
 */
- (void)bitlyzer:(Bitlyzer *)bitlyzer didFailShorteningURL:(NSString *)urlToShorten error:(NSError *)error;
@end

/** Bitlyzer class for URL shortening using Bitly API service, both delegate and block based.
 
 If no delegate object is provided requests must should be performed using shortURL:succeeded:fail: method (that is block based) otherwise shortURL: method should be used (delegate based).
 */

@interface Bitlyzer : NSObject <NSURLConnectionDelegate>

#pragma mark - Instance methods

/**
 Initializes and returns a Bitlyzer object with given credentials. Designated initializer.
 
 @param APIKey the API key to use for requests to Bitly API service
 @param username the username to use for requests to Bitly API service
 */
- (id)initWithAPIKey:(NSString *)APIKey username:(NSString *)username;

/**
 Initializes and returns a Bitlyzer object with given credentials and delegate set
 
 @param APIKey the API key to use for requests to Bitly API service
 @param username the username to use for requests to Bitly API service
 @param delegate the delegate object
 */
- (id)initWithAPIKey:(NSString *)APIKey username:(NSString *)username delegate:(id <BitlyzerDelegate>)delegate;

/**
 Contact the Bitly API service to https://api-ssl.bitly.com/v3/shorten to shorten the given URL
 
 @param urlToShorten the URL to shorten
 */
- (void)shortURL:(NSString *)urlToShorten;

/**
 Contact the Bitly API service to https://api-ssl.bitly.com/v3/shorten to shorten the given URL
 
 @param urlToShorten the URL to shorten
 @param success the success callback block used as callback
 @param failure the failure block used as callback
 */
- (void)shortURL:(NSString *)urlToShorten succeeded:(BitlyzerSuccessBlock)success fail:(BitlyzerFailBlock)failure;

#pragma mark - Properties

/**
 Reference to the delegate object
 */
@property (nonatomic, weak) id <BitlyzerDelegate> delegate;

@end
