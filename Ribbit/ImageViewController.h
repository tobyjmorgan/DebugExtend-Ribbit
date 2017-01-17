//
//  ImageViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RibbitMessage;

@interface ImageViewController : UIViewController

@property (nonatomic, strong) RibbitMessage *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
