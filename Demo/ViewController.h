//
//  ViewController.h
//  Bitlyzer
//
//  Created by Alberto De Bortoli on 22/02/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bitlyzer.h"

@interface ViewController : UIViewController <BitlyzerDelegate> {
    
    IBOutlet UILabel *shortenURLLabel;
    IBOutlet UITextField *textField;
}

- (IBAction)shortUrlAction:(id)sender;
- (IBAction)shortUrlUsingBlocksAction:(id)sender;

@end
