//
//  ITBHotNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBHotNewsViewController.h"
#import <CoreData/CoreData.h>

#import "ITBNewsAPI.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"

#import "ITBLoginTableViewController.h"

#import "ITBNewsDetailViewController.h"

#import "ITBCategoriesViewController.h"

#import "ITBNewsCell.h"

NSString *const hotNewsTitle = @"HOT NEWS";

@interface ITBHotNewsViewController () <NSFetchedResultsControllerDelegate, ITBLoginTableViewControllerDelegate, ITBNewsCellDelegate, ITBCategoriesPickerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesPickerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ITBHotNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)init {
    
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self != nil) {
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
//    self.navigationItem.title = @"Hot news";
    self.title = NSLocalizedString(hotNewsTitle, nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    
    self.categoriesPickerButton.enabled = ([ITBNewsAPI sharedInstance].currentUser.username != nil);
    self.refreshButton.enabled = self.categoriesPickerButton.enabled;
    
    self.loginButton.title = self.categoriesPickerButton.enabled ? NSLocalizedString(logout, nil) : NSLocalizedString(login, nil);
    
    // refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(refreshNews) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
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
    
    if ([self.loginButton.title isEqualToString:NSLocalizedString(logout, nil)]) {
        
        [[ITBNewsAPI sharedInstance] logOut];
        
        self.loginButton.title = NSLocalizedString(login, nil);
        
        self.categoriesPickerButton.enabled = NO;
        self.refreshButton.enabled = NO;
        
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
    
    if ([ITBNewsAPI sharedInstance].currentUser != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *description = [NSEntityDescription entityForName:@"ITBNews"
                                                       inManagedObjectContext:[ITBNewsAPI sharedInstance].managedObjectContext];
        
        [fetchRequest setEntity:description];
        
        NSSortDescriptor *ratingDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
        [fetchRequest setSortDescriptors:@[ratingDescriptor]];
        
//    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
//    [fetchRequest setSortDescriptors:@[titleDescriptor]];
        
//        NSLog(@"[user.selectedCategories count] = %u", [user.selectedCategories count]);
        
        if ([[ITBNewsAPI sharedInstance].currentUser.selectedCategories count] != 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category IN %@", [ITBNewsAPI sharedInstance].currentUser.selectedCategories];
            [fetchRequest setPredicate:predicate];
            
        } else {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category.title == %@", @"nothing"];
            [fetchRequest setPredicate:predicate];
        }
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                                 initWithFetchRequest:fetchRequest
                                                                 managedObjectContext:[ITBNewsAPI sharedInstance].managedObjectContext
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
    
    if ([ITBNewsAPI sharedInstance].currentUser != nil) {
        
        return [[self.fetchedResultsController sections] count];
        
    } else {
        
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([ITBNewsAPI sharedInstance].currentUser != nil) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([ITBNewsAPI sharedInstance].currentUser != nil) {
        
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
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = newsItem.title;
    
    cell.categoryLabel.text = newsItem.category.title;
    
//    cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[newsItem.likeAddedUsers count]];
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@", newsItem.rating];
    
    BOOL isLikedByCurrentUser = [newsItem.likeAddedUsers containsObject:[ITBNewsAPI sharedInstance].currentUser];
    NSLog(@"Select categories checking : currentUser = %@, likeAddedUsers count = %li", [ITBNewsAPI sharedInstance].currentUser.username, (long)[newsItem.likeAddedUsers count]);
    for (ITBUser* likeAddedUser in newsItem.likeAddedUsers) {
        NSLog(@"likeAddedUser %@ for newsItem %@", likeAddedUser.username, newsItem.title);
    }
    
//    NSLog(@"after login i'm checking count of newsItem.likeAddedUsers - %li for newsItem.title - %@", [newsItem.likeAddedUsers count], newsItem.title);
    
    cell.addLikeButton.enabled = !isLikedByCurrentUser;
    cell.subtractLikeButton.enabled = isLikedByCurrentUser;
    
    NSLog(@"cell.addLikeButton.enabled = %i for newsItem - %@", !cell.addLikeButton.enabled, newsItem.title);
    
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
        
        self.categoriesPickerButton.enabled = ([ITBNewsAPI sharedInstance].currentUser != nil);
        self.refreshButton.enabled = self.categoriesPickerButton.enabled;
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC {
    
    [ITBNewsAPI sharedInstance].currentUser.selectedCategories = [NSSet setWithArray:categoriesVC.categoriesOfCurrentUserArray];
    
    NSLog(@"number of self.dataManager.currentUser.categories NSSet = %li", (long)[[ITBNewsAPI sharedInstance].currentUser.selectedCategories count]);
    
    // здесь идет сохранение в permanent store
    [[ITBNewsAPI sharedInstance].managedObjectContext save:nil];
    
    self.fetchedResultsController = nil;

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
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString: newsItem.newsURL];
    
    newsDetailVC.title = newsItem.title;
    newsDetailVC.url = url;
    
    [self.navigationController pushViewController:newsDetailVC animated:YES];
    
}

- (void) getNewsCellForSender:(ITBNewsCell* ) cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL isLikedByCurrentUser = [newsItem.likeAddedUsers containsObject:[ITBNewsAPI sharedInstance].currentUser];
    
    NSInteger ratingInt = [newsItem.rating integerValue];
    
    if (isLikedByCurrentUser) {
        
        [newsItem removeLikeAddedUsersObject:[ITBNewsAPI sharedInstance].currentUser];
        --ratingInt;
        
    } else {
        
        [newsItem addLikeAddedUsersObject:[ITBNewsAPI sharedInstance].currentUser];
        ++ratingInt;
    }
    
    newsItem.rating = [NSNumber numberWithInteger:ratingInt];
    
    [[ITBNewsAPI sharedInstance].managedObjectContext save:nil];
    
    [self.tableView reloadData];
    
}

#pragma mark - Private Methods

- (void)refreshNews {
    
    [[ITBNewsAPI sharedInstance]
     updateCurrentUserFromLocalToServerOnSuccess:^(BOOL isSuccess)
     {
         
         if (isSuccess) {
             
             __weak ITBHotNewsViewController* weakSelf = self;
             
             [[ITBNewsAPI sharedInstance] updateLocalDataSourceOnSuccess:^(BOOL isSuccess)
              {
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      
                      weakSelf.fetchedResultsController = nil;
                      [weakSelf.tableView reloadData];
                      
                      [weakSelf.refreshControl endRefreshing];
                      
                  });
              }];
         }
         
     }];
    
}

#pragma mark - Actions

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
    
    ITBCategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCategoriesViewController"];
    
    vc.allCategoriesArray = [[ITBNewsAPI sharedInstance] fetchAllCategories];
    
    vc.categoriesOfCurrentUserArray = [[ITBNewsAPI sharedInstance].currentUser.selectedCategories allObjects];
    
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
    
    [self updateCurrentUserFromLocalToServer];
    
}

- (void) updateLocalDataSource
{
    
    __weak ITBHotNewsViewController* weakSelf = self;
    
    [[ITBNewsAPI sharedInstance] updateLocalDataSourceOnSuccess:^(BOOL isSuccess)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             weakSelf.fetchedResultsController = nil;
             [weakSelf.tableView reloadData];
             
         });
     }];
    
}

- (void) updateCurrentUserFromLocalToServer
{
    
    [[ITBNewsAPI sharedInstance]
     updateCurrentUserFromLocalToServerOnSuccess:^(BOOL isSuccess)
     {
         
         if (isSuccess) {
             
             [self updateLocalDataSource];
         }
         
     }];
}

@end
