//
//  ITBHotNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBHotNewsViewController.h"

#import "ITBDataManager.h"
#import "ITBServerManager.h"

#import "ITBNewsCD.h"
#import "ITBCategoryCD.h"
#import "ITBUserCD.h"

#import "ITBUser.h"
#import "ITBNews.h"

#import "ITBLoginTableViewController.h"

#import "ITBNewsDetailViewController.h"

#import "ITBCategoriesViewController.h"

#import "ITBNewsCell.h"

NSString *const hotNewsTitle = @"HOT NEWS";

@interface ITBHotNewsViewController () <ITBLoginTableViewControllerDelegate, NSFetchedResultsControllerDelegate, ITBNewsCellDelegate, ITBCategoriesPickerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) ITBServerManager* serverManager;
@property (strong, nonatomic) ITBDataManager* dataManager;

@end

@implementation ITBHotNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)init {
    
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        
    }
    
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        
        _managedObjectContext = [[ITBDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serverManager = [ITBServerManager sharedManager];
    self.dataManager = [ITBDataManager sharedManager];
    
    // Do any additional setup after loading the view.
    
//    self.navigationItem.title = @"Hot news";
    self.title = NSLocalizedString(hotNewsTitle, nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    
    self.categoriesPickerButton.enabled = (self.dataManager.currentUser.sessionToken != nil);
    self.refreshButton.enabled = (self.dataManager.currentUser.sessionToken != nil);
    
    self.loginButton.title = (self.dataManager.currentUser.sessionToken != nil) ? @"Logout" : @"Login";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// пока мне вообще не нужен этот метод добавления нового объекта (т.е. новости)
- (void)insertNewObject:(id)sender {
}

#pragma mark - UIViewController methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
    if ([self.loginButton.title isEqualToString:@"Logout"]) {
        
        self.loginButton.title = NSLocalizedString(login, nil);
        
        self.dataManager.currentUser = nil;
        self.dataManager.currentUserCD = nil;
        
        self.categoriesPickerButton.enabled = (self.dataManager.currentUser != nil);
        self.refreshButton.enabled = (self.dataManager.currentUser != nil);
        
        [self.dataManager saveSettings];
        
        [self.tableView reloadData];
        
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"login"])
    {
        
        UINavigationController *loginNavVC = [segue destinationViewController];
        
        ITBLoginTableViewController* loginVC = (ITBLoginTableViewController* )loginNavVC.topViewController;
        
        loginVC.delegate = self;
        
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
//    [self.dataManager fetchCurrentUserForObjectId:[userDefaults objectForKey:kSettingsObjectId]];
//    [self.dataManager fetchAllCategories]; // здесь вычисляется self.allCategories когда мы либо загружаем локальную БД (при загрузке app) либо когда нажимаем refreshButton
    
    ITBUserCD* user = self.dataManager.currentUserCD;
    
    if (user != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *description = [NSEntityDescription entityForName:@"ITBNewsCD"
                                                       inManagedObjectContext:self.managedObjectContext];
        
//    [fetchRequest setResultType:NSDictionaryResultType]; // that line doesn't work with NSFetchedResultsController
        
        [fetchRequest setEntity:description];
        
        NSSortDescriptor *ratingDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
        [fetchRequest setSortDescriptors:@[ratingDescriptor]];
        //    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        //    [fetchRequest setSortDescriptors:@[titleDescriptor]];
        
//        NSLog(@"[user.selectedCategories count] = %u", [user.selectedCategories count]);
        
        if ([user.selectedCategories count] != 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category IN %@", user.selectedCategories];
            [fetchRequest setPredicate:predicate];
            
        } else {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category.title == %@", @"nothing"];
            [fetchRequest setPredicate:predicate];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                                 initWithFetchRequest:fetchRequest
                                                                 managedObjectContext:self.managedObjectContext
                                                                 sectionNameKeyPath:nil cacheName:nil];
        
        aFetchedResultsController.delegate = self;
        
        self.fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //     abort();
        }
        
        return _fetchedResultsController;
    }
    
    return nil;
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    return [[self.fetchedResultsController sections] count];
    
    if (self.dataManager.currentUser != nil) {
        
        return [[self.fetchedResultsController sections] count];
    } else {
        
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    
    if (self.dataManager.currentUser != nil) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataManager.currentUser != nil) {
        
        static NSString *identifier = @"NewsCell";
        
        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.delegate = self;
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noData"];
        
        cell.textLabel.text = NSLocalizedString(beforeLogin, nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        return cell;
        
    }
}

- (void)configureCell:(ITBNewsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ITBNewsCD *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = newsItem.title;
    
    cell.categoryLabel.text = newsItem.category.title;
    
//    cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[newsItem.likeAddedUsers count]];
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@", newsItem.rating];
    
    BOOL isLikedByCurrentUserCD = [newsItem.likeAddedUsers containsObject:self.dataManager.currentUserCD];
    
    cell.addLikeButton.enabled = !isLikedByCurrentUserCD;
    cell.subtractLikeButton.enabled = isLikedByCurrentUserCD;
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //            abort();
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - ITBLoginTableViewControllerDelegate

- (void) loginDidPassSuccessfully:(ITBLoginTableViewController *)vc {
    
    self.loginButton.title = @"Logout";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.categoriesPickerButton.enabled = (self.dataManager.currentUser != nil);
        self.refreshButton.enabled = (self.dataManager.currentUser != nil);
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC {
    
    self.dataManager.currentUserCD.selectedCategories = [NSSet setWithArray:categoriesVC.categoriesOfCurrentUserArray];
    
    NSLog(@"number of self.dataManager.currentUser.categories NSSet = %li", (long)[self.dataManager.currentUserCD.selectedCategories count]);
    
    // здесь идет сохранение в permanent store
    [self.managedObjectContext save:nil];
    
    self.fetchedResultsController = nil; // эта проперти обнуляется чтобы заново сделать выборку используя новые данные selectedCategories
    
    [self.tableView reloadData];
}

#pragma mark - ITBNewsCellDelegate

- (void)newsCellDidTapAdd:(ITBNewsCell *) cell {
    
    [self getNewsCellForSender: cell];
}

- (void)newsCellDidTapSubtract:(ITBNewsCell *) cell {
    
    [self getNewsCellForSender: cell];
}

- (void)newsCellDidTapDetail:(ITBNewsCell *) cell {
    
    ITBNewsDetailViewController *newsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBNewsDetailViewController"];
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNewsCD *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString: newsItem.newsURL];
    
    newsDetailVC.title = newsItem.title;
    newsDetailVC.url = url;
    
    [self.navigationController pushViewController:newsDetailVC animated:YES];
    
}

#pragma mark - Private Methods

// этот метод нужен для методов протокола ITBNewsCellDelegate
- (void) getNewsCellForSender:(ITBNewsCell* ) cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNewsCD *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL isLikedByCurrentUser = [newsItem.likeAddedUsers containsObject:self.dataManager.currentUserCD];
    
    if (isLikedByCurrentUser) {
        
        [newsItem removeLikeAddedUsersObject:self.dataManager.currentUserCD];
        
    } else {
        
        [newsItem addLikeAddedUsersObject:self.dataManager.currentUserCD];
        
    }
    
    // здесь идет сохранение в permanent store
    [self.managedObjectContext save:nil];
    
    // мне надо сделать reloadData для всей таблицы т.к. у меня идет сортировка по RATING который меняется в результате нажатия на + или - и в результате после каждого нажатия меняется порядок во всей таблице
        [self.tableView reloadData];
/*
    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
*/
    
}

#pragma mark - Actions

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
    
    ITBCategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCategoriesViewController"];
    
//    vc.allCategoriesArray = [self.dataManager fetchAllCategories];
//    [self.dataManager fetchAllCategories]; //  вызов этого метода не здесь а когда мы либо загружаем локальную БД либо нажимаем refreshButton
    vc.allCategoriesArray = self.dataManager.allCategoriesArray;
    vc.categoriesOfCurrentUserArray = [self.dataManager.currentUserCD.selectedCategories allObjects];
    
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (sender == nil) {
            return;
        }
        
        nav.modalPresentationStyle = UIModalPresentationPopover;
//        nav.preferredContentSize = CGSizeMake(300, 400);
        
        [self presentViewController:nav animated:YES completion:nil];
        
        UIPopoverPresentationController* popoverPresentationController = nav.popoverPresentationController;
        
        popoverPresentationController.sourceView = self.view;
        
        [popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionUp];
        
        
    } else {
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

- (IBAction)actionRefresh:(UIBarButtonItem *)sender {
    
    __weak ITBHotNewsViewController* weakSelf = self;
    
    [self.serverManager updateLocalDataSourceOnSuccess:^(BOOL isSuccess) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            weakSelf.fetchedResultsController = nil;
            [weakSelf.tableView reloadData];
        });
        
    }];
}

@end
