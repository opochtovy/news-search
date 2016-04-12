//
//  ITBLoginTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginTableViewController.h"

#import "ITBUtils.h"

#import "ITBUser.h"
#import "ITBNews.h"

#import "ITBNewsAPI.h"

#import "ITBSignInTableViewController.h"

NSString * const loginTitle = @"Login:";
NSString * const invalidLogin = @"invalid login parameters";
NSString * const signInSegueId = @"signIn";

@interface ITBLoginTableViewController () <UITextFieldDelegate, ITBSignInTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;

@end

@implementation ITBLoginTableViewController

#pragma mark - Lifecycle

- (void)dealloc {
    
    [_activityIndicator stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(loginTitle, nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:signInSegueId]) {
        
        ITBSignInTableViewController *signInVC = [segue destinationViewController];
        
        signInVC.delegate = self;
        
    }
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

#pragma mark - ITBSignInTableViewControllerDelegate

- (void)signingDidPassSuccessfully:(ITBSignInTableViewController *)vc forUsername:(NSString *)username password:(NSString *)password {
    
    [self authorizeWithUsername:username password:password];
}

#pragma mark - ITBNewsAPI

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password {
    
    __weak ITBLoginTableViewController *weakSelf = self;
    
    [[ITBNewsAPI sharedInstance] authorizeWithUsername:username password:password rememberSwitchValue:self.rememberSwitch.isOn onSuccess:^(ITBUser *user, BOOL isConnected) {
        
        if (!isConnected) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.activityIndicator stopAnimating];
                
                UIAlertController *alert = showAlertWithTitle(noConnectionTitle, noConnectionMessage);
                [weakSelf presentViewController:alert animated:YES completion:nil];
                
            });
            
        } else if (user != nil) {
            
            [weakSelf.delegate loginDidPassSuccessfully:weakSelf];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.usernameField.text = @"";
                weakSelf.passwordField.text = @"";
                
                weakSelf.usernameField.placeholder = NSLocalizedString(invalidLogin, nil);
                weakSelf.passwordField.placeholder = NSLocalizedString(invalidLogin, nil);
                
                [weakSelf.activityIndicator stopAnimating];
                
            });
            
        }
        
    }];
    
}

#pragma mark - IBActions

- (IBAction)actionLogin:(UIButton *)sender {
    
    if ((self.usernameField.text.length > 0) && (self.passwordField.text.length > 0) ) {
        
        [self.activityIndicator startAnimating];
        
        [self authorizeWithUsername:self.usernameField.text password:self.passwordField.text];
    }
}

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
