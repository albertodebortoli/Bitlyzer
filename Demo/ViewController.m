//
//  ViewController.m
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ViewController.h"

#define kBitlyAPIUsername        @""
#define kBitlyAPIKey             @""

@interface ViewController ()

- (void)_showAlertForMissingCredentials;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [textField becomeFirstResponder];
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
        [bitlyzer shortURL:textField.text];
    }
    @catch (NSException *exception) {
        [self _showAlertForMissingCredentials];
    }
}

- (IBAction)shortUrlUsingBlocksAction:(id)sender
{
    @try {
        Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithAPIKey:kBitlyAPIKey username:kBitlyAPIUsername];
        [bitlyzer shortURL:textField.text
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
    NSLog(@"URL %@ shorten into %@", urlToShorten, shortenedURL);
    shortenURLLabel.text = shortenedURL;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ok"
                                                    message:[NSString stringWithFormat:@"URL %@ shorten into %@", urlToShorten, shortenedURL]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
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
