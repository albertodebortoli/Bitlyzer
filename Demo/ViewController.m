//
//  ViewController.m
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ViewController.h"

#define kBitlyAPIUsername        @"whispit"
#define kBitlyAPIKey             @"R_be8d9f9c34e5f37e8a40b77db3217e80"

@interface ViewController ()

- (void)_showAlertForMissingCredentials;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [topTextField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)shortUrlAction:(id)sender
{
    @try {
        Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithAPIKey:kBitlyAPIKey username:kBitlyAPIUsername delegate:self];
        
        NSMutableArray *linkArray = [NSMutableArray new];
        
        if (topTextField.text.length > 7)
            [linkArray addObject:topTextField.text];
        if (bottomTextField.text.length > 7)
            [linkArray addObject:bottomTextField.text];
        
        [bitlyzer shortURLs:linkArray];

    }
    @catch (NSException *exception) {
        [self _showAlertForMissingCredentials];
    }
}

- (IBAction)shortUrlUsingBlocksAction:(id)sender
{
    @try {
        Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithAPIKey:kBitlyAPIKey username:kBitlyAPIUsername];
        [bitlyzer shortURL:topTextField.text
                 succeeded:^(NSString *urlToShorten, NSString *shortenedURL) {
                     [self bitlyzer:bitlyzer didShortURL:urlToShorten toURL:shortenedURL];
                 } fail:^(NSString *urlToShorten, NSError *error) {
                     [self bitlyzer:bitlyzer didFailShorteningURL:urlToShorten error:error];
                 }];
    }
    @catch (NSException *exception) {
        [self _showAlertForMissingCredentials];
    }
    
}

#pragma mark - IWLBitlyzerDelegate

- (void)bitlyzer:(Bitlyzer *)bitlyzer didShortURL:(NSString *)urlToShorten toURL:(NSString *)shortenedURL
{
    if ([urlToShorten isEqualToString:topTextField.text]) {
        topShortenURLLabel.text = shortenedURL;
    }
    if ([urlToShorten isEqualToString:bottomTextField.text]) {
        bottomShortenURLLabel.text = shortenedURL;
    }
}

- (void)bitlyzer:(Bitlyzer *)bitlyzer didShortURLs:(NSArray *)urlsToShorten toURLs:(NSArray *)shortenedURLs
{
    
}

- (void)bitlyzer:(Bitlyzer *)bitlyzer didFailShorteningURL:(NSString *)urlToShorten error:(NSError *)error
{
    NSLog(@"%@", [error description]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"Can't short URL %@", urlToShorten]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

#pragma mark - Private

- (void)_showAlertForMissingCredentials
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing credentials"
                                                    message:@"Set your Bitly username and API key in ViewController.m"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
