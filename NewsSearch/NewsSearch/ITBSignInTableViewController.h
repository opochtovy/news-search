//
//  ITBSignInTableViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITBSignInTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationField;

@property (weak, nonatomic) IBOutlet UILabel *uniqueUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordConfirmationLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)actionSignIn:(UIButton *)sender;

@end
