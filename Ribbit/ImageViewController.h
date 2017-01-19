//
//  ImageViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJMMessage;

@interface ImageViewController : UIViewController

@property (nonatomic, strong) TJMMessage *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
