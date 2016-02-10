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

@interface ITBNewsViewController () <ITBLoginTableViewControllerDelegate>

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
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if (self.isLogin) {
        
        [self.tableView reloadData];
        
        [self getNewsFromServer];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (ITBNews* ) getNewsCellForSender:(UIButton* )sender {
    
    UIView* parentView;
    
    UIView* childView = sender;
    
    while (![parentView isKindOfClass:[ITBNewsCell class]]) {
        
        parentView = childView.superview;
        
        childView = parentView;
    }
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(ITBNewsCell* )parentView];
    
    ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
    
    return news;
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

- (void)updateNewsObject:(NSString* ) objectId
              withFields:(NSDictionary* ) parameters
            forUrlString:(NSString* ) urlString {
    
    [[ITBServerManager sharedManager] updateObject:objectId
                                        withFields:parameters
                                      forUrlString:urlString
                                         onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS !!! ");
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

    if (self.isLogin) {
        
        static NSString *identifier = @"NewsCell";
        
        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = news.title;
        
        cell.categoryLabel.text = news.category;
        
//        cell.ratingLabel.text = [NSString stringWithFormat:@"%@", news.rating];
        cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[news.likedUsers count]];
        
        if (news.isLikedByCurrentUser) {
            
            cell.addLikeButton.enabled = NO;
            cell.subtractLikeButton.enabled = YES;
            
        } else {
            
            cell.addLikeButton.enabled = YES;
            cell.subtractLikeButton.enabled = NO;
            
        }
        
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

#pragma mark - Actions

- (IBAction)actionAddLike:(UIButton *)sender {
    
    ITBNews* news = [self getNewsCellForSender:sender];
    
    NSLog(@"news.title = %@", news.title);
    
    NSMutableArray* updatedLikedUsers;
    
    if ([news.likedUsers count]) {
        
        updatedLikedUsers = [news.likedUsers mutableCopy];
        
    } else {

        updatedLikedUsers = [NSMutableArray array];
    }
    
    [updatedLikedUsers addObject:self.currentUser.objectId];
    
    news.isLikedByCurrentUser = YES;

    news.likedUsers = [updatedLikedUsers copy];
    
    [self.tableView reloadData];
    
    // осталось отправить на сервер новый news.likedUsers
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", news.objectId];
    
    NSDictionary *parameters = @{ @"likedUsers": @{ @"__op": @"AddUnique", @"objects": @[ self.currentUser.objectId ] } };

    [self updateNewsObject:news.objectId
                withFields:parameters
              forUrlString:urlString];

}

- (IBAction)actionSubtractLike:(UIButton *)sender {
    
    ITBNews* news = [self getNewsCellForSender:sender];
    
    NSMutableArray* updatedLikedUsers;
    
    if ([news.likedUsers count]) {
        
        updatedLikedUsers = [news.likedUsers mutableCopy];
        
    } else {
        
        updatedLikedUsers = [NSMutableArray array]; // я здесь оставляю чтобы это подходило для обоих методов (addLike and subtractLike)
    }
    
//    ITBUser* currentUser = [ITBServerManager sharedManager].currentUser;
    
    [updatedLikedUsers removeObject:self.currentUser.objectId];
    
    news.isLikedByCurrentUser = NO;
    
    news.likedUsers = [updatedLikedUsers copy];
    
    [self.tableView reloadData];
    
    // осталось отправить на сервер новый news.likedUsers
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", news.objectId];
    
    // change 3
    NSDictionary *parameters = @{ @"likedUsers": @{ @"__op": @"Remove", @"objects": @[ self.currentUser.objectId ] } };
    
    [self updateNewsObject:news.objectId
                withFields:parameters
              forUrlString:urlString];
    
    
}


@end
