//
//  ITBCustomNewsDetailViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITBNews;

@protocol ITBCustomNewsDetailViewControllerDataSource;

@interface ITBCustomNewsDetailViewController : UIViewController

@property (weak, nonatomic) id <ITBCustomNewsDetailViewControllerDataSource> delegate;

@end

@protocol ITBCustomNewsDetailViewControllerDataSource

@optional

- (ITBNews *)sendNewsItemTo:(ITBCustomNewsDetailViewController *)newsDetailVC;

@end
