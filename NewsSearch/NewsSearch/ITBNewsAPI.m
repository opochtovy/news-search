//
//  ITBNewsAPI.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI.h"

#import <UIKit/UIKit.h>

#import "ITBRestClient.h"
#import "ITBCoreDataManager.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"

NSString *const login = @"Login";
NSString *const logout = @"Logout";
NSString *const beforeLogin = @"You need to login for using our news network!";

static NSString *const kSettingsUsername = @"username";
static NSString *const kSettingsObjectId = @"objectId";
static NSString *const kSettingsSessionToken = @"sessionToken";

@interface ITBNewsAPI ()

@property (strong, nonatomic) ITBRestClient* restClient;
@property (strong, nonatomic) ITBCoreDataManager* coreDataManager;

@end

@implementation ITBNewsAPI

+ (ITBNewsAPI *)sharedInstance
{
    static ITBNewsAPI *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ITBNewsAPI alloc] init];
        
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        
        self.restClient = [[ITBRestClient alloc] init];
        
        self.coreDataManager = [[ITBCoreDataManager alloc] init];
        
        [self loadCurrentUser];
        
    }
    return self;
}

 #pragma mark - NSUserDefaults
 
- (void)saveCurrentUser {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.currentUser.username forKey:kSettingsUsername];
    [userDefaults setObject:self.currentUser.objectId forKey:kSettingsObjectId];
    [userDefaults setObject:self.currentUser.sessionToken forKey:kSettingsSessionToken];
    
    [userDefaults synchronize];
    
}
 
- (void)loadCurrentUser {
 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString* objectId = [userDefaults objectForKey:kSettingsObjectId];
    
    NSLog(@"username has objectId = %@", objectId);
     
    if (objectId != nil) {
        
        self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:objectId];
    }
 
}

- (void) logOut
{
    self.currentUser = nil;
    
    [self saveCurrentUser];
}
#pragma mark - ITBRestClient

- (void)authorizeWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(ITBUser* user)) success
{
    
    [self.restClient authorizeWithUsername:username
                              withPassword:password
                                 onSuccess:^(NSDictionary *userDict)
    {
        
        ITBUser* user = [[ITBUser alloc] insertObjectWithDictionary:userDict inContext:self.managedObjectContext];
        
        self.currentUser = user;
        
        NSInteger code = [user.code integerValue];
        
        if (code == 0) {
            
            [self saveCurrentUser];
            
            self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:user.objectId];
            
            success(user);
            
        } else {
            
            success(nil);
        }
        
//        success(user);
        
    }
                                 onFailure:^(NSError *error, NSInteger statusCode)
    {
        
    }];
    
}

- (void)registerWithUsername:(NSString* ) username
                withPassword:(NSString* ) password
                   onSuccess:(void(^)(BOOL isSuccess)) success
{
    
    [self.restClient registerWithUsername:username
                             withPassword:password
                                onSuccess:^(NSDictionary *userDict)
    {
        
        NSString* objectId = [userDict objectForKey:@"objectId"];
        
        BOOL isSucces = (objectId == nil) ? NO : YES;
        
        success(isSucces);
        
    }
                                onFailure:^(NSError *error, NSInteger statusCode)
    {
        
    }];
}

- (void)getUsersOnSuccess:(void(^)(NSSet *usernames)) success
{
    
    [self.restClient getUsersOnSuccess:^(NSArray *dicts) {
        
        NSMutableArray *usernamesArray = [NSMutableArray array];
        
        for (NSDictionary *dict in dicts) {
            
            NSString* username = [dict objectForKey:@"username"];
            
            [usernamesArray addObject:username];
        }
        
        NSSet* usernamesSet = [NSSet setWithArray:usernamesArray];
        
        success(usernamesSet);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void)getCategoriesOnSuccess:(void(^)(NSArray *categories)) success
{
    
}

#pragma mark - ITBCoreDataManager

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext == nil) {
        
        _managedObjectContext = [self.coreDataManager managedObjectContext];
    }
    
    return _managedObjectContext;
}

- (void)saveContext {
    
    [self.coreDataManager saveContext];
    
}

- (void)fetchCurrentUserForObjectId:(NSString* ) objectId
{
    
    self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:objectId];
}

- (NSArray* )fetchAllCategories
{
    return [self.coreDataManager fetchAllCategories];
}

#pragma mark - Database creating

- (void) createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.restClient
     getAllObjectsForClassName:@"ITBNews"
     onSuccess:^(NSArray *dicts) {
         
         NSArray* newsDicts = dicts;
         
         NSLog(@"count of newsArray = %li", (long)[newsDicts count]);
         
         NSArray* news = [self.coreDataManager addNewsToLocalDBFromLoadedArray:newsDicts];
//         NSArray* news = [self.coreDataManager allObjectsForName:@"ITBNews"];
         
         [self.restClient
          getAllObjectsForClassName:@"ITBCategory"
          onSuccess:^(NSArray *dicts)
          {
              
              NSArray* categoryDicts = dicts;
              
              NSLog(@"count of categoriesArray = %li", (long)[categoryDicts count]);
              
              NSArray* categories = [self.coreDataManager addCategoriesToLocalDBFromLoadedArray:categoryDicts];
//              NSArray* categories = [self.coreDataManager allObjectsForName:@"ITBCategory"];
              
              [self.restClient
               getCurrentUser:self.currentUser.objectId
               onSuccess:^(NSDictionary *dict)
               {
                   
                   //                   __weak ITBNewsAPI* weakSelf = self;
                   
                   [self.coreDataManager
                    addRelationsToLocalDBFromNewsDictsArray:newsDicts
                    forNewsArray:news
                    fromCategoryDictsArray:categoryDicts
                    forCategoriesArray:categories
                    forUser:self.currentUser
                    onSuccess:^(BOOL isSuccess)
                   {
                        
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        
                        success(isSuccess);
                    }];
                   
               }
               onFailure:^(NSError *error, NSInteger statusCode) { }];
          
          }
          onFailure:^(NSError *error, NSInteger statusCode) { }];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) { }];
    
}

- (void) updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.restClient
     getAllObjectsForClassName:@"ITBNews"
     onSuccess:^(NSArray *dicts)
     {
         NSMutableArray* newsDicts = [dicts mutableCopy];
         
         NSMutableArray* newsArray = [ [self.coreDataManager allObjectsForName:@"ITBNews"] mutableCopy];
         
         NSMutableArray* updatedNews = [NSMutableArray array];
         NSMutableArray* updatedNewsDicts = [NSMutableArray array];
         
         for (int i = [newsDicts count] - 1; i>=0; i--) {
             
             NSDictionary* newsDict = [newsDicts objectAtIndex:i];
             
             for (int j = [newsArray count] - 1; j>=0; j--) {
                 
                 ITBNews* newsItem = [newsArray objectAtIndex:j];
                 
                 if ([newsItem.objectId isEqualToString:[newsDict objectForKey:@"objectId"]]) {
                     
                     [updatedNews addObject:newsItem];
                     [updatedNewsDicts addObject:newsDict];
                     
                     [newsArray removeObject:newsItem];
                     [newsDicts removeObject:newsDict];
                     
                 }
             }
         }
         
         NSMutableArray* deletedNews = newsArray;
         
         NSMutableArray* insertedNewsDicts = newsDicts;
         
         NSLog(@"number of elements in updatedNews = %li", (long)[updatedNews count]);
         NSLog(@"number of elements in updatedNewsDicts = %li", (long)[updatedNewsDicts count]);
         NSLog(@"number of elements in deletedNews = %li", (long)[deletedNews count]);
         NSLog(@"number of elements in insertedNewsDicts = %li", (long)[insertedNewsDicts count]);

         // updating of attributes
         for (NSDictionary* newsDict in updatedNewsDicts) {
             
             ITBNews* newsItem = [updatedNews objectAtIndex:[updatedNewsDicts indexOfObject:newsDict]];
             
             [newsItem updateObjectWithDictionary:newsDict inContext:self.managedObjectContext];
         }
         
         // creating of attributes for inserted news and merge updated and inserted objects (and dicts)
         NSArray* insertedNews = [NSArray array];
         if ([insertedNewsDicts count] > 0) {
             
             insertedNews = [self.coreDataManager addNewsToLocalDBFromLoadedArray:insertedNewsDicts];
             
             for (ITBNews* insertedNewsItem in insertedNews) {
                 
                 [updatedNews addObject:insertedNews];
                 
                 NSInteger indexOfInsertedNewsItem = [insertedNews indexOfObject:insertedNewsItem];
                 
                 [updatedNewsDicts addObject:[insertedNewsDicts objectAtIndex:indexOfInsertedNewsItem]];
             }
         }
         
         // deleting
         if ([deletedNews count] > 0) {
             
             [self.coreDataManager deleteObjectsInArray:deletedNews];
         }
         
         [self.restClient
          getAllObjectsForClassName:@"ITBCategory"
          onSuccess:^(NSArray *dicts)
         {
             NSMutableArray* categoryDicts = [dicts mutableCopy];
             
             NSMutableArray* categoriesArray = [ [self.coreDataManager allObjectsForName:@"ITBCategory"] mutableCopy];
             
             NSMutableArray* updatedCategories = [NSMutableArray array];
             NSMutableArray* updatedCategoryDicts = [NSMutableArray array];
             
             for (int i = [categoryDicts count] - 1; i>=0; i--) {
                 
                 NSDictionary* categoryDict = [categoryDicts objectAtIndex:i];
                 
                 for (int j = [categoriesArray count] - 1; j>=0; j--) {
                     
                     ITBCategory* category = [categoriesArray objectAtIndex:j];
                     
                     if ([category.objectId isEqualToString:[categoryDict objectForKey:@"objectId"]]) {
                         
                         [updatedCategories addObject:category];
                         [updatedCategoryDicts addObject:categoryDict];
                         
                         [categoriesArray removeObject:category];
                         [categoryDicts removeObject:categoryDict];
                     }
                 }
             }
             
             NSMutableArray* deletedCategories = categoriesArray;
             
             NSMutableArray* insertedCategoryDicts = categoryDicts;
             
             NSLog(@"number of elements in updatedCategories = %li", (long)[updatedCategories count]);
             NSLog(@"number of elements in updatedCategoryDicts = %li", (long)[updatedCategoryDicts count]);
             NSLog(@"number of elements in deletedCategories = %li", (long)[deletedCategories count]);
             NSLog(@"number of elements in insertedCategoriesDicts = %li", (long)[insertedCategoryDicts count]);
             
             // updating of attributes
             for (NSDictionary* categoryDict in updatedCategoryDicts) {
                 
                 ITBCategory* category = [updatedCategories objectAtIndex:[updatedCategoryDicts indexOfObject:categoryDict]];
                 
                 [category updateObjectWithDictionary:categoryDict inContext:self.managedObjectContext];
             }
             
             // creating of attributes for inserted categories and merge updated and inserted objects (and dicts)
             NSArray* insertedCategories = [NSArray array];
             if ([insertedCategoryDicts count] > 0) {
                 
                 insertedCategories = [self.coreDataManager addCategoriesToLocalDBFromLoadedArray:insertedCategoryDicts];
                 
                 for (ITBCategory* insertedCategory in insertedCategories) {
                     
                     [updatedCategories addObject:insertedCategory];
                     
                     NSInteger indexOfInsertedCategory = [insertedCategories indexOfObject:insertedCategory];
                     
                     [updatedCategoryDicts addObject:[insertedCategoryDicts objectAtIndex:indexOfInsertedCategory]];
                 }
             }
             
             // deleting
             if ([deletedCategories count] > 0) {
                 
                 [self.coreDataManager deleteObjectsInArray:deletedCategories];
             }
             
             // и теперь уже обновление связей для всех элементов в updatedNews (из updatedNewsDicts) и в updatedCategories (из updatedCategoryDicts)
             
             [self.restClient
              getCurrentUser:self.currentUser.objectId
              onSuccess:^(NSDictionary *dict)
             {
                 
                 [self.coreDataManager
                  addRelationsToLocalDBFromNewsDictsArray:updatedNewsDicts
                  forNewsArray:updatedNews
                  fromCategoryDictsArray:updatedCategoryDicts
                  forCategoriesArray:updatedCategories
                  forUser:self.currentUser onSuccess:^(BOOL isSuccess)
                 {
                     
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     
                     success(isSuccess);
                     
                  }];
                 
              } onFailure:^(NSError *error, NSInteger statusCode) { }];
             
             
          }
          onFailure:^(NSError *error, NSInteger statusCode) { }];
    }
     onFailure:^(NSError *error, NSInteger statusCode) { }];
    
}

- (void)deleteLocalDB
{
    [self.coreDataManager deleteAllObjects];
}

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    NSLog(@"self.currentUser.sessionToken = %@", self.currentUser.sessionToken);
    
    if (self.currentUser.sessionToken != nil) {
        
        [self.restClient uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:self.currentUser onSuccess:^(BOOL isSuccess) {
            
            success(isSuccess);
            
        }];
    }
    
}

- (void)fetchAllObjects {
    
    NSLog(@"All news:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBNews"];
    
    NSLog(@"All categories:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBCategory"];
    
    NSLog(@"All users:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBUser"];
}

- (void) printAllObjectsOfLocalDB
{
    [self.coreDataManager printAllObjectsForName:@"ITBNews"];
    [self.coreDataManager printAllObjectsForName:@"ITBCategory"];
    [self.coreDataManager printAllObjectsForName:@"ITBUser"];
}

@end
