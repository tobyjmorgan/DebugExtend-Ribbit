//
//  InboxViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class RibbitMessage;

@interface InboxViewController : UITableViewController

@property (nonatomic, strong) RibbitMessage *selectedMessage;
// TJM 1/12/2017 Bug Fix #5 - replace deprecated MPMoviePlayer with AVPlayerViewController
//@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)logout:(id)sender;

@end
