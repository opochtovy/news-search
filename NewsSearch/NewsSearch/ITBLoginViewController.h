//
//  ITBLoginViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBLoginViewControllerDelegate;

@interface ITBLoginViewController : UIViewController

@property (weak, nonatomic) id <ITBLoginViewControllerDelegate> delegate;

@end

@protocol ITBLoginViewControllerDelegate //<NSObject>

@optional

- (void)changeTitleForLoginButton:(ITBLoginViewController *)vc;

@end
