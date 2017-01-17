//
//  LoginViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+ShowErrorAlert.h"

#import <Backendless/Backendless.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
}

- (IBAction)login:(id)sender {
    NSString *email = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([email length] == 0 || [password length] == 0) {
        [self showErrorAlertWithTitle:@"Oops!" andMessage:@"Make sure you enter a username and password!"];
    }
    else {
        
        [backendless.userService login:email password:password
                              response:^(BackendlessUser * _Nullable user) {
                                  // TJM - all went well - now dismiss
                                  [backendless.userService setStayLoggedIn:YES];
                                  [self.navigationController popToRootViewControllerAnimated:YES];
                              } error:^(Fault * _Nullable fault) {
                                  // TJM - notify the user what the error was
                                  [self showErrorAlertWithTitle:@"Sorry!" andMessage:fault.message];
                              }];
        
//        [[FIRAuth auth] signInWithEmail:username password:password completion:^(FIRUser *user, NSError *error) {
//            if (error) {
//                [self showErrorAlertWithTitle:@"Sorry!" andMessage:[error.userInfo objectForKey:NSLocalizedDescriptionKey]];
//            }
//            else {
//                
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            }
//        }];
    }
}

@end
