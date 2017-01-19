//
//  CameraViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIViewController+ShowErrorAlert.h"

#import "FriendsCell.h"

// TJM - Backendless integration
#import "BackendlessUser.h"
#import "TJMModel.h"
#import "TJMMessage.h"
#import "TJMFriends.h"

@interface CameraViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;


@property (nonatomic, strong) NSMutableArray *recipients;

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recipients = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self updateSendButtonState];
    
    // launch image picker
    if (self.image == nil && [self.videoFilePath length] == 0) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        [self.imagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }    
}

- (void)updateSendButtonState {
    
    if (self.recipients.count > 0) {
        
        self.sendButton.enabled = YES;

    } else {
        
        self.sendButton.enabled = NO;
    }
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
    return [[[TJMModel sharedInstance] currentUsersFriends] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendsCell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BackendlessUser *user = [[[TJMModel sharedInstance] currentUsersFriends] objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.name;
    
    if ([self.recipients containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    BackendlessUser *user = [[[TJMModel sharedInstance] currentUsersFriends] objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:user];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user];
    }

    [self updateSendButtonState];

    NSLog(@"%@", self.recipients);
}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // A photo was taken/selected!
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the image!
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    else {
        // A video was taken/selected!
        self.videoFilePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save the video!
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)send:(id)sender {
    if (self.image == nil && [self.videoFilePath length] == 0) {
        [self showErrorAlertWithTitle:@"Try again!" andMessage:@"Please capture or select a photo or video to share!"];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    else {
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark - Helper methods

- (void)uploadMessage {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (self.image != nil) {
        // TJM 1/12/2017 Bug Fix #5 - resize the image to save some space and to better fit this device
        CGFloat aspectRatio = self.image.size.height / self.image.size.width;
        UIImage *newImage = [self resizeImage:self.image toWidth:750.0 andHeight:750.0*aspectRatio];
        
        fileData = UIImagePNGRepresentation(newImage);
        fileName = [NSString stringWithFormat:@"%f.png",[NSDate timeIntervalSinceReferenceDate]];
        fileType = @"image";
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = [NSString stringWithFormat:@"%f.mov",[NSDate timeIntervalSinceReferenceDate]];
        fileType = @"video";
    }
    
    [[TJMModel sharedInstance] sendMessagesForFileNamed:fileName withData:fileData fileType:fileType toRecipients:self.recipients error:^(NSString *errorMessage) {
        
        // TJM - notify the user what the error was
        // TJM 1/12/2017 Bug Fix #5 - slightly better error reporting
        NSString *message = [NSString stringWithFormat:@"%@\nPlease try sending your message again.", errorMessage];
        [self showErrorAlertWithTitle:@"Sorry!" andMessage:message];
    }];
}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
