//
//  ITBLoginTableViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBLoginTableViewControllerDelegate;

@interface ITBLoginTableViewController : UITableViewController

@property (weak, nonatomic) id <ITBLoginTableViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;


- (IBAction)actionLogin:(UIButton *)sender;

- (IBAction)actionCancel:(UIBarButtonItem *)sender;


@end


@protocol ITBLoginTableViewControllerDelegate //<NSObject>

@optional

- (void)changeTitleForLoginButton:(ITBLoginTableViewController *)vc;

- (void) loginDidPassSuccessful:(ITBLoginTableViewController *)vc;
//- (void)saveSettingsAfterLogin:(ITBLoginTableViewController *)vc;

@end
