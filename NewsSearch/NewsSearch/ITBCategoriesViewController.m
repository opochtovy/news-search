//
//  ITBCategoriesViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategoriesViewController.h"

#import "ITBNewsAPI.h"

#import "ITBUser.h"
#import "ITBCategory.h"

NSString *const categoriesTitle = @"Categories";
NSString *const allCatsCell = @"All categories";

@interface ITBCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;

@property (strong, nonatomic) NSMutableArray *checkBoxes;
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
    
    self.checkBoxes = [[NSMutableArray alloc] init];
    
    for (ITBCategory* category in self.allCategoriesArray) {
        
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
        
        ITBCategory* category = [self.allCategoriesArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = category.title;
        
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
            cell.backgroundColor = [UIColor lightGrayColor];
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section != 0) {
        
        if (self.isAllChecked) {
            
            self.isAllChecked = !self.isAllChecked;
            
            NSIndexPath *allIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.categoriesTableView beginUpdates];
            [self.categoriesTableView reloadRowsAtIndexPaths:@[allIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.categoriesTableView endUpdates];
        }
        
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
    
    NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
    
    for (ITBCategory* category in self.allCategoriesArray) {
        
        NSInteger i = [self.allCategoriesArray indexOfObject:category];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        
        if (hasCheckBox) {
            
            [categoriesOfCurrentUser addObject:category];
        }
    }
    
    NSLog(@"number of selected categories = %li", (long)[categoriesOfCurrentUser count]);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
        
        for (ITBCategory* category in self.allCategoriesArray) {
            
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

    NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
    
    for (ITBCategory* category in self.allCategoriesArray) {
        
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
