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

#import <CoreLocation/CoreLocation.h>

static NSString * const hotNewsTitle = @"News";

static NSString * const loginSegueId = @"login";
static NSString * const chooseCategoriesSegueId = @"chooseCategories";
static NSString * const showNewsPageSegueId = @"showNewsPage";
static NSString * const showCustomNewsPageSegueId = @"showCustomNewsPage";

static NSString * const ITBNewsCellReuseIdentifier = @"NewsCell";
static NSString * const ITBActiveNewsCellReuseIdentifier = @"ActiveNewsCell";
static NSString * const noDataReuseIdentifier = @"noData";

static NSString * const logoutTitleOfLoginButton = @"Logout";

static NSString * const errorMessage = @"Unresolved error:";

@interface ITBHotNewsViewController () <NSFetchedResultsControllerDelegate, ITBLoginTableViewControllerDelegate, ITBNewsCellDelegate, ITBCategoriesPickerDelegate, ITBCustomNewsDetailViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoriesPickerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewsButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) ITBSortingType chosenSortingType;

@property (strong, nonatomic) ITBNews *newsItemForDetailPage;

@property (strong, nonatomic) NSArray *newsByGeolocationArray;

@end

@implementation ITBHotNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Lifecycle

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[ITBNewsAPI sharedInstance].bgManagedObjectContext];
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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshNews) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [userDefaults objectForKey:kSettingsChosenSortingType];
    self.chosenSortingType = [number intValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForMainContext:) name:NSManagedObjectContextDidSaveNotification object:[ITBNewsAPI sharedInstance].bgManagedObjectContext];
    
    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
    
    [self hideSharingButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshDataForMainContext:(NSNotification *)notification {
    
    NSManagedObjectContext *mainContext = [ITBNewsAPI sharedInstance].mainManagedObjectContext;
    
    [mainContext mergeChangesFromContextDidSaveNotification:notification];
    
    NSError *error = nil;
    BOOL saved = [mainContext save:&error];
    if (!saved) {
        NSLog(@"%@ %@", contextSavingError, error);
    }

}

#pragma mark - Custom Accessors

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [ITBNewsAPI sharedInstance].mainManagedObjectContext;
    
    NSArray *users = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:ITBUserEntityName usingContext:context];
    ITBUser *currentUser = [users firstObject];
    
    if (currentUser.objectId != nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *description = [NSEntityDescription entityForName:ITBNewsEntityName inManagedObjectContext:context];
        
        [fetchRequest setEntity:description];
        
        NSString *descriptorKey;
        
        NSPredicate *predicate;
        
        if ([currentUser.selectedCategories count] != 0) {
            
            predicate = [NSPredicate predicateWithFormat:@"category IN %@", currentUser.selectedCategories];
            
        } else {
            
            predicate = [NSPredicate predicateWithFormat:@"category.title == %@", nothingPredicateFormat];
        }
        
        switch (self.chosenSortingType) {
                
            case ITBSortingTypeHot:
                descriptorKey = frcRatingDescriptorKey;
                break;
                
            case ITBSortingTypeNew:
                descriptorKey = createdAtDescriptorKey;
                break;
                
            case ITBSortingTypeCreated: {
                descriptorKey = titleDescriptorKey;
                
                if ([currentUser.selectedCategories count] != 0) {
                    
                    predicate = [NSPredicate predicateWithFormat:@"(category IN %@) AND (author.objectId == %@)", currentUser.selectedCategories, currentUser.objectId];
                    
                } else {
                    
                    predicate = [NSPredicate predicateWithFormat:@"(category.title == %@) AND (author.objectId == %@)", nothingPredicateFormat, currentUser.objectId];
                    
                }
                break;
            }
                
            case ITBSortingTypeFavourites: {
                descriptorKey = titleDescriptorKey;
                
                if ([currentUser.favouriteNews count] != 0) {
                    
                    predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", currentUser.favouriteNews];
                    
                } else {
                    
                    predicate = [NSPredicate predicateWithFormat:@"objectId == %@", nothingPredicateFormat];
                    
                }
                break;
            }
                
            case ITBSortingTypeGeolocation:
                descriptorKey = titleDescriptorKey;
                
                if ([currentUser.selectedCategories count] != 0) {
                    
                    predicate = [NSPredicate predicateWithFormat:@"(category IN %@) AND (isValidByGeolocation != %@)", currentUser.selectedCategories, @0];
                    
                } else {
                    
                    predicate = [NSPredicate predicateWithFormat:@"(category.title == %@) AND (isValidByGeolocation != %@)", nothingPredicateFormat, @0];
                    
                }
                break;
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:descriptorKey ascending:NO];
        
        if (self.chosenSortingType == ITBSortingTypeHot) {
            
            NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:titleDescriptorKey ascending:NO];
            [fetchRequest setSortDescriptors:@[descriptor, titleDescriptor]];
            
        } else {
            
            [fetchRequest setSortDescriptors:@[descriptor]];
        }
        
        [fetchRequest setPredicate:predicate];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        
        aFetchedResultsController.delegate = self;
        
        self.fetchedResultsController = aFetchedResultsController;
        
        NSError *error = nil;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            
            NSLog(@"%@ %@, %@", errorMessage, error, [error userInfo]);
        }
        
        return _fetchedResultsController;
    }
    
    return nil;
}

#pragma mark - Private

- (void)getNewsCellForSender:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSPredicate *newsPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", newsItem.objectId];
    NSArray *news = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:newsPredicate];
    newsItem = [news firstObject];
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", [ITBNewsAPI sharedInstance].currentUser.objectId];
    NSArray *users = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBUserEntityName withSortDescriptors:nil predicate:userPredicate];
    ITBUser *currentUser = [users firstObject];

    BOOL isLikedByCurrentUser = [newsItem.isLikedByCurrentUser boolValue];
    
    NSInteger ratingInt = [newsItem.rating integerValue];
    
    if (isLikedByCurrentUser) {
        
        [newsItem removeLikeAddedUsersObject:currentUser];
        --ratingInt;
        newsItem.isLikedByCurrentUser = @0;
        
    } else {
        
        [newsItem addLikeAddedUsersObject:currentUser];
        ++ratingInt;
        newsItem.isLikedByCurrentUser = @1;
        
    }
    
    newsItem.rating = [NSNumber numberWithInteger:ratingInt];
    
    [[ITBNewsAPI sharedInstance] saveBgContext];
    
}

- (void)refreshNews {
    
    if (self.refreshButton.enabled) {
        
        __weak ITBHotNewsViewController *weakSelf = self;
        
        NSArray *allLocalNews = [[ITBNewsAPI sharedInstance] fetchObjectsForEntity:ITBNewsEntityName usingContext:[ITBNewsAPI sharedInstance].mainManagedObjectContext];
        
        [[ITBNewsAPI sharedInstance] checkNetworkConnectionOnSuccess:^(BOOL isConnected) {
            
            if (isConnected) {
                
                if ([allLocalNews count] > 0) {
                    
                    [[ITBNewsAPI sharedInstance] updateCurrentUserFromLocalToServerOnSuccess:^(BOOL isSuccess) {
                        
                        if (isSuccess) {
                            
                            [[ITBNewsAPI sharedInstance] updateLocalDataSourceOnSuccess:^(BOOL isSuccess) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [weakSelf prefetchValidByGeolocationNews];
                                    
                                    weakSelf.fetchedResultsController = nil;
                                    [weakSelf.tableView reloadData];
                                    
                                    weakSelf.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
                                    [weakSelf.refreshControl endRefreshing];
                                    
                                });
                            }];
                        }
                        
                    }];
                    
                    
                } else {
                    
                    [[ITBNewsAPI sharedInstance] createLocalDataSourceOnSuccess:^(BOOL isSuccess) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self prefetchValidByGeolocationNews];
                            
                            self.fetchedResultsController = nil;
                            [self.tableView reloadData];
                            
                            self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
                            [self.refreshControl endRefreshing];
                        });
                    }];
                }
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
                    [self.refreshControl endRefreshing];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:noConnectionTitle message:noConnectionMessage preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:okAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                });
            }
            
        }];
        
    } else {
        
        [self.refreshControl endRefreshing];
    }
}

- (void)prefetchValidByGeolocationNews {
    
    self.newsByGeolocationArray = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *latNumber = [userDefaults objectForKey:kSettingsLatitude];
    NSNumber *longNumber = [userDefaults objectForKey:kSettingsLongitude];
    
    CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:[latNumber doubleValue] longitude:[longNumber doubleValue]];
    
    for (ITBNews *newsItem in self.newsByGeolocationArray) {
        
        CLLocation *newsItemLocation = [[CLLocation alloc] initWithLatitude:[newsItem.latitude doubleValue] longitude:[newsItem.longitude doubleValue]];
        
        CLLocationDistance distance = [newsItemLocation distanceFromLocation:currentUserLocation];
        
        BOOL isValid = (distance <= maxDistance) ? YES : NO;
        newsItem.isValidByGeolocation = [NSNumber numberWithBool:isValid];
    }
    
    [[ITBNewsAPI sharedInstance] saveBgContext];
    
}

- (void)hideSharingButtons {
    
    NSArray *news = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:nil];
    
    for (ITBNews *newsItem in news) {
        newsItem.isTitlePressed = @0;
    }
    
    [[ITBNewsAPI sharedInstance] saveBgContext];
    
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
        
    } else if ([identifier isEqualToString:showNewsPageSegueId]) {
        
        if (self.newsItemForDetailPage.newsURL == nil) {
            
            return NO;
            
        }
        
    } else if ([identifier isEqualToString:showCustomNewsPageSegueId]) {
        
        if (self.newsItemForDetailPage.newsURL != nil) {
            
            return NO;
            
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:loginSegueId]) {
        
        ITBLoginTableViewController *loginVC = [segue destinationViewController];
        loginVC.delegate = self;
        
    } else if ([[segue identifier] isEqualToString:chooseCategoriesSegueId]) {
        
        ITBCategoriesViewController *categoriesVC = [segue destinationViewController];
        categoriesVC.delegate = self;
        
    } else if ([[segue identifier] isEqualToString:showNewsPageSegueId]) {
        
        if (self.newsItemForDetailPage.newsURL != nil) {
            
            ITBNewsDetailViewController *newsDetailVC = [segue destinationViewController];
            
            NSURL *url = [NSURL URLWithString:self.newsItemForDetailPage.newsURL];
            
            newsDetailVC.title = self.newsItemForDetailPage.title;
            newsDetailVC.url = url;
            
        }
    } else if ([[segue identifier] isEqualToString:showCustomNewsPageSegueId]) {
        
        if (self.newsItemForDetailPage.newsURL == nil) {
            
            ITBCustomNewsDetailViewController *customNewsDetailVC = [segue destinationViewController];
            customNewsDetailVC.delegate = self;
            
        }
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
        
        BOOL isTitlePressed = [newsItem.isTitlePressed boolValue];
        
        if (isTitlePressed) {
            
            ITBActiveNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ITBActiveNewsCellReuseIdentifier];
            
            cell.activeDelegate = self;
            
            [self configureActiveCell:cell atIndexPath:indexPath];
            
            return cell;
        
        } else {
            
            ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ITBNewsCellReuseIdentifier];
            
            cell.delegate = self;
            
            [self configureCell:cell atIndexPath:indexPath];
            
            return cell;
        }
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataReuseIdentifier];
        
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
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        BOOL saved = [context save:&error];
        
        if (!saved) {
            
            NSLog(@"%@ %@\n%@", contextSavingError, [error localizedDescription], [error userInfo]);
        }
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
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    self.loginButton.title = logoutTitleOfLoginButton;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        self.categoriesPickerButton.enabled = YES;
        self.refreshButton.enabled = YES;
        self.addNewsButton.enabled = YES;
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC withSortingType:(NSInteger)sortingType sortingName:(NSString *)sortingName {
    
    [self hideSharingButtons];
    
    self.chosenSortingType = (int)sortingType;
    self.title = sortingName;
    
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
}

#pragma mark - ITBNewsCellDelegate

- (void)newsCellDidTapAdd:(UITableViewCell *)cell {
    
    [self getNewsCellForSender:cell];
 
}

- (void)newsCellDidTapSubtract:(UITableViewCell *)cell {
    
    [self getNewsCellForSender:cell];
    
}

- (void)newsCellDidTapDetail:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    self.newsItemForDetailPage = newsItem;
    
    if (self.newsItemForDetailPage.newsURL != nil) {
        
        [self performSegueWithIdentifier:showNewsPageSegueId sender:cell];
        
    } else {
        
        [self performSegueWithIdentifier:showCustomNewsPageSegueId sender:cell];
        
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
    
    NSPredicate *newsPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", newsItem.objectId];
    NSArray *news = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:newsPredicate];
    newsItem = [news firstObject];
    
    ITBUser *currentUser = [ITBNewsAPI sharedInstance].currentUser;
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", currentUser.objectId];
    NSArray *users = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBUserEntityName withSortDescriptors:nil predicate:userPredicate];
    currentUser = [users firstObject];
    
    if (![currentUser.favouriteNews containsObject:newsItem]) {
        
        [currentUser addFavouriteNewsObject:newsItem];
        
        [[ITBNewsAPI sharedInstance] saveBgContext];
        
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
    
    return self.newsItemForDetailPage;
}

#pragma mark - IBActions

- (IBAction)actionRefresh:(UIBarButtonItem *)sender {

    [self.refreshControl beginRefreshing];
    self.tableView.contentOffset = CGPointMake(0.f, -120.f);
    
    [self refreshNews];
}

@end
