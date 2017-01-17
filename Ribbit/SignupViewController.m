//
//  SignupViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "SignupViewController.h"
#import "User.h"
#import "UIViewController+ShowErrorAlert.h"

// TJM - Backendless integration
#import <Backendless/Backendless.h>


@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [super viewWillDisappear:animated];
}
- (IBAction)signup:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        [self showErrorAlertWithTitle:@"Oops!"
                           andMessage:@"Make sure you enter a username, password, and email address!"];
    }
    else {
        
        // TJM - attempt to create the new user in Backendless using email and password
        BackendlessUser *user = [BackendlessUser new];
        user.password = password;
        [user setProperty:@"name" object:username];
        [user setProperty:@"email" object:email];
        
        [backendless.userService registering:user
                                    response:^(BackendlessUser * _Nullable user) {
                                        // TJM - all went well - now dismiss
                                        [backendless.userService setCurrentUser:user];
                                        [backendless.userService setStayLoggedIn:YES];
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                    } error:^(Fault * _Nullable fault) {
                                        // TJM - notify the user what the error was
                                        [self showErrorAlertWithTitle:@"Sorry!" andMessage:fault.message];
                                    }];
    }
}

@end
