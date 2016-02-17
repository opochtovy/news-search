//
//  ITBLoginTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginTableViewController.h"

#import "ITBServerManager.h"
#import "ITBDataManager.h"

#import "ITBUser.h"

NSString *const loginTitle = @"Login:";
NSString *const invalidLogin = @"invalid login parameters";

@interface ITBLoginTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) ITBServerManager* serverManager;
@property (strong, nonatomic) ITBDataManager* dataManager;

@end

@implementation ITBLoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
//    self.navigationItem.title = loginTitle;
    self.navigationItem.title = NSLocalizedString(loginTitle, nil);
    
    self.serverManager = [ITBServerManager sharedManager];
    self.dataManager = [ITBDataManager sharedManager];
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
    
//    ITBServerManager* manager = [ITBServerManager sharedManager];
    
    [self.serverManager
     authorizeWithUsername:self.usernameField.text
     withPassword:self.passwordField.text
     onSuccess:^(ITBUser *user)
     {

         NSInteger code = [user.code integerValue];

         if (code == 0) {
             
//             NSLog(@"Login was successful!!!");
             
             self.serverManager.currentUser = user;
             [self.dataManager fetchCurrentUserForObjectId:user.objectId];
             
             if (self.rememberSwitch.enabled) {
                 
                 NSLog(@"rememberSwitch is ONN!");
                 
//                 [self.delegate saveSettingsAfterLogin:self];
                 [self.serverManager saveSettings];
                 
                 // надо сделать fetchRequest чтобы получить currentUserCD
//                 [[ITBDataManager sharedManager] fetchCurrentUser];
                 
             }
             
//             [self.delegate changeTitleForLoginButton:self];
             [self.delegate loginDidPassSuccessful:self];
             
             [self dismissViewControllerAnimated:YES completion:nil];
             
         } else {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
//                 self.usernameField.placeholder = invalidLogin;
                 self.usernameField.placeholder = NSLocalizedString(invalidLogin, nil);
                 
//                 self.passwordField.placeholder = invalidLogin;
                 self.passwordField.placeholder = NSLocalizedString(invalidLogin, nil);
                 
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
