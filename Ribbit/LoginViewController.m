//
//  LoginViewController.m
//  Ribbit
//
//  Created by Ben Jakuben on 7/30/13.
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "LoginViewController.h"
#import "UIViewController+ShowErrorAlert.h"

// TJM - Backendless integration
#import "TJMModel.h"

@interface LoginViewController ()

// TJM - Backendless integration
@property (nonatomic, weak) TJMModel *model;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.model = [TJMModel sharedInstance];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
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
        
        [self.model logInWithEmail:email andPassword:password completion:^(BackendlessUser *user) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }error:^(NSString *errorMessage) {
            
            [self showErrorAlertWithTitle:@"Sorry!" andMessage:errorMessage];
        }];
    }
}

- (IBAction)resetPassword {
    NSString *email = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([email length] == 0) {
        [self showErrorAlertWithTitle:@"Oops!" andMessage:@"Enter your email and try again!"];
    }
    else {
        [self.model passwordResetForEmail:email completion:^(void) {
            
            [self showErrorAlertWithTitle:@"Sent!" andMessage:[NSString stringWithFormat:@"An email has been sent to: %@", email]];
            
        } error:^(NSString *errorMessage) {
            
            [self showErrorAlertWithTitle:@"Sorry!" andMessage:errorMessage];
        }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
