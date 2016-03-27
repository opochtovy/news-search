//
//  ITBSignInTableViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBSignInTableViewControllerDelegate;

@interface ITBSignInTableViewController : UITableViewController

@property (weak, nonatomic) id <ITBSignInTableViewControllerDelegate> delegate;

@end


@protocol ITBSignInTableViewControllerDelegate <NSObject>

- (void)signingDidPassSuccessfully:(ITBSignInTableViewController *)vc forUsername:(NSString *)username password:(NSString *)password;

@end
