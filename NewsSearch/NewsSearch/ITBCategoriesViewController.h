//
//  ITBCategoriesViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITBCategoriesPickerDelegate;

@interface ITBCategoriesViewController : UIViewController

@property (weak, nonatomic) id <ITBCategoriesPickerDelegate> delegate;

@end

@protocol ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC withCategoriesOfCurrentUserArray:(NSArray *)categoriesOfCurrentUser sortingNamesArray:(NSArray *)categoryNames sortingType:(NSInteger)index;

@end
