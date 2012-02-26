//
//  ViewController.m
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [textField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)shortUrlAction:(id)sender
{
    Bitlyzer *bitlyzer = [[Bitlyzer alloc] initWithDelegate:self];
    [bitlyzer shortURL:textField.text];
}

- (IBAction)shortUrlUsingBlocksAction:(id)sender
{
    Bitlyzer *bitlyzer = [[Bitlyzer alloc] init];
    [bitlyzer shortURL:textField.text
      succeeded:^(NSString *urlToBitly, NSString *shortenURL) {
        [self bitlyReturnedOkForURL:urlToBitly shortenURL:shortenURL];
    } fail:^(NSString *urlToBitly, NSError *error) {
        [self bitlyReturnedError:error forURL:urlToBitly];
    }];
}

#pragma mark - IWLBitlyzerDelegate

- (void)bitlyReturnedOkForURL:(NSString *)urlString shortenURL:(NSString *)shortenURL 
{
    NSLog(@"URL %@ shorten into %@", urlString, shortenURL);
    shortenURLLabel.text = shortenURL;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ok"
                                                    message:[NSString stringWithFormat:@"URL %@ shorten into %@", urlString, shortenURL]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

- (void)bitlyReturnedError:(NSError *)error forURL:(NSString *)urlString
{
    NSLog(@"%@", [error description]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"Can't short URL %@", urlString]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

@end
