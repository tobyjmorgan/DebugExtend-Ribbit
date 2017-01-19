//
//  SignupViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "SignupViewController.h"

#import "UIViewController+ShowErrorAlert.h"

// TJM - Backendless integration
#import "TJMModel.h"

@interface SignupViewController ()

// TJM - Backendless integration
@property (nonatomic, weak) TJMModel *model;

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.model = [TJMModel sharedInstance];
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
        [self.model signupNewUserWithName:username email:email andPassword:password completion:^(BackendlessUser *user) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        error:^(NSString *errorMessage) {
        
            // TJM - notify the user what the error was
            [self showErrorAlertWithTitle:@"Sorry!" andMessage:errorMessage];
        }];
    }
}

@end
