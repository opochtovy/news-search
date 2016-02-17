//
//  ITBNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsViewController.h"

#import "ITBServerManager.h"
#import "ITBDataManager.h"

#import "ITBLoginTableViewController.h"

#import "ITBNews.h"
#import "ITBUser.h"

#import "ITBNewsCell.h"

#import "ITBCategoriesViewController.h"

#import "ITBNewsDetailViewController.h"

NSString *const login = @"Login";
NSString *const logout = @"Logout";
NSString *const newsTitle = @"NEWS";
NSString *const beforeLogin = @"You need to login for using our news network!";

@interface ITBNewsViewController () <ITBLoginTableViewControllerDelegate, ITBCategoriesPickerDelegate, ITBNewsCellDelegate>

@property (strong, nonatomic) NSArray *newsArray;

@property (strong, nonatomic) NSMutableSet *categoriesSet;

@property (assign, nonatomic) BOOL isLogin;

@property (strong, nonatomic) NSArray *buttonsArray;

@property (strong, nonatomic) ITBUser *currentUser;

@end

@implementation ITBNewsViewController

- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        
        _managedObjectContext = [[ITBDataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsArray = [NSArray array];
    
    self.categoriesSet = [NSMutableSet set];
    
    self.currentUser = [[ITBUser alloc] init];
    
//    self.title = newsTitle;
    self.title = NSLocalizedString(newsTitle, nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0;
    
    self.categoriesPickerButton.enabled = self.isLogin;
   
    ITBServerManager* manager = [ITBServerManager sharedManager];
    [manager loadSettings];
    
    if (manager.currentUser.sessionToken != nil) {
        
        NSLog(@"username != 0 -> загружаются новости из локальной БД");
        
        ITBDataManager* dataManager = [ITBDataManager sharedManager];
        
        // here I initialize a property currentUserCD of ITBDataManager
        [dataManager fetchCurrentUserForObjectId:manager.currentUser.objectId];
        
//        [dataManager printAllObjects];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void) getNewsCellForSender:(ITBNewsCell* ) cell {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
    
    NSMutableArray* updatedLikedUsers;
    
    if ([news.likedUsers count] != 0) {
        
        updatedLikedUsers = [news.likedUsers mutableCopy];
        
    } else {
        
        updatedLikedUsers = [NSMutableArray array];
    }
    
    if (news.isLikedByCurrentUser) {
        
        [updatedLikedUsers removeObject:self.currentUser.objectId];
        
    } else {
        
        [updatedLikedUsers addObject:self.currentUser.objectId];
        
    }
    
    news.likedUsers = [updatedLikedUsers copy];
    
    news.isLikedByCurrentUser = !news.isLikedByCurrentUser;
    
//    [self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    // осталось отправить на сервер новый news.likedUsers
    [self updateRatingForNewsItem:news];
    
}

#pragma mark - API

- (void) getCurrentUserFromServer {

    [[ITBDataManager sharedManager] addCurrentUserToLocalDB];
    
}

- (void)getCategoriesFromServer {
    
    [[ITBServerManager sharedManager]
     getCategoriesOnSuccess:^(NSArray *categories) {
         
         [[ITBDataManager sharedManager] addCategoriesToLocalDBFromLoadedArray:categories];
        
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

- (void)getNewsFromServer {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
         [[ITBDataManager sharedManager] addNewsToLocalDBFromLoadedArray:news];
         
//         [self.tableView reloadData];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self.tableView reloadData];
             
         });
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

- (void)getNewsFromServerByCategories {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
//         self.currentUser = [ITBServerManager sharedManager].currentUser;
         
//         self.newsArray = news;
         
         NSMutableArray* choosedNews = [NSMutableArray array];
         
         for (NSString* category in [ITBServerManager sharedManager].currentUser.categories) {
             
             for (ITBNews* newsItem in news) {
                 
                 if ([category isEqualToString:newsItem.category]) {
                     
                     [choosedNews addObject:newsItem];
                 }
             }
         }
         
         self.newsArray = [choosedNews copy];
         
         for (ITBNews* newsItem in news) {
             
             [self.categoriesSet addObject:newsItem.category];
             
             if ([newsItem.likedUsers containsObject:self.currentUser.objectId]) {
                 
                 newsItem.isLikedByCurrentUser = YES;
             }
             
         }
         
//         [self.tableView reloadData];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self.tableView reloadData];
             
         });
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

- (void) updateRatingForNewsItem:(ITBNews* ) news {
    
    [[ITBServerManager sharedManager]
     updateRatingFromUserForNewsItem: news
     onSuccess:^(NSDate *updatedAt)
     {
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
}

- (void) updateCategories {
    
    [[ITBServerManager sharedManager]
     updateCategoriesFromUserOnSuccess:^(NSDate *updatedAt)
     {
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
}

#pragma mark - UIViewController methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
//    if ([self.loginButton.title isEqualToString:logout]) {
    
    if ([self.loginButton.title isEqualToString:NSLocalizedString(logout, nil)]) {
        
//        self.loginButton.title = login;
        self.loginButton.title = NSLocalizedString(login, nil);
        
        self.isLogin = NO;
        
        self.newsArray = nil;
        
        self.categoriesPickerButton.enabled = self.isLogin;
        
        self.currentUser = nil;
        
        ITBServerManager* serverManager = [ITBServerManager sharedManager];
        
        serverManager.currentUser = nil;
        [serverManager saveSettings];
//        [self saveSettings];
        
        
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isLogin) {
        
        return [self.newsArray count];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.newsArray count] != 0) {
        
        static NSString *identifier = @"NewsCell";
        
        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.delegate = self;
        
        ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = news.title;
        
        cell.categoryLabel.text = news.category;
        
        cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[news.likedUsers count]];
        
        cell.addLikeButton.enabled = !news.isLikedByCurrentUser;
        cell.subtractLikeButton.enabled = news.isLikedByCurrentUser;
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noData"];
        
//        cell.textLabel.text = beforeLogin;
        cell.textLabel.text = NSLocalizedString(beforeLogin, nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ITBLoginTableViewControllerDelegate

- (void) loginDidPassSuccessful:(ITBLoginTableViewController *)vc {
    
    self.loginButton.title = NSLocalizedString(logout, nil);
    
    self.isLogin = YES;
    
    [self.tableView reloadData];
    
//        [self getNewsFromServer];
    [self getNewsFromServerByCategories];
    
    
}

#pragma mark - ITBCategoriesPickerDelegate

- (void)reloadCategoriesFrom:(ITBCategoriesViewController *)categoriesVC {
    
    self.currentUser.categories = categoriesVC.categoriesOfCurrentUserArray;
    
    [self.tableView reloadData];
    
    // осталось отправить на сервер новый self.currentUser.categories
    [self updateCategories];
    
    // вызов этого метода нужен чтобы обновить список новостей в соответствии с выбранными категориями
    [self getNewsFromServerByCategories];
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
    
    ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
    
    newsDetailVC.title = news.title;
    
    NSURL *url = [NSURL URLWithString: news.newsURL];
    newsDetailVC.url = url;
    
    [self.navigationController pushViewController:newsDetailVC animated:YES];
    
    
}

#pragma mark - Actions

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
    
    ITBCategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCategoriesViewController"];
    
//    NSLog(@"[self.currentUser.categories count] = %ld", (long)[self.currentUser.categories count]);
    
    vc.allCategoriesArray = [self.categoriesSet allObjects];
    vc.categoriesOfCurrentUserArray = self.currentUser.categories;
    
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

@end
