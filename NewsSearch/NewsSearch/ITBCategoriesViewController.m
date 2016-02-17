//
//  ITBCategoriesViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategoriesViewController.h"

NSString *const categoriesTitle = @"Categories";
NSString *const allCatsCell = @"All categories";

@interface ITBCategoriesViewController ()

@property (strong, nonatomic) NSMutableArray *checkBoxes; // количество элементов этого нового массива такое же как в self.allCategoriesArray + 1 (из-за поля All)
@property (assign, nonatomic) BOOL isAllChecked;

@end

@implementation ITBCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = categoriesTitle;
    self.title = NSLocalizedString(categoriesTitle, nil);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
        
        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
        
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    
    [self.categoriesTableView selectRowAtIndexPath:self.checkmarkIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    self.checkBoxes = [[NSMutableArray alloc] init];
    
    for (NSString* category in self.allCategoriesArray) {
        
        BOOL checkBox = NO;
        
        if ([self.categoriesOfCurrentUserArray containsObject:category]) {
            checkBox = YES;
        }
        
        [self.checkBoxes addObject:[NSNumber numberWithBool:checkBox]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section != 0) {
        
        return [self.allCategoriesArray count];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    static NSString* allIdentifier = @"All";
    
    UITableViewCell *cell;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section != 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = [self.allCategoriesArray objectAtIndex:indexPath.row];
        
        NSNumber *number = [self.checkBoxes objectAtIndex:indexPath.row];
        BOOL hasCheckBox = [number boolValue];
        
        if (hasCheckBox) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        
    } else {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:allIdentifier];
        
//        cell.textLabel.text = allCatsCell;
        cell.textLabel.text = NSLocalizedString(allCatsCell, nil);
        
        if (self.isAllChecked) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            cell.highlighted = YES;
//            cell.selected = YES;
            cell.backgroundColor = [UIColor lightGrayColor];
            
        } else {
            
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section != 0) {
        
        NSNumber *number = [self.checkBoxes objectAtIndex:indexPath.row];
        BOOL hasCheckBox = [number boolValue];
        
        hasCheckBox = !hasCheckBox;
        
        [self.checkBoxes replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:hasCheckBox]];
        
//    [self.categoriesTableView reloadData];
        
        [self.categoriesTableView beginUpdates];
        [self.categoriesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.categoriesTableView endUpdates];
        
    } else {
        
        for (int i = 0; i < [self.checkBoxes count]; i++) {
            
            [self.checkBoxes replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!self.isAllChecked]];
        }
        
        self.isAllChecked = !self.isAllChecked;
        
        [self.categoriesTableView reloadData];
        
    }
    
    // Нюанс popover - поскольку я убрал из popover кнопки в navigationBar то надо обновлять данные при каждом select
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        // сначала НАДО ОБЯЗАТЕЛЬНО обновить массив categoriesOfCurrentUser
        NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
        
        for (NSString* category in self.allCategoriesArray) {
            
            NSInteger i = [self.allCategoriesArray indexOfObject:category];
            NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
            BOOL hasCheckBox = [numberWithBool boolValue];
            
            if (hasCheckBox) {
                
                [categoriesOfCurrentUser addObject:category];
            }
        }
        
        self.categoriesOfCurrentUserArray = [categoriesOfCurrentUser copy];
        
        [self.delegate reloadCategoriesFrom:self];
        
    }
    
}

#pragma mark - Actions
- (void)actionDone:(UIBarButtonItem *)sender {
    
    // сначала НАДО ОБЯЗАТЕЛЬНО обновить массив categoriesOfCurrentUser
    NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
    
    for (NSString* category in self.allCategoriesArray) {
        
        NSInteger i = [self.allCategoriesArray indexOfObject:category];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        
        if (hasCheckBox) {
            
            [categoriesOfCurrentUser addObject:category];
        }
    }
    
    self.categoriesOfCurrentUserArray = [categoriesOfCurrentUser copy];
    
    [self.delegate reloadCategoriesFrom:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
