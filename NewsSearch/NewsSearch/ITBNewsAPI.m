//
//  ITBNewsAPI.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI.h"

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
     
     if (objectId != nil) {
         
         self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:objectId];
     }
 
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
            
        }
        
        success(user);
        
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
    
    if (!_managedObjectContext) {
        
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

@end
