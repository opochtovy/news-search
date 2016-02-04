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

@interface ITBNewsViewController ()

@property (strong, nonatomic) NSArray *newsArray;

// эта property вместо метода -initWithCompletionBlock:
@property (copy, nonatomic) ITBLoginCompletionBlock completionBlock;

@end

@implementation ITBNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsArray = [NSArray array];
    
    self.title = @"NEWS";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"login"]) {
        
        ITBLoginViewController *loginVC = (ITBLoginViewController *) [segue destinationViewController];
    }
    
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"login"])
    {
        // Get reference to the destination view controller
        UINavigationController *loginNavVC = [segue destinationViewController];
        ITBLoginViewController* loginVC = (ITBLoginViewController* )loginNavVC.topViewController;
        
        // Pass any objects to the view controller here, like...
//        [loginVC setCompletionBlock:self.completionBlock];
/*
        [[ITBServerManager sharedManager] authorizeUserForLogin:loginVC
                                                      onSuccess:^(ITBUser *user) {
            NSLog(@"TADA!!! AUTHORIZED!");
            
//            NSLog(@"%@ %@", user.firstName, user.lastName);
        }
                                              onFailure:^(NSError *error, NSInteger statusCode)
        {
        
        }];
*/
        
        // Code below is for signing up a new user
        [[ITBServerManager sharedManager]
         postUserOnSuccess:^(ITBUser *user)
        {
            NSLog(@"TADA!!! USER WAS CREATED!");
        }
         onFailure:^(NSError *error, NSInteger statusCode)
        {
        
        }];

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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *identifier;
    
    UITableViewCell *cell;
    
    if (self.isLogin) {
        
        identifier = @"NewsCell";
        
    } else {
        
        identifier = @"NoLoginCell";
        
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (self.isLogin) {
        
        ITBNews *news = [self.newsArray objectAtIndex:indexPath.row];
//        cell.textLabel.text = news.
        
    } else {
        
        cell.textLabel.text = @"You need to login for using our news network!";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLogin) {
        
        return 88.0;
        
    } else {
        
        return 44.0;
        
    }
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

@end
