//
//  ITBNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsViewController.h"

#import "ITBServerManager.h"

#import "ITBLoginViewController.h"

#import "ITBNews.h"
#import "ITBUser.h"

#import "ITBNewsCell.h"

@interface ITBNewsViewController () <ITBLoginViewControllerDelegate>

//@property (strong, nonatomic) NSMutableArray *newsArray;
@property (strong, nonatomic) NSArray *newsArray;

@property (strong, nonatomic) NSMutableSet *categoriesSet;

@end

@implementation ITBNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.newsArray = [NSMutableArray array];
    self.newsArray = [NSArray array];
    
    self.categoriesSet = [NSMutableSet set];
    
    self.title = @"NEWS";
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([ITBServerManager sharedManager].currentUser.sessionToken) {
        
        [self getNewsFromServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)getNewsFromServer {
    
    // 12.3
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
//         [self.newsArray addObjectsFromArray:news];
         self.newsArray = news;
         
         for (ITBNews* newsItem in news) {
             
             [self.categoriesSet addObject:newsItem.category];
         }
         
#warning ? - вопрос Жене - не получается удалить cell c другим identifier при получении массива новостей - точнее удаление старой ячейки с идентификатором noData
         
         [self.tableView reloadData];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"login"])
    {
        
        UINavigationController *loginNavVC = [segue destinationViewController];
        ITBLoginViewController* loginVC = (ITBLoginViewController* )loginNavVC.topViewController;
        
        loginVC.delegate = self;
        
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.newsArray count]) {
        
        return [self.newsArray count];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
/*
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 if (!cell) {
 
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
 }
*/


    if ([self.newsArray count]) {
        
        static NSString *identifier = @"NewsCell";
        
        ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
        
        // that method sets all needed frames for my outlets depending of current newsItem for this cell
        [cell countFramesForNews:news];
        
        cell.titleLabel.text = news.title;
//        cell.titleLabel.textAlignment = NSTextAlignmentJustified;
        
        cell.categoryLabel.text = news.category;
        
        cell.ratingLabel.text = [NSString stringWithFormat:@"%@", news.rating];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell;
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noData"];
        
        cell.textLabel.text = @"You need to login for using our news network!";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.newsArray count]) {
        
//        return 88.0;
        
        // that method counts current cell height depending of current newsItem for this cell
        ITBNews *news = [self.newsArray objectAtIndex:indexPath.row];
        
        return [ITBNewsCell heightForNews:news];
        
        
    } else {
        
        return 44.0;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ITBLoginViewControllerDelegate

- (void)changeTitleForLoginButton:(ITBLoginViewController *)vc {
    
    self.loginButton.title = @"Logout";
    
    self.loginButton.enabled = NO;
}

@end
