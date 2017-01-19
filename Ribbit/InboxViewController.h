//
//  InboxViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJMMessage;

@interface InboxViewController : UITableViewController

// TJM 1/12/2017 Bug Fix #5 - replace deprecated MPMoviePlayer with AVPlayerViewController
//@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)logout:(id)sender;

@end
