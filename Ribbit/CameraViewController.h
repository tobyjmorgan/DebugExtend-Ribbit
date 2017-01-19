//
//  CameraViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@end
