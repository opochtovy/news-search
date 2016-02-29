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

@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;

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

        dispatch_async(dispatch_get_main_queue(), ^{
            
            _mainManagedObjectContext = [_coreDataManager mainManagedObjectContext];
        });
        
        if (self.mainManagedObjectContext != nil) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                _backgroundManagedObjectContext = [_coreDataManager getContextForBGTask];
            });
            
        }
        
        [self loadCurrentUser];
        
    }
    return self;
}

- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if (_mainManagedObjectContext == nil) {
        
        _mainManagedObjectContext = [self.coreDataManager mainManagedObjectContext];
    }
    
    return _mainManagedObjectContext;
}

 #pragma mark - NSUserDefaults
 
- (void)saveCurrentUser
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.currentUser.username forKey:kSettingsUsername];
    [userDefaults setObject:self.currentUser.objectId forKey:kSettingsObjectId];
    [userDefaults setObject:self.currentUser.sessionToken forKey:kSettingsSessionToken];
    
    [userDefaults synchronize];
    
}
 
- (void)loadCurrentUser
{
 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString* objectId = [userDefaults objectForKey:kSettingsObjectId];
    
    if (objectId != nil) {
        
        self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:objectId usingContext:self.mainManagedObjectContext];
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
    
    [self.restClient
     authorizeWithUsername:username
     withPassword:password
     onSuccess:^(NSDictionary *userDict)
     {
         
         ITBUser* user = [self.coreDataManager fetchCurrentUserForObjectId:[userDict objectForKey:@"objectId"] usingContext:self.mainManagedObjectContext];
         [user updateObjectWithDictionary:userDict inContext:self.mainManagedObjectContext];
         
         if (user == nil) {
             
             user = [[ITBUser alloc] insertObjectWithDictionary:userDict inContext:self.mainManagedObjectContext];
         }
         
         [self saveMainContext];
         
         self.currentUser = user;
         [self saveCurrentUser];
         
         success(user);
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) { }];
    
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

- (void) checkNetworkConnectionOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    if (self.currentUser.sessionToken != nil) {
        
        [self.restClient
         checkNetworkConnectionWithSessionToken:self.currentUser.sessionToken
         onSuccess:^(BOOL isSuccess)
         {
             success(isSuccess);
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) { }];
        
    } else {
        
        [self loadCurrentUser];
    }
}

#pragma mark - ITBCoreDataManager

- (void)saveMainContext {
    
    [self.coreDataManager saveMainContext];
    
}

- (NSArray* )fetchAllCategories
{
    return [self.coreDataManager fetchAllCategories];
}

- (NSArray* )fetchAllObjectsForEntity:(NSString* ) entityName
{
    
    NSManagedObjectContext* context = [self.coreDataManager getCurrentThreadContext];
    
    return [self.coreDataManager getObjectsOfType:@"ITBUser" withSortDescriptors:nil andPredicate:nil inContext:context];
}

- (NSArray* )newsInLocalDB {

    return [self.coreDataManager allObjectsForName:@"ITBNews"];
}

#pragma mark - Database creating

- (void) createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.restClient
     getAllObjectsForClassName:@"ITBNews"
     onSuccess:^(NSArray *dicts) {
         
         NSArray* newsDicts = dicts;
         
         NSArray* news = [self.coreDataManager addNewsToLocalDBFromLoadedArray:newsDicts usingContext:self.backgroundManagedObjectContext];
         
         [self.restClient
          getAllObjectsForClassName:@"ITBCategory"
          onSuccess:^(NSArray *dicts)
          {
              
              NSArray* categoryDicts = dicts;
              
              NSArray* categories = [self.coreDataManager addCategoriesToLocalDBFromLoadedArray:categoryDicts usingContext:self.backgroundManagedObjectContext];
              
              [self.restClient
               getCurrentUser:self.currentUser.objectId
               onSuccess:^(NSDictionary *dict)
               {
                   
                   ITBUser* user = [self.coreDataManager fetchCurrentUserForObjectId:self.currentUser.objectId usingContext:self.backgroundManagedObjectContext];
                   
                   [user updateObjectWithDictionary:dict inContext:self.backgroundManagedObjectContext];
                   user.sessionToken = self.currentUser.sessionToken;
                   
                   [self.coreDataManager
                    addRelationsToLocalDBFromNewsDictsArray:newsDicts
                    forNewsArray:news
                    fromCategoryDictsArray:categoryDicts
                    forCategoriesArray:categories
                    forUser:user
                    usingContext:self.backgroundManagedObjectContext
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
         
         NSMutableArray* newsArray = [ [self.coreDataManager allObjectsForName:@"ITBNews" usingContext:self.backgroundManagedObjectContext] mutableCopy];
         
         NSMutableArray* updatedNews = [NSMutableArray array];
         NSMutableArray* updatedNewsDicts = [NSMutableArray array];
         
         for (int i = (int)[newsDicts count] - 1; i>=0; i--) {
             
             NSDictionary* newsDict = [newsDicts objectAtIndex:i];
             
             for (int j = (int)[newsArray count] - 1; j>=0; j--) {
                 
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

         // updating of attributes
         for (NSDictionary* newsDict in updatedNewsDicts) {
             
             ITBNews* newsItem = [updatedNews objectAtIndex:[updatedNewsDicts indexOfObject:newsDict]];
             
             [newsItem updateObjectWithDictionary:newsDict inContext:self.backgroundManagedObjectContext];
         }
         
         // creating of attributes for inserted news and merge updated and inserted objects (and dicts)
         NSArray* insertedNews = [NSArray array];
         if ([insertedNewsDicts count] > 0) {
             
             insertedNews = [self.coreDataManager addNewsToLocalDBFromLoadedArray:insertedNewsDicts usingContext:self.backgroundManagedObjectContext];
             
             for (ITBNews* insertedNewsItem in insertedNews) {
                 
                 [updatedNews addObject:insertedNews];
                 
                 NSInteger indexOfInsertedNewsItem = [insertedNews indexOfObject:insertedNewsItem];
                 
                 [updatedNewsDicts addObject:[insertedNewsDicts objectAtIndex:indexOfInsertedNewsItem]];
             }
         }
         
         // deleting
         if ([deletedNews count] > 0) {
             
             for (id object in deletedNews) {
                 [self.backgroundManagedObjectContext deleteObject:object];
             }
         }
         
         [self.restClient
          getAllObjectsForClassName:@"ITBCategory"
          onSuccess:^(NSArray *dicts)
         {
             NSMutableArray* categoryDicts = [dicts mutableCopy];
             
             NSMutableArray* categoriesArray = [ [self.coreDataManager allObjectsForName:@"ITBCategory" usingContext:self.backgroundManagedObjectContext] mutableCopy];
             
             NSMutableArray* updatedCategories = [NSMutableArray array];
             NSMutableArray* updatedCategoryDicts = [NSMutableArray array];
             
             for (int i = (int)[categoryDicts count] - 1; i>=0; i--) {
                 
                 NSDictionary* categoryDict = [categoryDicts objectAtIndex:i];
                 
                 for (int j = (int)[categoriesArray count] - 1; j>=0; j--) {
                     
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
             
             // updating of attributes
             for (NSDictionary* categoryDict in updatedCategoryDicts) {
                 
                 ITBCategory* category = [updatedCategories objectAtIndex:[updatedCategoryDicts indexOfObject:categoryDict]];
                 
                 [category updateObjectWithDictionary:categoryDict inContext:self.backgroundManagedObjectContext];
             }
             
             // creating of attributes for inserted categories and merge updated and inserted objects (and dicts)
             NSArray* insertedCategories = [NSArray array];
             if ([insertedCategoryDicts count] > 0) {
                 
                 insertedCategories = [self.coreDataManager addCategoriesToLocalDBFromLoadedArray:insertedCategoryDicts usingContext:self.backgroundManagedObjectContext];
                 
                 for (ITBCategory* insertedCategory in insertedCategories) {
                     
                     [updatedCategories addObject:insertedCategory];
                     
                     NSInteger indexOfInsertedCategory = [insertedCategories indexOfObject:insertedCategory];
                     
                     [updatedCategoryDicts addObject:[insertedCategoryDicts objectAtIndex:indexOfInsertedCategory]];
                 }
             }
             
             // deleting
             if ([deletedCategories count] > 0) {
                 
                 for (id object in deletedCategories) {
                     [self.backgroundManagedObjectContext deleteObject:object];
                 }
             }
             
             // и теперь уже обновление связей для всех элементов в updatedNews (из updatedNewsDicts) и в updatedCategories (из updatedCategoryDicts)
             [self.restClient
              getCurrentUser:self.currentUser.objectId
              onSuccess:^(NSDictionary *dict)
              {
                  
                  NSString* sessionToken = [self.currentUser.sessionToken copy];
                  
                  ITBUser* user = [self.coreDataManager fetchCurrentUserForObjectId:self.currentUser.objectId usingContext:self.backgroundManagedObjectContext];
                  
                  [user updateObjectWithDictionary:dict inContext:self.backgroundManagedObjectContext];
                  
                  user.sessionToken = sessionToken;
                 
                 [self.coreDataManager
                  addRelationsToLocalDBFromNewsDictsArray:updatedNewsDicts
                  forNewsArray:updatedNews
                  fromCategoryDictsArray:updatedCategoryDicts
                  forCategoriesArray:updatedCategories
                  forUser:user
                  usingContext:self.backgroundManagedObjectContext
                  onSuccess:^(BOOL isSuccess)
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

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess)) success
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.currentUser.sessionToken != nil) {
        
        [self.restClient uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:self.currentUser onSuccess:^(BOOL isSuccess) {
            
            success(isSuccess);
            
        }];
    }
    
}

@end
