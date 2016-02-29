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

@property (strong, nonatomic) NSArray *allCategoriesArray;
@property (strong, nonatomic) NSArray *categoriesOfCurrentUserArray;

@property (strong, nonatomic) NSManagedObjectContext* context;

@end

@protocol ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC;

@end
