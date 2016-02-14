//
//  ITBLoginTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginTableViewController.h"

#import "ITBServerManager.h"

#import "ITBUser.h"

NSString *const invalidLogin = @"invalid login parameters";

@interface ITBLoginTableViewController () <UITextFieldDelegate>

@end

@implementation ITBLoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    self.navigationItem.title = @"Login";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [self.activityIndicator stopAnimating];
}

#pragma mark - API

- (void)authorizeUser {
    
    [[ITBServerManager sharedManager]
     authorizeWithUsername:self.usernameField.text
     withPassword:self.passwordField.text
     onSuccess:^(ITBUser *user)
     {

         NSInteger code = [user.code integerValue];

         if (code == 0) {
             
//             NSLog(@"Login was successful!!!");
             
             [self.delegate changeTitleForLoginButton:self];
             
             [self dismissViewControllerAnimated:YES completion:nil];
             
         } else {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 self.usernameField.placeholder = invalidLogin;
                 
                 self.passwordField.placeholder = invalidLogin;
                 
                 [self.activityIndicator stopAnimating];
                 
             });
             
         }
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.usernameField]) {
        
        [self.passwordField becomeFirstResponder];
        
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)actionLogin:(UIButton *)sender {
    
    [self.activityIndicator startAnimating];
    
    [self authorizeUser];
}

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
