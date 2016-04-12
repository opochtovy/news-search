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

@end


@protocol ITBLoginTableViewControllerDelegate <NSObject>

- (void)loginDidPassSuccessfully:(ITBLoginTableViewController *)vc;

@optional

- (NSArray *)sendObjectIDsArrayTo:(ITBLoginTableViewController *)vc;

@end
