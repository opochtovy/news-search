//
//  ITBNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsViewController.h"

#import "ITBServerManager.h"

#import "ITBLoginTableViewController.h"

#import "ITBNews.h"
#import "ITBUser.h"

#import "ITBNewsCell.h"

#import "ITBCategoriesViewController.h"

@interface ITBNewsViewController () <ITBLoginTableViewControllerDelegate, ITBCategoriesPickerDelegate>

@property (strong, nonatomic) NSArray *newsArray;

@property (strong, nonatomic) NSMutableSet *categoriesSet;

@property (assign, nonatomic) BOOL isLogin;

@property (strong, nonatomic) NSArray *buttonsArray;

@property (strong, nonatomic) ITBUser *currentUser;

@end

@implementation ITBNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsArray = [NSArray array];
    
    self.categoriesSet = [NSMutableSet set];
    
    self.title = @"NEWS";
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0;
    
    self.categoriesPickerButton.enabled = self.isLogin;
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if (self.isLogin) {
        
        [self.tableView reloadData];
        
//        [self getNewsFromServer];
        [self getNewsFromServerByCategories];
        
    }
    
    self.categoriesPickerButton.enabled = self.isLogin;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void) getNewsCellForSender:(UIButton* )sender {
    
    UIView* parentView;
    
    UIView* childView = sender;
    
    while (![parentView isKindOfClass:[ITBNewsCell class]]) {
        
        parentView = childView.superview;
        
        childView = parentView;
    }
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(ITBNewsCell* )parentView];
    
    ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
    
    NSMutableArray* updatedLikedUsers;
    
    if ([news.likedUsers count]) {
        
        updatedLikedUsers = [news.likedUsers mutableCopy];
        
    } else {
        
        updatedLikedUsers = [NSMutableArray array];
    }
    
    if (news.isLikedByCurrentUser) {
        
        [updatedLikedUsers removeObject:self.currentUser.objectId];
        
//        news.isLikedByCurrentUser = NO;
        
    } else {
        
        [updatedLikedUsers addObject:self.currentUser.objectId];
        
//        news.isLikedByCurrentUser = YES;
        
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

- (void)getNewsFromServer {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
         self.currentUser = [ITBServerManager sharedManager].currentUser;
         
         self.newsArray = news;
         
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

- (void)getNewsFromServerByCategories {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
         self.currentUser = [ITBServerManager sharedManager].currentUser;
         
//         self.newsArray = news;
         
         NSMutableArray* choosedNews = [NSMutableArray array];
         
         for (NSString* category in self.currentUser.categories) {
             
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
    
    if ([self.loginButton.title isEqualToString:@"Logout"]) {
        
        self.loginButton.title = @"Login";
        
        self.isLogin = NO;
        
        self.newsArray = nil;
        
        self.categoriesPickerButton.enabled = self.isLogin;
        
        self.currentUser = nil;
        
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
    
    if ([self.newsArray count]) {
        static NSString *identifier = @"NewsCell";
        
        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = news.title;
        
        cell.categoryLabel.text = news.category;
        
        cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[news.likedUsers count]];
        
        cell.addLikeButton.enabled = !news.isLikedByCurrentUser;
        cell.subtractLikeButton.enabled = news.isLikedByCurrentUser;
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noData"];
        
        cell.textLabel.text = @"You need to login for using our news network!";
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
- (void)changeTitleForLoginButton:(ITBLoginTableViewController *)vc {
    
    self.loginButton.title = @"Logout";
    
    self.isLogin = YES;
    
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

#pragma mark - Actions

- (IBAction)actionAddLike:(UIButton *)sender {
    
    [self getNewsCellForSender:sender];
}

- (IBAction)actionSubtractLike:(UIButton *)sender {
    
    [self getNewsCellForSender:sender];
}

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
    
    ITBCategoriesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ITBCategoriesViewController"];
    
    NSLog(@"[self.currentUser.categories count] = %ld", (long)[self.currentUser.categories count]);
    
    vc.allCategoriesArray = [self.categoriesSet allObjects];
    vc.categoriesOfCurrentUserArray = self.currentUser.categories;
    
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (!sender) {
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
