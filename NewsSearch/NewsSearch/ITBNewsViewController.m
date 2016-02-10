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

#pragma mark - API

- (void)getNewsFromServer {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
         self.newsArray = news;
         
         for (ITBNews* newsItem in news) {
             
             [self.categoriesSet addObject:newsItem.category];
         }
         
         [self.tableView reloadData];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

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

#pragma mark - Table view data source

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
        
        cell.ratingLabel.text = [NSString stringWithFormat:@"%@", news.rating];
        
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

@end
