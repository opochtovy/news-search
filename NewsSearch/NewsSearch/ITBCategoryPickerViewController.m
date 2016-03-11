//
//  ITBCategoryPickerViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategoryPickerViewController.h"

#import "ITBNewsAPI.h"

#import "ITBCategory.h"

@interface ITBCategoryPickerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;

@property (copy, nonatomic) NSArray *allCategoriesArray;
@property (strong, nonatomic) NSIndexPath *checkmarkIndexPath;
@property (copy, nonatomic) NSString *chosenCategoryTitle;

@end

@implementation ITBCategoryPickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Category";
    
    self.checkmarkIndexPath = [self.delegate sendCategoryCheckmarkIndexTo:self];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
        
        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
        
    }
    
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    self.allCategoriesArray = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:@"ITBCategory" withSortDescriptors:@[titleDescriptor] predicate:nil inContext:[ITBNewsAPI sharedInstance].mainManagedObjectContext];
    
    [self.categoriesTableView selectRowAtIndexPath:self.checkmarkIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    ITBCategory *category = [self.allCategoriesArray objectAtIndex:self.checkmarkIndexPath.row];
    self.chosenCategoryTitle = category.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.allCategoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    ITBCategory *category = [self.allCategoriesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = category.title;
    
    if (indexPath.row == self.checkmarkIndexPath.row) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.highlighted = YES;
        cell.selected = YES;
        
        cell.backgroundColor = [UIColor lightGrayColor];
        
    } else {
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.checkmarkIndexPath = indexPath;
    
    ITBCategory *category = [self.allCategoriesArray objectAtIndex:indexPath.row];
    self.chosenCategoryTitle = category.title;
    
    [self.categoriesTableView reloadData];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self.delegate reloadCategoryFrom:self withCategoryTitle:self.chosenCategoryTitle indexPath:indexPath];
        
    }
    
}

#pragma mark - Actions

- (void)actionDone:(UIBarButtonItem *)sender {
    
    [self.delegate reloadCategoryFrom:self withCategoryTitle:self.chosenCategoryTitle indexPath:self.checkmarkIndexPath];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
