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
#import "ITBUserCD.h"

#import "ITBUser.h"

#import "ITBLoginTableViewController.h"

//NSString *const login = @"Login";
//NSString *const logout = @"Logout";
NSString *const hotNewsTitle = @"HOT NEWS";
//NSString *const beforeLogin = @"You need to login for using our news network!";


//static NSString *const kSettingsUsernameCD = @"username";
//static NSString *const kSettingsObjectIdCD = @"objectId";

@interface ITBHotNewsViewController () <ITBLoginTableViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

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
    // Do any additional setup after loading the view.
    
//    self.navigationItem.title = @"Hot news";
    self.title = NSLocalizedString(hotNewsTitle, nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 400.0;

    ITBServerManager* serverManager = [ITBServerManager sharedManager];
    [serverManager loadSettings];

    if (serverManager.currentUser.sessionToken != nil) {
        
        NSLog(@"username != 0 -> загружаются новости из локальной БД");
        
        ITBDataManager* dataManager = [ITBDataManager sharedManager];
        
//        [dataManager fetchCurrentUser];
        [dataManager fetchCurrentUserForObjectId:serverManager.currentUser.objectId];
        
        self.categoriesPickerButton.enabled = YES;
        self.refreshButton.enabled = YES;
        
        self.loginButton.title = @"Logout";
        
    } else {
        
        self.categoriesPickerButton.enabled = NO;
        self.refreshButton.enabled = NO;
        
        self.loginButton.title = @"Login";
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// пока мне вообще не нужен этот метод добавления нового объекта (т.е. новости)
- (void)insertNewObject:(id)sender {
    /*
     NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
     
     NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
     
     NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
     
     // If appropriate, configure the new managed object.
     // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
     [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
     
     // Save the context.
     NSError *error = nil;
     if (![context save:&error]) {
     // Replace this implementation with code to handle the error appropriately.
     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
     */
}

#pragma mark - UIViewController methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
    if ([self.loginButton.title isEqualToString:@"Logout"]) {
        
        self.loginButton.title = @"Login";
//        self.loginButton.title = NSLocalizedString(login, nil);
        
//        self.isLogin = NO;
        
//        self.newsArray = nil;
        ITBServerManager* serverManager = [ITBServerManager sharedManager];
        serverManager.currentUser = nil;
        
        // here I initialize a property currentUserCD of ITBDataManager
        ITBDataManager* dataManager = [ITBDataManager sharedManager];
//        [dataManager fetchCurrentUser]; // проще написать строку ниже
        dataManager.currentUserCD = nil;
        
        // ([ITBServerManager sharedManager].currentUser != nil)
        self.categoriesPickerButton.enabled = (serverManager.currentUser != nil);
        self.refreshButton.enabled = (serverManager.currentUser != nil);
        
//        self.currentUser = nil;
        
        [serverManager saveSettings];
        
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
    
    ITBUserCD* user = [ITBDataManager sharedManager].currentUserCD;
    
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
        
        //    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"university == %@", self.university];
        //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses contains %@", self.course];
        
//    ITBUserCD* user = [ITBDataManager sharedManager].currentUserCD;
        NSLog(@"[user.selectedCategories count] = %ld", [user.selectedCategories count]);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category IN %@", user.selectedCategories];
        [fetchRequest setPredicate:predicate];
        
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
    
    // numberOfSectionsInTableView
//    return [[self.fetchedResultsController sections] count];
    
    // numberOfRowsInSection
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //    return [[self.fetchedResultsController sections] count];
    
    if ([ITBServerManager sharedManager].currentUser != nil) {
        
        return [[self.fetchedResultsController sections] count];
    } else {
        
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //    return [sectionInfo numberOfObjects];
    
    if ([ITBServerManager sharedManager].currentUser != nil) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
        
    } else {
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath]; // этот метод используется при работе со сториборд
     */
    /*
     // не буду использовать сториборд а использую базовые ячейки
     static NSString *identifier = @"Cell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     
     if (!cell) {
     
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
     
     }
     
     [self configureCell:cell atIndexPath:indexPath];
     
     return cell;
     */
    
    if ([ITBServerManager sharedManager].currentUser != nil) {
        
        static NSString *identifier = @"NewsCell";
        /*
         ITBNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
         
         cell.delegate = self;
         
         ITBNews* news = [self.newsArray objectAtIndex:indexPath.row];
         
         cell.titleLabel.text = news.title;
         
         cell.categoryLabel.text = news.category;
         
         cell.ratingLabel.text = [NSString stringWithFormat:@"%ld", (long)[news.likedUsers count]];
         
         cell.addLikeButton.enabled = !news.isLikedByCurrentUser;
         cell.subtractLikeButton.enabled = news.isLikedByCurrentUser;
         */
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noData"];
        
        cell.textLabel.text = @"You need to login for using our news network!";
        //        cell.textLabel.text = NSLocalizedString(beforeLogin, nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        return cell;
        
    }
}

//# warning 7 - у меня должна идти custom cell а не UITableViewCell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ITBNewsCD *newsItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = newsItem.title;
    //    cell.detailTextLabel.text = nil;
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

- (void) loginDidPassSuccessful:(ITBLoginTableViewController *)vc {
    
    self.loginButton.title = @"Logout";
    
//    self.isLogin = YES;
    
//    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.categoriesPickerButton.enabled = ([ITBServerManager sharedManager].currentUser != nil);
        self.refreshButton.enabled = ([ITBServerManager sharedManager].currentUser != nil);
        
        [self.tableView reloadData];
        
    });
    
//    self.managedObjectContext;
    
    //        [self getNewsFromServer];
    
    
//    [self getNewsFromServerByCategories];
    
}

#pragma mark - Actions

- (IBAction)actionChooseCategories:(UIBarButtonItem *)sender {
}
@end
