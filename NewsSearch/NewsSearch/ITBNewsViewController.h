//
//  ITBNewsViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITBNewsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;


- (IBAction)actionAddLike:(UIButton *)sender;
- (IBAction)actionSubtractLike:(UIButton *)sender;

@end
