//
//  ITBSignInTableViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBSignInTableViewController.h"

#import "ITBNewsAPI.h"
#import "ITBUtils.h"

NSString *const signinTitle = @"Sign In";
NSString *const waitUnique = @"Please wait...";
NSString *const noUnique = @"Such username already exists...";
NSString *const okUnique = @"Such username is available !";
NSString *const noPassConfirm = @"Password confirmation is not successful...";
NSString *const okPassConfirm = @"Password confirmation is successful !";

@interface ITBSignInTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationField;

@property (weak, nonatomic) IBOutlet UILabel *uniqueUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordConfirmationLabel;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (copy, nonatomic) NSSet *usernamesSet;

@end

@implementation ITBSignInTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernamesSet = [NSSet set];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordConfirmationField.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(signinTitle, nil);
    
    self.usernameField.enabled = NO;
    self.passwordField.enabled = NO;
    self.passwordConfirmationField.enabled = NO;
    self.signInButton.enabled = NO;
    
    [self getUsersFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)registerUser {
    
    __weak ITBSignInTableViewController *weakSelf = self;
    
    [[ITBNewsAPI sharedInstance] registerWithUsername:self.usernameField.text password:self.passwordField.text onSuccess:^(BOOL isConnected) {
        
        if (!isConnected) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.activityIndicator stopAnimating];
                
                UIAlertController *alert = showAlertWithTitle(noConnectionTitle, noConnectionMessage);
                
                [weakSelf presentViewController:alert animated:YES completion:nil];
                
            });
            
        } else {
            
            [weakSelf.delegate signingDidPassSuccessfully:weakSelf forUsername:weakSelf.usernameField.text password:weakSelf.passwordField.text];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            });
            
        }
    }];
    
}

- (void)getUsersFromServer {
    
    __weak ITBSignInTableViewController *weakSelf = self;
    
    [self.activityIndicator startAnimating];
    
    self.uniqueUsernameLabel.text = NSLocalizedString(waitUnique, nil);
    
    [[ITBNewsAPI sharedInstance] getUsersOnSuccess:^(NSSet *usernames, BOOL isConnected) {
        
        if (!isConnected) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.activityIndicator stopAnimating];
                weakSelf.uniqueUsernameLabel.text = noConnectionTitle;
                
                UIAlertController *alert = showAlertWithTitle(noConnectionTitle, noConnectionMessage);
                
                [weakSelf presentViewController:alert animated:YES completion:nil];
                
            });
            
        } else {
            
            weakSelf.usernamesSet = usernames;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.usernameField.enabled = YES;
                weakSelf.passwordField.enabled = YES;
                weakSelf.passwordConfirmationField.enabled = YES;
                weakSelf.signInButton.enabled = YES;
                
                weakSelf.uniqueUsernameLabel.text = nil;
                
                [weakSelf.activityIndicator stopAnimating];
                
            }); 
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    NSMutableString *result = [textField.text mutableCopy];
                               
    [result replaceCharactersInRange:range withString:string];
    
    if ([textField isEqual:self.usernameField]) {
        
        if ([self.usernamesSet containsObject:result]) {
            
            self.uniqueUsernameLabel.text = NSLocalizedString(noUnique, nil);
            self.uniqueUsernameLabel.textColor = [UIColor redColor];
            
        } else {
            
            self.uniqueUsernameLabel.text = NSLocalizedString(okUnique, nil);
            self.uniqueUsernameLabel.textColor = [UIColor blueColor];
            
        }
        
    } else if ([textField isEqual:self.passwordConfirmationField]) {
        
        if ([result isEqual:self.passwordField.text]) {
            
            self.passwordConfirmationLabel.text = NSLocalizedString(okPassConfirm, nil);
            self.passwordConfirmationLabel.textColor = [UIColor blueColor];
            
        } else {
            
            self.passwordConfirmationLabel.text = NSLocalizedString(noPassConfirm, nil);
            self.passwordConfirmationLabel.textColor = [UIColor redColor];
        }
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)actionSignIn:(UIButton *)sender {
    
    if ( (self.usernameField.text.length > 0) && (self.passwordField.text.length > 0) && (![self.usernamesSet containsObject:self.usernameField.text]) && ([self.passwordField.text isEqual:self.passwordConfirmationField.text]) ) {
        
        [self.activityIndicator startAnimating];
        
        [self registerUser];
    }
    
}

@end
