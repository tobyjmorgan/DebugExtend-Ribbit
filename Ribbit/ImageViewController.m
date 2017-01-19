//
//  ImageViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "ImageViewController.h"

// TJM - Backendless integration
#import "BackendlessUser.h"
#import "TJMMessage.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // TJM - Backendless integration
    // TJM - fetch the file from the server
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    
    NSURL *url = [NSURL URLWithString:self.message.file];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSData *imageData = [NSData dataWithContentsOfURL:location];
                self.imageView.image = [UIImage imageWithData:imageData];
                [self.activityIndicator stopAnimating];
                [self.activityIndicator setHidden:YES];
                
                if ([self respondsToSelector:@selector(timeout)]) {
                    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
                }
                else {
                    NSLog(@"Error: selector missing!");
                }
            });
        }
    }];
    
    [task resume];
    
    NSString *senderName = self.message.sender.name;
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;
}


#pragma mark - Helper methods

- (void)timeout {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
