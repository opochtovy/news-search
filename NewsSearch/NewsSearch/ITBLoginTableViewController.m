//
//  ITBLoginTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginTableViewController.h"

#import "ITBUser.h"
#import "ITBNews.h"

#import "ITBNewsAPI.h"

NSString *const loginTitle = @"Login:";
NSString *const invalidLogin = @"invalid login parameters";

@interface ITBLoginTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;

@end

@implementation ITBLoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(loginTitle, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [self.activityIndicator stopAnimating];
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

#pragma mark - API

- (void)authorizeUser {
    
    [[ITBNewsAPI sharedInstance] authorizeWithUsername:self.usernameField.text
                                          withPassword:self.passwordField.text
                                             onSuccess:^(ITBUser *user)
    {
        
        if (user != nil) {
            
            [self.delegate loginDidPassSuccessfully:self];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.usernameField.text = @"";
                self.passwordField.text = @"";
                
                self.usernameField.placeholder = NSLocalizedString(invalidLogin, nil);
                self.passwordField.placeholder = NSLocalizedString(invalidLogin, nil);
                
                [self.activityIndicator stopAnimating];
                
            });
            
        }
        
    }];
    
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
