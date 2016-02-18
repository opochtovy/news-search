//
//  ITBCategoriesViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBCategoriesPickerDelegate;

@interface ITBCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;

@property (strong, nonatomic) NSArray *allCategoriesArray;
@property (strong, nonatomic) NSArray *categoriesOfCurrentUserArray;

@property (weak, nonatomic) id <ITBCategoriesPickerDelegate> delegate;

@end

@protocol ITBCategoriesPickerDelegate

@required
- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC;

@end
