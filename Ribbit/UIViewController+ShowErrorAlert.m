//
//  UIViewController+ShowErrorAlert.m
//  Ribbit
//
//  Created by redBred LLC on 1/4/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

#import "UIViewController+ShowErrorAlert.h"

@implementation UIViewController (ShowErrorAlert)

- (void)showErrorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
