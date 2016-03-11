//
//  ITBCategoryPickerViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBCategoryToCreateNewsPickerDelegate;

@interface ITBCategoryPickerViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) id <ITBCategoryToCreateNewsPickerDelegate> delegate;

@end

@protocol ITBCategoryToCreateNewsPickerDelegate

- (void)reloadCategoryFrom:(ITBCategoryPickerViewController *)categoryPickerVC withCategoryTitle:(NSString *)title indexPath:(NSIndexPath *)indexPath;

@optional

- (NSIndexPath *)sendCategoryCheckmarkIndexTo:(ITBCategoryPickerViewController *)categoryVC;

@end
