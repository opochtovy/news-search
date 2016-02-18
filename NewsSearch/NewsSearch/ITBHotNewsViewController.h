//
//  ITBHotNewsViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ITBHotNewsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesPickerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender;
@end
