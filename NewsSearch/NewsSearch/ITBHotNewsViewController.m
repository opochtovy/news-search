//
//  ITBHotNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 16.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBHotNewsViewController.h"

#import "ITBUtils.h"

#import <CoreData/CoreData.h>

#import "ITBNewsAPI.h"
#import "ITBActiveNewsCell.h"
#import "ITBNewsCellDelegate.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"
#import "ITBPhoto.h"

#import "ITBLoginTableViewController.h"

#import "ITBNewsDetailViewController.h"
#import "ITBCustomNewsDetailViewController.h"
#import "ITBAddCustomNewsViewController.h"

#import "ITBCategoriesViewController.h"

#import "ITBNewsCell.h"

#import <Social/Social.h>

static NSString * const hotNewsTitle = @"NEWS";
static NSString * const loginSegueId = @"login";

@interface ITBHotNewsViewController () <NSFetchedResultsControllerDelegate, ITBLoginTableViewControllerDelegate, ITBNewsCellDelegate, ITBCategoriesPickerDelegate, ITBCustomNewsDetailViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesPickerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewsButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) ITBSortingType chosenSortingType;

@property (strong, nonatomic) ITBNews *customNewsItem;

@end

@implementation ITBHotNewsViewController

#pragma mark - Lifecycle

- (id)init {
    
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self != nil) {
        
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(hotNewsTitle, nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200.0;
    
    BOOL wasUserSavedLocally = ([ITBNewsAPI sharedInstance].currentUser.username != nil);
    
    self.categoriesPickerButton.enabled = wasUserSavedLocally;
    self.refreshButton.enabled = wasUserSavedLocally;
    self.addNewsButton.enabled = wasUserSavedLocally;
    
    self.loginButton.title = wasUserSavedLocally ? NSLocalizedString(logout, nil) : NSLocalizedString(login, nil);
    
    // refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(refreshNews) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // initializing of self.chosenSortingType
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *number = [userDefaults objectForKey:kSettingsChosenSortingType];
    self.chosenSortingType = [number intValue];

    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification* note) {
        
        NSManagedObjectContext *mainContext = [ITBNewsAPI sharedInstance].mainManagedObjectContext;
        NSManagedObjectContext *syncContext = [ITBNewsAPI sharedInstance].syncManagedObjectContext;
        
        NSManagedObjectContext *otherContext = note.object;
        
        if (otherContext.persistentStoreCoordinator == mainContext.persistentStoreCoordinator) {
            
            if (otherContext == syncContext) {
            
                [mainContext performBlock:^(){
                    
                    [mainContext mergeChangesFromContextDidSaveNotification:note];
                    
                    [[ITBNewsAPI sharedInstance] saveMainContext];
                    [[ITBNewsAPI sharedInstance] saveSaveContext];
                }];
            }
        }
    }];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [ITBNewsAPI sharedInstance].mainManagedObjectContext;
    
    NSArray *users = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:@"ITBUser" usingContext:context];
    ITBUser *currentUser = [users firstObject];
    
    if (currentUser.objectId != nil) {
        
        [context performBlockAndWait:^{
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            
            NSEntityDescription *description = [NSEntityDescription entityForName:@"ITBNews" inManagedObjectContext:context];
            
            [fetchRequest setEntity:description];
            
            NSString *descriptorKey;
            
            NSPredicate *predicate;
            
            if ([currentUser.selectedCategories count] != 0) {
                
                predicate = [NSPredicate predicateWithFormat:@"category IN %@", currentUser.selectedCategories];
                
            } else {
                
                predicate = [NSPredicate predicateWithFormat:@"category.title == %@", @"nothing"];
            }
            
            switch (self.chosenSortingType) {
                    
                case ITBSortingTypeHot:
                    descriptorKey = @"rating";
                    break;
                    
                case ITBSortingTypeNew:
                    descriptorKey = @"createdAt";
                    break;
                    
                case ITBSortingTypeCreated: {
                    descriptorKey = @"title";
                    
                    if ([currentUser.selectedCategories count] != 0) {
                        
                        predicate = [NSPredicate predicateWithFormat:@"(category IN %@) AND (author.objectId == %@)", currentUser.selectedCategories, currentUser.objectId];
                        
                    } else {
                        
                        predicate = [NSPredicate predicateWithFormat:@"(category.title == %@) AND (author.objectId == %@)", @"nothing", currentUser.objectId];
                        
                    }
                    break;
                }
                    
                case ITBSortingTypeFavourites: {
                    descriptorKey = @"title";
                    
                    if ([currentUser.favouriteNews count] != 0) {
                        
                        predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", currentUser.favouriteNews];
                        
                    } else {
                        
                        predicate = [NSPredicate predicateWithFormat:@"objectId == %@", @"nothing"];
                        
                    }
                    break;
                }
            }
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:descriptorKey ascending:NO];
            [fetchRequest setSortDescriptors:@[descriptor]];
            
            [fetchRequest setPredicate:predicate];
            
            NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
            
            aFetchedResultsController.delegate = self;
            
            self.fetchedResultsController = aFetchedResultsController;
            
            NSError *error = nil;
            
            if (![self.fetchedResultsController performFetch:&error]) {
                
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            
        }];
        
        return _fetchedResultsController;
    }
    
    return nil;
}

#pragma mark - Private

- (void)getNewsCellForSender:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];

    BOOL isLikedByCurrentUser = [newsItem.isLikedByCurrentUser boolValue];
    
    NSInteger ratingInt = [newsItem.rating integerValue];
    
    if (isLikedByCurrentUser) {
        
        [newsItem removeLikeAddedUsersObject:[ITBNewsAPI sharedInstance].currentUser];
        --ratingInt;
        newsItem.isLikedByCurrentUser = @0;
        
    } else {
        
        [newsItem addLikeAddedUsersObject:[ITBNewsAPI sharedInstance].currentUser];
        ++ratingInt;
        newsItem.isLikedByCurrentUser = @1;
        
    }
    
    newsItem.rating = [NSNumber numberWithInteger:ratingInt];
    
}

- (void)refreshNews {
    
    __weak ITBHotNewsViewController *weakSelf = self;
    
    NSArray *allLocalNews = [[ITBNewsAPI sharedInstance] newsInLocalDB];
    
    if ([allLocalNews count] > 0) {
        
        [[ITBNewsAPI sharedInstance] updateCurrentUserFromLocalToServerOnSuccess:^(BOOL isSuccess) {
            
            if (isSuccess) {
                
                [[ITBNewsAPI sharedInstance] updateLocalDataSourceOnSuccess:^(BOOL isSuccess) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.fetchedResultsController = nil;
                        [weakSelf.tableView reloadData];
                        
                        [weakSelf.refreshControl endRefreshing];
                        
                    });
                }];
            }
            
        }];
        
    } else {
        
        [[ITBNewsAPI sharedInstance] createLocalDataSourceOnSuccess:^(BOOL isSuccess) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.fetchedResultsController = nil;
                [weakSelf.tableView reloadData];
                
                [weakSelf.refreshControl endRefreshing];
                
            });
        }];
    }
}

#pragma mark - UIViewController methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
    if ( ([identifier isEqualToString:loginSegueId]) && ([ITBNewsAPI sharedInstance].currentUser.sessionToken != nil) ) {
        
        [[ITBNewsAPI sharedInstance] logOut];
        
        self.loginButton.title = NSLocalizedString(login, nil);
        
        self.categoriesPickerButton.enabled = NO;
        self.refreshButton.enabled = NO;
        self.addNewsButton.enabled = NO;
        
        [self.tableView reloadData];
        
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:loginSegueId]) {
        
        UINavigationController *loginNavVC = [segue destinationViewController];
        
        ITBLoginTableViewController *loginVC = (ITBLoginTableViewController *)loginNavVC.topViewController;
        
        loginVC.delegate = self;
        
    }
    
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
        
        ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        static NSString *identifier = @"NewsCell";
        static NSString *activeIdentifier = @"ActiveNewsCell";
        
//        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        BOOL isTitlePressed = [newsItem.isTitlePressed boolValue];
        
        if (isTitlePressed) {
            
            ITBActiveNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:activeIdentifier];
            
            cell.activeDelegate = self;
            
            [self configureActiveCell:cell atIndexPath:indexPath];
            
            return cell;
        
        } else {
            
            ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            cell.delegate = self;
            
            [self configureCell:cell atIndexPath:indexPath];
            
            return cell;
        }
        
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
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@", newsItem.rating];
    
    BOOL isLikedByCurrentUser = ([newsItem.isLikedByCurrentUser intValue] > 0);
    
    cell.addLikeButton.enabled = !isLikedByCurrentUser;
    cell.subtractLikeButton.enabled = isLikedByCurrentUser;
    
}

- (void)configureActiveCell:(ITBActiveNewsCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = newsItem.title;
    cell.categoryLabel.text = newsItem.category.title;
    cell.ratingLabel.text = [NSString stringWithFormat:@"%@", newsItem.rating];
    
    BOOL isLikedByCurrentUser = ([newsItem.isLikedByCurrentUser intValue] > 0);
    
    cell.addLikeButton.enabled = !isLikedByCurrentUser;
    cell.subtractLikeButton.enabled = isLikedByCurrentUser;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        [context performBlockAndWait:^{
            
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            if (context == [ITBNewsAPI sharedInstance].mainManagedObjectContext) {

                [[ITBNewsAPI sharedInstance] saveMainContext];
                [[ITBNewsAPI sharedInstance] saveSaveContext];
                
            }
            
        }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
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
            
        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

#pragma mark - ITBLoginTableViewControllerDelegate

- (void)loginDidPassSuccessfully:(ITBLoginTableViewController *)vc {
    
    self.loginButton.title = @"Logout";
    
    dispatch_async(dispatch_get_main_queue(), ^{

        self.categoriesPickerButton.enabled = YES;
        self.refreshButton.enabled = YES;
        self.addNewsButton.enabled = YES;
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC withCategoriesOfCurrentUserArray:(NSArray *)categoriesOfCurrentUser sortingNamesArray:(NSArray *)categoryNames sortingType:(NSInteger)index {
    
    // saving chosenSortingType
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:[NSNumber numberWithInteger:index] forKey:kSettingsChosenSortingType];
    
    self.chosenSortingType = (int)index;
    
    [[ITBNewsAPI sharedInstance].mainManagedObjectContext performBlockAndWait:^{
        
        [ITBNewsAPI sharedInstance].currentUser.selectedCategories = [NSSet setWithArray:categoriesOfCurrentUser];
        
        [[ITBNewsAPI sharedInstance] saveMainContext];
        [[ITBNewsAPI sharedInstance] saveSaveContext];
        
        self.title = [categoryNames objectAtIndex:index];
        [userDefaults setObject:self.title forKey:kSettingsChosenSortingName];
        
        self.fetchedResultsController = nil;
        [self.tableView reloadData];
        
    }];
}

#pragma mark - ITBNewsCellDelegate

- (void)newsCellDidTapAdd:(UITableViewCell *)cell {
    
    [[ITBNewsAPI sharedInstance].mainManagedObjectContext performBlockAndWait:^{
        
        [self getNewsCellForSender:cell];
        
        [[ITBNewsAPI sharedInstance] saveMainContext];
        [[ITBNewsAPI sharedInstance] saveSaveContext];
        
        [self.tableView reloadData];
        
    }];
}

- (void)newsCellDidTapSubtract:(UITableViewCell *)cell {
    
    [[ITBNewsAPI sharedInstance].mainManagedObjectContext performBlockAndWait:^{
        
        [self getNewsCellForSender:cell];
        
        [[ITBNewsAPI sharedInstance] saveMainContext];
        [[ITBNewsAPI sharedInstance] saveSaveContext];
        
        [self.tableView reloadData];
        
    }];
}

- (void)newsCellDidTapDetail:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (newsItem.newsURL != nil) {
        
        ITBNewsDetailViewController *newsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBNewsDetailViewController"];
        
        NSURL *url = [NSURL URLWithString:newsItem.newsURL];
        
        newsDetailVC.title = newsItem.title;
        newsDetailVC.url = url;
        
        [self.navigationController pushViewController:newsDetailVC animated:YES];
        
    } else {
        
        ITBCustomNewsDetailViewController *customNewsDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCustomNewsDetailViewController"];
        
        customNewsDetailVC.delegate = self;
        
        self.customNewsItem = newsItem;
        
        [self.navigationController pushViewController:customNewsDetailVC animated:YES];
    }
    
}

- (void)newsCellDidSelectTitle:(UITableViewCell *) cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    newsItem.isTitlePressed = [NSNumber numberWithBool:YES];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

- (void)newsCellDidSelectHide:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    newsItem.isTitlePressed = [NSNumber numberWithBool:NO];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

- (void)newsCellDidAddToFavourites:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ITBUser *currentUser = [ITBNewsAPI sharedInstance].currentUser;
    
    if (![currentUser.favouriteNews containsObject:newsItem]) {
        
        [[ITBNewsAPI sharedInstance].mainManagedObjectContext performBlockAndWait:^{
            
            [currentUser addFavouriteNewsObject:newsItem];
            
            [[ITBNewsAPI sharedInstance] saveMainContext];
            [[ITBNewsAPI sharedInstance] saveSaveContext];
            
        }];
        
    }
}

- (void)newsCellDidTapTweetButton:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:newsItem.title];
        
        if (newsItem.newsURL != nil) {
            
            [tweetSheet addURL:[NSURL URLWithString:newsItem.newsURL]];
            
        }
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }
    
}

- (void)newsCellDidTapFacebookButton:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        if (newsItem.newsURL != nil) {
            
            [facebookSheet addURL:[NSURL URLWithString:newsItem.newsURL]];
            
        } else {
            
            [facebookSheet setInitialText:newsItem.title];
            
        }
        
        [self presentViewController:facebookSheet animated:YES completion:Nil];
    }
}

#pragma mark - ITBCustomNewsDetailViewControllerDataSource

- (ITBNews *)sendNewsItemTo:(ITBCustomNewsDetailViewController *)newsDetailVC {
    
    return self.customNewsItem;
}

#pragma mark - IBActions

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
    
    ITBCategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCategoriesViewController"];
    
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (sender == nil) {
            return;
        }
        
        nav.modalPresentationStyle = UIModalPresentationPopover;
        
        [self presentViewController:nav animated:YES completion:nil];
        
        UIPopoverPresentationController *popoverPresentationController = nav.popoverPresentationController;
        
        popoverPresentationController.sourceView = self.view;
        
        [popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionUp];
        
        
    } else {
        
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (IBAction)actionRefresh:(UIBarButtonItem *)sender {

    [self.refreshControl beginRefreshing];
    self.tableView.contentOffset = CGPointMake(0.f, -120.f);
    
    __weak ITBHotNewsViewController *weakSelf = self;
    
    NSArray *allLocalNews = [[ITBNewsAPI sharedInstance] newsInLocalDB];

    if ([allLocalNews count] > 0) {

        [[ITBNewsAPI sharedInstance] updateCurrentUserFromLocalToServerOnSuccess:^(BOOL isSuccess) {
             
             if (isSuccess) {
                 
                 [[ITBNewsAPI sharedInstance] updateLocalDataSourceOnSuccess:^(BOOL isSuccess) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          weakSelf.fetchedResultsController = nil;
                          [weakSelf.tableView reloadData];
                          
                          weakSelf.tableView.contentOffset = CGPointMake(0.f, 0.f);
                          
                          [weakSelf.refreshControl endRefreshing];
                          
                      });
                  }];
             }
             
         }];

        
    } else {
        
        [[ITBNewsAPI sharedInstance] createLocalDataSourceOnSuccess:^(BOOL isSuccess) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 weakSelf.fetchedResultsController = nil;
                 [weakSelf.tableView reloadData];
                 
                 weakSelf.tableView.contentOffset = CGPointMake(0.f, 0.f);
                 
                 [weakSelf.refreshControl endRefreshing];
             });
         }];
    }
}

@end
