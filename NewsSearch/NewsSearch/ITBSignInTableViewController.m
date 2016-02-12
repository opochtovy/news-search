//
//  ITBSignInTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBSignInTableViewController.h"

#import "ITBServerManager.h"

#import "ITBUser.h"

NSString *const signinTitle = @"Sign In";
NSString *const waitUnique = @"Please wait...";
NSString *const noUnique = @"Such username already exists...";
NSString *const okUnique = @"Such username is available !";
NSString *const noPassConfirm = @"Password confirmation is not successful...";
NSString *const okPassConfirm = @"Password confirmation is successful !";

@interface ITBSignInTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableSet* usernamesSet;

@end

@implementation ITBSignInTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernamesSet = [NSMutableSet set];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordConfirmationField.delegate = self;
    
    self.navigationItem.title = signinTitle;
    
    [self getUsersFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
//    [self.activityIndicator stopAnimating];
}

#pragma mark - API

- (void)registerUser {
    
    [[ITBServerManager sharedManager]
     registerWithUsername:self.usernameField.text
     withPassword:self.passwordField.text
     onSuccess:^(ITBUser *user)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self.activityIndicator stopAnimating];
             
             [self dismissViewControllerAnimated:YES completion:nil];
             
         });
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
    
}

- (void)getUsersFromServer {
    
    self.usernameField.enabled = NO;
    self.passwordField.enabled = NO;
    self.passwordConfirmationField.enabled = NO;
    
    [self.activityIndicator startAnimating];
    
    self.uniqueUsernameLabel.text = waitUnique;
    
    [[ITBServerManager sharedManager]
     getUsersOnSuccess:^(NSArray *users) {
         
         for (ITBUser* userItem in users) {
             
             [self.usernamesSet addObject:userItem.username];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             self.usernameField.enabled = YES;
             self.passwordField.enabled = YES;
             self.passwordConfirmationField.enabled = YES;
             
             self.uniqueUsernameLabel.text = nil;
             
             [self.activityIndicator stopAnimating];
             
//             NSLog(@"%@", self.usernamesSet);
             
         });
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameField]) {
        
        [self.passwordField becomeFirstResponder];
        
    } else if ([textField isEqual:self.passwordField]) {
        
        [self.passwordConfirmationField becomeFirstResponder];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString* result = [textField.text mutableCopy];
                               
    [result replaceCharactersInRange:range withString:string];
    
    if ([textField isEqual:self.usernameField]) {
        
        if ([self.usernamesSet containsObject:result]) {
            
            self.uniqueUsernameLabel.text = noUnique;
            self.uniqueUsernameLabel.textColor = [UIColor redColor];
            
        } else {
            
            self.uniqueUsernameLabel.text = okUnique;
            self.uniqueUsernameLabel.textColor = [UIColor greenColor];
            
        }
        
    } else if ([textField isEqual:self.passwordConfirmationField]) {
        
        if ([result isEqual:self.passwordField.text]) {
            
            self.passwordConfirmationLabel.text = okPassConfirm;
            self.passwordConfirmationLabel.textColor = [UIColor greenColor];
            
        } else {
            
            self.passwordConfirmationLabel.text = noPassConfirm;
            self.passwordConfirmationLabel.textColor = [UIColor redColor];
        }
    }
    
    return YES;
}

- (IBAction)actionSignIn:(UIButton *)sender {
    
    if ( (![self.usernamesSet containsObject:self.usernameField.text]) && ([self.passwordField.text isEqual:self.passwordConfirmationField.text]) ) {
        
        [self.activityIndicator startAnimating];
        
        [self registerUser];
    }
    
}

@end
