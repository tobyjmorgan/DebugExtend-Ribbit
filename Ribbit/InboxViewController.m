//
//  InboxViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "InboxViewController.h"

#import "ImageViewController.h"
#import "InboxCell.h"

// TJM 1/12/2017 Bug Fix #5 - replace deprecated MPMoviePlayer with AVPlayerViewController
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

// TJM - Backendless integration
#import "TJMModel.h"
#import "TJMMessage.h"
#import "BackendlessUser.h"

@interface InboxViewController ()

// TJM - Backendless integration
@property (nonatomic, weak) TJMModel *model;

@property (nonatomic, strong) TJMMessage *selectedMessage;

@end

@implementation InboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.model = [TJMModel sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:TJMModel_Messages_Refreshed object:self.model];
    
    // TJM 1/12/2017 Bug Fix #5 - replace deprecated MPMoviePlayer with AVPlayerViewController
//    self.moviePlayer = [[MPMoviePlayerController alloc] init];
}

// TJM 1/12/2017 Bug Fix #5 - need to reload the view controller each time we return to this screen
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // if the current user is nil - go to the log in screen
    if (self.model.currentUser == nil) {
            
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }

    [self.tableView reloadData];
}

- (void)refresh {
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.model currentUsersMessages].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InboxCell";
    InboxCell *cell = (InboxCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    TJMMessage *message = [[self.model currentUsersMessages] objectAtIndex:indexPath.row];
    cell.senderNameLabel.text = message.sender.name;
    
    NSString *fileType = message.fileType;
    if ([fileType isEqualToString:@"image"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else {
        cell.iconImageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJMMessage *message = [[self.model currentUsersMessages] objectAtIndex:indexPath.row];
    self.selectedMessage = message;
    NSString *fileType = self.selectedMessage.fileType;
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        
        // File type is video
        
        // TJM 1/12/2017 Bug Fix #5 - replace deprecated MPMoviePlayer with AVPlayerViewController
//        self.moviePlayer.contentURL = videoFile.fileURL;
//        [self.moviePlayer prepareToPlay];
//        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
//        // Add it to the view controller so we can see it
//        [self.view addSubview:self.moviePlayer.view];
//        [self.moviePlayer setFullscreen:YES animated:YES];
        
        NSURL *url = [NSURL URLWithString:message.file];
        AVPlayer *player = [AVPlayer playerWithURL:url];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = player;
        [self presentViewController:playerViewController animated:YES completion:nil];
    }
    
    // Delete it!
    [self.model removeMessage:message];
}

- (IBAction)logout:(id)sender {
    
    [self.model logOut];
    
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if ([segue.identifier isEqualToString:@"showImage"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}

@end
