//
//  ITBCategoriesViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 11.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategoriesViewController.h"

#import "ITBNewsAPI.h"

#import "ITBUtils.h"

#import "ITBUser.h"
#import "ITBCategory.h"
#import "ITBNews.h"

static NSString * const categoriesTitle = @"Categories";
static NSString * const allCatsCell = @"All categories";

@interface ITBCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *allCategoriesArray;
@property (strong, nonatomic) NSArray *categoriesOfCurrentUserArray;

@property (strong, nonatomic) NSArray *allSortingsArray;

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;

@property (strong, nonatomic) NSMutableArray *checkBoxes;
@property (assign, nonatomic) BOOL isAllChecked;

@property (assign, nonatomic) NSInteger sortingCheckmarkIndex;

@end

@implementation ITBCategoriesViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(categoriesTitle, nil);
    
    // self.allCategoriesArray
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    self.allCategoriesArray = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:@"ITBCategory" withSortDescriptors:@[titleDescriptor] predicate:nil inContext:[ITBNewsAPI sharedInstance].mainManagedObjectContext];
    
    // self.categoriesOfCurrentUserArray
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefaults objectForKey:kSettingsObjectId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    NSArray *users = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:@"ITBUser" withSortDescriptors:nil predicate:predicate inContext:[ITBNewsAPI sharedInstance].mainManagedObjectContext];
    ITBUser *currentUser = [users firstObject];
    self.categoriesOfCurrentUserArray = [currentUser.selectedCategories allObjects];
    
    // self.sortingCheckmarkIndex
    NSNumber *number = [userDefaults objectForKey:kSettingsChosenSortingType];
    self.sortingCheckmarkIndex = [number intValue];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionDone:)];
        
        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
        
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    
    self.checkBoxes = [[NSMutableArray alloc] init];
    
    for (ITBCategory *category in self.allCategoriesArray) {
        
        BOOL checkBox = NO;
        
        if ([self.categoriesOfCurrentUserArray containsObject:category]) {
            
            checkBox = YES;
        }
        
        [self.checkBoxes addObject:[NSNumber numberWithBool:checkBox]];
    }
    
    self.allSortingsArray = @[@"Hot news", @"New news", @"Created news", @"Favourites"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return [self.allSortingsArray count];
        
    } else if (section == 1) {
        
        return 1;
        
    } else {
        
        return [self.allCategoriesArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"Cell";
    static NSString *allIdentifier = @"All";
    static NSString *sortingIdentifier = @"Sorting";
    
    UITableViewCell *cell;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:sortingIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sortingIdentifier];
        }
        
        NSString *sortingType = [self.allSortingsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = sortingType;
        
        if (indexPath.row == self.sortingCheckmarkIndex) {
            
            cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
            
        } else {
            
            cell.backgroundColor = [UIColor whiteColor];
        }
    
    } else if (indexPath.section == 1) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:allIdentifier];
        
        cell.textLabel.text = NSLocalizedString(allCatsCell, nil);
        
        BOOL areAllCellsChosen = YES;
        for (int i=0; i < [self.checkBoxes count]; i++) {
            
            NSNumber *number = [self.checkBoxes objectAtIndex:i];
            BOOL isCellChosen = [number boolValue];
            
            areAllCellsChosen = areAllCellsChosen * isCellChosen;
        }
        
        if (areAllCellsChosen) {
            
            self.isAllChecked = YES;
        }
        
        if ( (self.isAllChecked) || (areAllCellsChosen) ) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        }
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        ITBCategory *category = [self.allCategoriesArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = category.title;
        
        NSNumber *number = [self.checkBoxes objectAtIndex:indexPath.row];
        BOOL hasCheckBox = [number boolValue];
        
        if (hasCheckBox) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        
    }
    
    return cell;
}

#pragma mark - UITableViewDataDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        self.sortingCheckmarkIndex = indexPath.row;
        
        [self.categoriesTableView reloadData];
        
    } else if (indexPath.section == 1) {
        
        for (int i=0; i < [self.checkBoxes count]; i++) {
            
            [self.checkBoxes replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!self.isAllChecked]];
        }
        
        self.isAllChecked = !self.isAllChecked;
        
        [self.categoriesTableView reloadData];
        
    } else {
        
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
        
//        [self.categoriesTableView reloadData];
        
        [self.categoriesTableView beginUpdates];
        [self.categoriesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.categoriesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        [self.categoriesTableView endUpdates];
        
    }
    
    NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
    
    for (ITBCategory *category in self.allCategoriesArray) {
        
        NSInteger i = [self.allCategoriesArray indexOfObject:category];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        
        if (hasCheckBox) {
            
            [categoriesOfCurrentUser addObject:category];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
        
        for (ITBCategory *category in self.allCategoriesArray) {
            
            NSInteger i = [self.allCategoriesArray indexOfObject:category];
            NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
            BOOL hasCheckBox = [numberWithBool boolValue];
            
            if (hasCheckBox) {
                
                [categoriesOfCurrentUser addObject:category];
            }
        }
        
        self.categoriesOfCurrentUserArray = [categoriesOfCurrentUser copy];
        
        [self.delegate reloadCategoriesFrom:self withCategoriesOfCurrentUserArray:self.categoriesOfCurrentUserArray sortingNamesArray:self.allSortingsArray sortingType:self.sortingCheckmarkIndex];
        
    }
}

#pragma mark - Actions

- (void)actionDone:(UIBarButtonItem *)sender {

    NSMutableArray *categoriesOfCurrentUser = [[NSMutableArray alloc] init];
    
    for (ITBCategory *category in self.allCategoriesArray) {
        
        NSInteger i = [self.allCategoriesArray indexOfObject:category];
        NSNumber *numberWithBool = [self.checkBoxes objectAtIndex:i];
        BOOL hasCheckBox = [numberWithBool boolValue];
        
        if (hasCheckBox) {
            
            [categoriesOfCurrentUser addObject:category];
        }
    }
    
    self.categoriesOfCurrentUserArray = [categoriesOfCurrentUser copy];
    
    [self.delegate reloadCategoriesFrom:self withCategoriesOfCurrentUserArray:self.categoriesOfCurrentUserArray sortingNamesArray:self.allSortingsArray sortingType:self.sortingCheckmarkIndex];
 
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
