//
//  ITBDataManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBDataManager.h"

#import "ITBUser.h"
#import "ITBNews.h"

#import "ITBServerManager.h"

#import "ITBNewsCD.h"
#import "ITBCategoryCD.h"
#import "ITBUserCD.h"

static NSString *const kSettingsUsername = @"username";
//static NSString *const kSettingsObjectId = @"objectId";
static NSString *const kSettingsSessionToken = @"sessionToken";

NSString *const kSettingsObjectId = @"objectId";

NSString *const login = @"Login";
NSString *const logout = @"Logout";
NSString *const beforeLogin = @"You need to login for using our news network!";

@interface ITBDataManager ()

@end

@implementation ITBDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (ITBDataManager *)sharedManager {
    
    static ITBDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[ITBDataManager alloc] init];
        
    });
    
    return manager;
}

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        self.usersArray = [NSArray array];
        self.categoriesArray = [NSArray array];
        self.newsArray = [NSArray array];
        
        self.currentUser = [[ITBUser alloc] init];
        
        self.allCategoriesArray = [NSArray array];
        
        [self loadSettings];
        
        if (self.currentUser.sessionToken != nil) {
            
            NSLog(@"username != 0 -> загружаются новости из локальной БД");
            
            [self fetchCurrentUserForObjectId:self.currentUser.objectId];
            
            [self fetchAllCategories]; // здесь вычисляется self.allCategories когда мы либо загружаем локальную БД (при загрузке app) либо когда нажимаем refreshButton
            
        }
    }
    
    return self;
}

#pragma mark - NSUserDefaults

- (void)saveSettings {
    
//    NSLog(@"QQQ : self.currentUser.username : %@", self.currentUser.username);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.currentUser.username forKey:kSettingsUsername];
    [userDefaults setObject:self.currentUser.objectId forKey:kSettingsObjectId];
    [userDefaults setObject:self.currentUser.sessionToken forKey:kSettingsSessionToken];
    
//    NSLog(@"Username for currentUser was saved to NSUserDefaults : %@", self.currentUser.username);
    
    [userDefaults synchronize];
    
}

- (void)loadSettings {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.currentUser.username = [userDefaults objectForKey:kSettingsUsername];
    self.currentUser.objectId = [userDefaults objectForKey:kSettingsObjectId];
    self.currentUser.sessionToken = [userDefaults objectForKey:kSettingsSessionToken];
    
//    NSLog(@"sessionToken for currentUser was loaded from NSUserDefaults : %@", self.currentUser.sessionToken);
}

# pragma mark - Private Methods

// выборка всех объектов
- (NSArray *)allObjects {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBObject"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    return resultArray;
    
}

- (void)deleteAllObjects {
    
    NSArray *allObjects = [self allObjects];
    
    for (id object in allObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    // здесь идет сохранение в permanent store
    [self.managedObjectContext save:nil];
}

- (void)printArray:(NSArray *)array {
    
    for (id object in array) {
        
        if ([object isKindOfClass:[ITBNewsCD class]]) {
            
            ITBNewsCD *newsItem = (ITBNewsCD *)object;
            NSLog(@"NEWS title : %@ and URL %@, created at : %@, updated at : %@ AND category = %@ AND author = %@ AND number of likeAddedUsers = %li AND newsItem.rating = %li", newsItem.title, newsItem.newsURL, newsItem.createdAt, newsItem.updatedAt, newsItem.category.title, newsItem.author.username, (long)[newsItem.likeAddedUsers count], (long)newsItem.rating);
            
        } else if ([object isKindOfClass:[ITBCategoryCD class]]) {
            
            ITBCategoryCD *category = (ITBCategoryCD *)object;
            NSLog(@"CATEGORY title : %@ and objectId = %@ and number of news in that category = %li and number of signed users = %li", category.title, category.objectId, (long)[category.news count], (long)[category.signedUsers count]);
            
        } else if ([object isKindOfClass:[ITBUserCD class]]) {
            
            ITBUserCD *user = (ITBUserCD *)object;
            NSLog(@"USER username : %@ and objectId = %@ and number of created news = %li and number of liked news = %li and number of selected categories = %li", user.username, user.objectId, (long)[user.createdNews count], (long)[user.likedNews count], (long)[user.selectedCategories count]);
            
        }
        
    }
    
}

- (void) printAllObjects {

    NSArray *allObjects = [self allObjects];
    [self printArray:allObjects];

}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

- (void)fetchCurrentUserForObjectId:(NSString* ) objectId {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBUserCD"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
    [request setPredicate:predicate];
    
    NSError *requestError = nil;
    
    NSArray *currentUserArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    self.currentUserCD = [currentUserArray firstObject];
    
}

- (void )fetchAllCategories {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription
                                        entityForName:@"ITBCategoryCD"
                                        inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
/*
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    NSLog(@"When I pressed choose category button ,,, number of selected categoies = %li", [resultArray count]);
    
    return resultArray;
*/
    
    self.allCategoriesArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
}

# pragma mark - API

- (void)getNewsFromServer {
    
    [[ITBServerManager sharedManager]
     getNewsOnSuccess:^(NSArray *news) {
         
         NSLog(@"number of all news = %li", (long)[news count]);
         
         [self addNewsToLocalDBFromLoadedArray:news];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

// ЭТИ МЕТОДЫ ДЛЯ СОХРАНЕНИЯ В ЛОКАЛЬНУЮ БД В ТЕСТОВОМ РЕЖИМЕ (РЕЖИМ КОГДА МЫ ВРУЧНУЮ СОЗДАВАЛИ СВЯЗИ ЛОКАЛЬНО А ЗАТЕМ ЗАКАЧИВАЛИ ВСЕ СВЯЗИ НА СЕРВЕР ЧТОБЫ ПОЛУЧИТЬ НА СЕРВЕРЕ ПОЛНОЦЕННУЮ РАБОЧУЮ БД)


// 1st method to get users from server for saving them to local DB
- (void)addNewsToLocalDBFromLoadedArray:(NSArray* ) news {
    
    // эта строка удаляет все объекты из permanent store
    [self deleteAllObjects];
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in news) {
        
        ITBNewsCD *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNewsCD" inManagedObjectContext:self.managedObjectContext];
        
        newsItem.objectId = [newsDict objectForKey:@"objectId"];
        newsItem.title = [newsDict objectForKey:@"title"];
        newsItem.newsURL = [newsDict objectForKey:@"newsURL"];
        
        // createdAt and updatedAt are UTC timestamps stored in ISO 8601 format with millisecond precision: YYYY-MM-DDTHH:MM:SS.MMMZ.
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"updatedAt"]];
        
        
/*
        // устанавливаю связь author и likeAddedUsers
        NSDictionary* authorDict = [newsDict objectForKey:@"author"];
        NSString* authorObjectId = [authorDict objectForKey:@"objectId"];
        
        NSArray* likeAddedUsersObjectIdsArray = [newsDict objectForKey:@"likedUsers"];
        
        for (ITBUserCD* user in self.usersArray) {
            
            if ([user.objectId isEqualToString:authorObjectId]) {
                
                newsItem.author = user;
            }
            
            for (NSString* likeAddedUsersObjectId in likeAddedUsersObjectIdsArray) {
                
                if ([user.objectId isEqualToString:likeAddedUsersObjectId]) {
                    
                    [newsItem addLikeAddedUsersObject:user];
                }
                
            }
        }
        
        // устанавливаю связь category
        NSDictionary* categoryDict = [newsDict objectForKey:@"cat"];
        NSString* categoryObjectId = [categoryDict objectForKey:@"objectId"];
        
        for (ITBCategoryCD* category in self.categoriesArray) {
            
            if ([category.objectId isEqualToString:categoryObjectId]) {
                
                newsItem.category = category;
            }
        }
*/
        [newsArray addObject:newsItem];
    }
    
    self.newsArray = [newsArray copy];
    
    NSLog(@"1st method");
    
    [self printArray:self.newsArray];
    
/*
    NSError *error = nil;
    
    // здесь идет сохранение в permanent store
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
*/
}

- (void)getCategoriesFromServer {
    
    [[ITBServerManager sharedManager]
     getCategoriesOnSuccess:^(NSArray *categories) {
         
         NSLog(@"number of all categories = %li", (long)[categories count]);
         
         [self addCategoriesToLocalDBFromLoadedArray:categories];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

// 2nd method to get users from server for saving them to local DB
- (void)addCategoriesToLocalDBFromLoadedArray:(NSArray* ) categories {
    
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* catDict in categories) {
        
        ITBCategoryCD *category = [NSEntityDescription insertNewObjectForEntityForName:@"ITBCategoryCD" inManagedObjectContext:self.managedObjectContext];
        
        category.objectId = [catDict objectForKey:@"objectId"];
        category.title = [catDict objectForKey:@"title"];
        
        
        /*
         // устанавливаю связь signedUsers
         NSArray* signedUsersObjectIdsArray = [catDict objectForKey:@"signedUsers"];
         
         for (ITBUserCD* user in self.usersArray) {
         
         for (NSString* signedUsersObjectId in signedUsersObjectIdsArray) {
         
         if ([user.objectId isEqualToString:signedUsersObjectId]) {
         
         [category addSignedUsersObject:user];
         }
         
         }
         }
         */
        /*
         // устанавливаю связь news
         NSArray* newsObjectIdsArray = [catDict objectForKey:@"news"];
         
         for (ITBNewsCD* newsItem in self.newsArray) {
         
         for (NSString* newsObjectId in newsObjectIdsArray) {
         
         if ([newsItem.objectId isEqualToString:newsObjectId]) {
         
         [category addNewsObject:newsItem];
         }
         
         }
         }
         */

        [categoriesArray addObject:category];
    }
    
    self.categoriesArray = [categoriesArray copy];
    
    NSLog(@"2nd method");
    [self printArray:self.categoriesArray];
/*
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
 */
}

- (void) addCurrentUserToLocalDB {
    
    ITBUserCD* user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUserCD" inManagedObjectContext:self.managedObjectContext];
    
    user.objectId = self.currentUser.objectId;
    user.username = self.currentUser.username;
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self printAllObjects];
    
    [self allObjects];
}

// 3rd method to get users from server for saving them to local DB
- (void)addUsersToLocalDBFromLoadedArray:(NSArray* ) users {
    
    // эта строка удаляет все объекты из permanent store
//    [self deleteAllObjects];
    
    NSMutableArray* usersArray = [NSMutableArray array];
    
    for (NSDictionary* userDict in users) {
        
        ITBUserCD *user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUserCD" inManagedObjectContext:self.managedObjectContext];
        
        user.objectId = [userDict objectForKey:@"objectId"];
        user.username = [userDict objectForKey:@"username"];
        
        [usersArray addObject:user];
    }
    
    self.usersArray = [usersArray copy];
    
    NSLog(@"3rd method");
    [self printArray:self.usersArray];
    
/*
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
 */
}

- (void) addRelations {
    
    // 1st fetchRequest for News
    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description1 = [NSEntityDescription
                                         entityForName:@"ITBNewsCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request1 setEntity:description1];
    
    NSError *requestError = nil;
    
    NSArray *resultNewsArray = [self.managedObjectContext executeFetchRequest:request1 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 2nd fetchRequest for Categories
    NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description2 = [NSEntityDescription
                                         entityForName:@"ITBCategoryCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request2 setEntity:description2];
    
    NSArray *resultCategoriesArray = [self.managedObjectContext executeFetchRequest:request2 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 3rd fetchRequest for Users
    NSFetchRequest *request3 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description3 = [NSEntityDescription
                                         entityForName:@"ITBUserCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request3 setEntity:description3];
    
    NSArray *resultUserArray = [self.managedObjectContext executeFetchRequest:request3 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    for (ITBNewsCD* newsItem in resultNewsArray) {
        
        //        newsItem.author = currentUser;
        //        car.model = carModelNames[arc4random_uniform(5)];
        //        NSInteger countOfUsers = [resultUserArray count];
        
        // 1 связь - author
        newsItem.author = [resultUserArray objectAtIndex:arc4random_uniform((int)[resultUserArray count])];
        NSLog(@"1 связь - author - newsItem.author.username = %@", newsItem.author.username);
        
        // 2 связь - likeAddedUsers
        for (ITBUserCD* user in resultUserArray) {
            
            [newsItem addLikeAddedUsersObject:user];
            
        }
        
        // 3 связь - category
        for (ITBCategoryCD* category in resultCategoriesArray) {
            
            if ( ([category.title isEqualToString:@"realty"]) && ([newsItem.objectId isEqualToString:@"etpe6DlNgc"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([category.title isEqualToString:@"sport"]) && ([newsItem.objectId isEqualToString:@"JlnHtVqzlP"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([category.title isEqualToString:@"weather"]) && ([newsItem.objectId isEqualToString:@"vuyVshsCZt"]) ) {
                
                newsItem.category = category;
                
            }
            
            
            // 4 связь - selectedCategories
            for (ITBUserCD* user in resultUserArray) {
                
                [user addSelectedCategoriesObject:category];
                
            }
        }
        
    }
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void) addRelationsManually2 {
    
    // 1st fetchRequest for News
    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description1 = [NSEntityDescription
                                         entityForName:@"ITBNewsCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request1 setEntity:description1];
    
    NSError *requestError = nil;
    
    NSArray *resultNewsArray = [self.managedObjectContext executeFetchRequest:request1 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 2nd fetchRequest for Categories
    NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description2 = [NSEntityDescription
                                         entityForName:@"ITBCategoryCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request2 setEntity:description2];
    
    NSArray *resultCategoriesArray = [self.managedObjectContext executeFetchRequest:request2 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 3rd fetchRequest for Users
    NSFetchRequest *request3 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description3 = [NSEntityDescription
                                         entityForName:@"ITBUserCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request3 setEntity:description3];
    
    NSArray *resultUserArray = [self.managedObjectContext executeFetchRequest:request3 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    for (ITBNewsCD* newsItem in resultNewsArray) {
        
//        newsItem.author = currentUser;
//        car.model = carModelNames[arc4random_uniform(5)];
//        NSInteger countOfUsers = [resultUserArray count];
        
        // 1 связь - author
        newsItem.author = [resultUserArray objectAtIndex:arc4random_uniform((int)[resultUserArray count])];
        NSLog(@"1 связь - author - newsItem.author.username = %@", newsItem.author.username);
        
        // 2 связь - likeAddedUsers
        for (ITBUserCD* user in resultUserArray) {
            
            [newsItem addLikeAddedUsersObject:user];
            
        }
        
        // 3 связь - category
        for (ITBCategoryCD* category in resultCategoriesArray) {
            
            if ( ([category.title isEqualToString:@"realty"]) && ([newsItem.objectId isEqualToString:@"etpe6DlNgc"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([category.title isEqualToString:@"sport"]) && ([newsItem.objectId isEqualToString:@"JlnHtVqzlP"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([category.title isEqualToString:@"weather"]) && ([newsItem.objectId isEqualToString:@"vuyVshsCZt"]) ) {
                
                newsItem.category = category;
                
            }
            
            
            // 4 связь - selectedCategories
            for (ITBUserCD* user in resultUserArray) {
                
                [user addSelectedCategoriesObject:category];
                
            }
        }
        
    }
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void) addRelationsManually {
    
    // code for setting all my relations manually
    
    // 1st fetchRequest for News
    NSFetchRequest *request1 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description1 = [NSEntityDescription
                                         entityForName:@"ITBNewsCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request1 setEntity:description1];
    
    NSError *requestError = nil;
    
    NSArray *resultNewsArray = [self.managedObjectContext executeFetchRequest:request1 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 2nd fetchRequest for Categories
    NSFetchRequest *request2 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description2 = [NSEntityDescription
                                         entityForName:@"ITBCategoryCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request2 setEntity:description2];
    
    NSArray *resultCategoriesArray = [self.managedObjectContext executeFetchRequest:request2 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    // 3rd fetchRequest for currentUser
    NSFetchRequest *request3 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description3 = [NSEntityDescription
                                         entityForName:@"ITBUserCD"
                                         inManagedObjectContext:self.managedObjectContext];
    
    [request3 setEntity:description3];
    
    NSArray *resultUserArray = [self.managedObjectContext executeFetchRequest:request3 error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    
    ITBUserCD* currentUser = [resultUserArray firstObject];
    
    for (ITBNewsCD* newsItem in resultNewsArray) {
        
        newsItem.author = currentUser;
        
        [newsItem addLikeAddedUsersObject:currentUser];
        
        
        // изменение newsItem.rating происходит в ITBNewsCD+CoreDataProperties.m в связанных методах likeAddedUsers
        /*
         NSInteger ratingInt = [newsItem.rating integerValue];
         newsItem.rating = [NSNumber numberWithInteger:++ratingInt];
         */
        for (ITBCategoryCD* category in resultCategoriesArray) {
            
            [category addSignedUsersObject:currentUser];
            
            if ( ([newsItem.objectId isEqualToString:@"JlnHtVqzlP"]) && ([category.title isEqualToString:@"sport"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([newsItem.objectId isEqualToString:@"etpe6DlNgc"]) && ([category.title isEqualToString:@"realty"]) ) {
                
                newsItem.category = category;
                
            } else if ( ([newsItem.objectId isEqualToString:@"vuyVshsCZt"]) && ([category.title isEqualToString:@"weather"]) ) {
                
                newsItem.category = category;
                
            }
            
        }
        
    }
    
    NSError *error = nil;
    
    // здесь идет сохранение в permanent store
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    // end of code for setting all my relations manually
    
}

// КОНЕЦ - ЭТИ МЕТОДЫ ДЛЯ СОХРАНЕНИЯ В ЛОКАЛЬНУЮ БД В ТЕСТОВОМ РЕЖИМЕ (РЕЖИМ КОГДА МЫ ВРУЧНУЮ СОЗДАВАЛИ СВЯЗИ ЛОКАЛЬНО А ЗАТЕМ ЗАКАЧИВАЛИ ВСЕ СВЯЗИ НА СЕРВЕР ЧТОБЫ ПОЛУЧИТЬ НА СЕРВЕРЕ ПОЛНОЦЕННУЮ РАБОЧУЮ БД)


// ЭТИ МЕТОДЫ УЖЕ ДЛЯ refresh КОГДА МЫ С ПОЛНОЦЕННОЙ БД НА СЕРВЕРЕ ЗАКАЧИВАЕМ В ЛОКАЛЬНУЮ БД АТРИБУТЫ И СВЯЗИ

- (void)addAllObjectsToLocalDBForDict:(NSDictionary* ) dict
                            onSuccess:(void(^)(BOOL isSuccess)) success {
    
    // эта строка удаляет все объекты из permanent store
    [self deleteAllObjects];
    
    // 1 - News
    
    NSArray* newsDictsArray = [dict objectForKey:@"news"];
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in newsDictsArray) {
        
        ITBNewsCD *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNewsCD" inManagedObjectContext:self.managedObjectContext];
        
        newsItem.objectId = [newsDict objectForKey:@"objectId"];
        newsItem.title = [newsDict objectForKey:@"title"];
        newsItem.newsURL = [newsDict objectForKey:@"newsURL"];
        
        // createdAt and updatedAt are UTC timestamps stored in ISO 8601 format with millisecond precision: YYYY-MM-DDTHH:MM:SS.MMMZ.
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"updatedAt"]];
        
        [newsArray addObject:newsItem];
    }
    
    //    self.newsArray = [newsArray copy];
    
    // end of 1 - News
    
    // 2 - Category
    
    NSArray* categoryDictsArray = [dict objectForKey:@"categories"];
    
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* categoryDict in categoryDictsArray) {
        
        ITBCategoryCD *category = [NSEntityDescription insertNewObjectForEntityForName:@"ITBCategoryCD" inManagedObjectContext:self.managedObjectContext];
        
        category.objectId = [categoryDict objectForKey:@"objectId"];
        category.title = [categoryDict objectForKey:@"title"];
        
        [categoriesArray addObject:category];
        
    }
    
    //        self.categoriesArray = [categoriesArray copy];
    
    // end of 2 - Category
    
    // 3 - User
    
    NSArray* userDictsArray = [dict objectForKey:@"users"];
    
    NSMutableArray* usersArray = [NSMutableArray array];
    
    for (NSDictionary* userDict in userDictsArray) {
        
        ITBUserCD *user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUserCD" inManagedObjectContext:self.managedObjectContext];
        
        user.objectId = [userDict objectForKey:@"objectId"];
        user.username = [userDict objectForKey:@"username"];
        
        [usersArray addObject:user];
        
    }
    
    //            self.usersArray = [usersArray copy];
    
    // end of 3 - User
    
    // 4 - и только теперь можно создавать все связи (отдельно от создания NSManagedObject
    for (NSDictionary* newsDict in newsDictsArray) {
        
        ITBNewsCD* newsItem = [newsArray objectAtIndex:[newsDictsArray indexOfObject:newsDict]];
        
        NSDictionary* authorDict = [newsDict objectForKey:@"author"];
        NSArray* likeAddedUsersDictsArray = [newsDict objectForKey:@"likeAddedUsers"];
        NSDictionary* categoryOfNewsItemDict = [newsDict objectForKey:@"category"];
        
        for (NSDictionary* categoryDict in categoryDictsArray) {
            
            ITBCategoryCD* category = [categoriesArray objectAtIndex:[categoryDictsArray indexOfObject:categoryDict]];
            
            // устанавливаю связь category - ЭТА связь не работает
            if ([category.objectId isEqualToString:[categoryOfNewsItemDict objectForKey:@"objectId"]]) {
                
                newsItem.category = category;
                
            }
            // конец - устанавливаю связь category
            
            for (NSDictionary* userDict in userDictsArray) {
                
                ITBUserCD* user = [usersArray objectAtIndex:[userDictsArray indexOfObject:userDict]];
                
                // устанавливаю связь likedNews
                for (NSDictionary* likeAddedUsersDict in likeAddedUsersDictsArray) {
                    
                    if ([user.objectId isEqualToString:[likeAddedUsersDict objectForKey:@"objectId"]]) {
                        
                        [user addLikedNewsObject:newsItem];
                    }
                }
                // конец - устанавливаю связь likedNews
                
                // устанавливаю связь author
                if ([user.objectId isEqualToString:[authorDict objectForKey:@"objectId"]]) {
                    
                    newsItem.author = user;
                    
                }
                // конец - устанавливаю связь author
                
                // устанавливаю связь selectedCategories
                NSLog(@"username = %@", user.username);
                
                NSLog(@"!!! %@", [userDict objectForKey:@"selectedCategories"]);
                
                NSArray* selectedCategoriesDictsArray = [userDict objectForKey:@"selectedCategories"];
                
                NSLog(@"%li", (long)[selectedCategoriesDictsArray count]);
                
                // тут идет проверка на то сколько элементов в массиве - 1 или больше (почему-то если 1 один то объект из полученного responseBody ( [userDict objectForKey:@"selectedCategories"] ) - не массив с одним элементом а просто NSString* objectId of selected category
                if ([selectedCategoriesDictsArray count] > 1) {
                    
                    for (NSDictionary* selectedCategoriesDict in selectedCategoriesDictsArray) {
                        
                        NSLog(@"!!! %@", [selectedCategoriesDict objectForKey:@"objectId"]);
                        
                        if ([category.objectId isEqualToString:[selectedCategoriesDict objectForKey:@"objectId"]]) {
                            
                            [user addSelectedCategoriesObject:category];
                        }
                    }
                    
                } else {
                    
                    if ([category.objectId isEqualToString:[userDict objectForKey:@"selectedCategories"]]) {
                        
                        [user addSelectedCategoriesObject:category];
                    }
                }
                // конец - устанавливаю связь selectedCategories
            }
            
        }
        
    }
    // конец 4 - создание всех связей

    // сохранение в persistant store
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error]) {
        
        NSLog(@"%@", [error localizedDescription]);
    }
    
    // 5 -  теперь надо установить self.currentUserCD и self.allCategoriesArray
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self fetchCurrentUserForObjectId:[userDefaults objectForKey:kSettingsObjectId]];
    [self fetchAllCategories];
    
    success(YES);
    
}

- (void)addNewsToLocalDBForNewsDictsArray:(NSArray* ) news {
    
    // эта строка удаляет все объекты из permanent store
    [self deleteAllObjects];
    
    NSMutableArray* newsArray = [NSMutableArray array];
    
    for (NSDictionary* newsDict in news) {
        
        ITBNewsCD *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNewsCD" inManagedObjectContext:self.managedObjectContext];
        
        newsItem.objectId = [newsDict objectForKey:@"objectId"];
        newsItem.title = [newsDict objectForKey:@"title"];
        newsItem.newsURL = [newsDict objectForKey:@"newsURL"];
        
        // createdAt and updatedAt are UTC timestamps stored in ISO 8601 format with millisecond precision: YYYY-MM-DDTHH:MM:SS.MMMZ.
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[newsDict objectForKey:@"updatedAt"]];
        
        [newsArray addObject:newsItem];
    }
    
    self.newsArray = [newsArray copy];
    
    [self printArray:self.newsArray];
}

- (void)addCategoriesToLocalDBForCategoriesDictsArray:(NSArray* ) categories {
    
    NSMutableArray* categoriesArray = [NSMutableArray array];
    
    for (NSDictionary* catDict in categories) {
        
        ITBCategoryCD *category = [NSEntityDescription insertNewObjectForEntityForName:@"ITBCategoryCD" inManagedObjectContext:self.managedObjectContext];
        
        category.objectId = [catDict objectForKey:@"objectId"];
        category.title = [catDict objectForKey:@"title"];
        
        // устанавливаю связь news
        NSArray* newsDictsArray = [catDict objectForKey:@"news"];
        
        for (ITBNewsCD* newsItem in self.newsArray) {
            
            for (NSDictionary* newsDict in newsDictsArray) {
                
                NSString* newsDictObjectId = [newsDict objectForKey:@"objectId"];
                
                if ([newsItem.objectId isEqualToString:newsDictObjectId]) {
                    
                    [category addNewsObject:newsItem];
                }
                
            }
        }
        
        [categoriesArray addObject:category];
    }
    
    self.categoriesArray = [categoriesArray copy];
    
    NSLog(@"2nd method");
    [self printArray:self.categoriesArray];
}

- (void)addUsersToLocalDBForUsersDictsArray:(NSArray* ) users {
    
    NSMutableArray* usersArray = [NSMutableArray array];
    
    for (NSDictionary* userDict in users) {
        
        ITBUserCD *user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUserCD" inManagedObjectContext:self.managedObjectContext];
        
        user.objectId = [userDict objectForKey:@"objectId"];
        user.username = [userDict objectForKey:@"username"];
        
        // устанавливаю связь createdNews
        NSArray* createdNewsDictsArray = [userDict objectForKey:@"createdNews"];
        
        // устанавливаю связь likedNews одновременно с связью createdNews
        NSArray* likedNewsDictsArray = [userDict objectForKey:@"likedNews"];
        
        for (ITBNewsCD* newsItem in self.newsArray) {
            
            for (NSDictionary* createdNewsDict in createdNewsDictsArray) {
                
                NSString* createdNewsDictObjectId = [createdNewsDict objectForKey:@"objectId"];
                
                if ([newsItem.objectId isEqualToString:createdNewsDictObjectId]) {
                    
                    [user addCreatedNewsObject:newsItem];
                }
                
            }
            
            for (NSDictionary* likedNewsDict in likedNewsDictsArray) {
                
                NSString* likedNewsDictObjectId = [likedNewsDict objectForKey:@"objectId"];
                
                if ([newsItem.objectId isEqualToString:likedNewsDictObjectId]) {
                    
                    [user addLikedNewsObject:newsItem];
                }
                
            }
        }
        
        // устанавливаю связь selectedCategories
        NSArray* selectedCategoriesDictsArray = [userDict objectForKey:@"selectedCategories"];
        
        for (ITBCategoryCD* category in self.categoriesArray) {
            
            for (NSDictionary* selectedCategoriesDict in selectedCategoriesDictsArray) {
                
                NSString* selectedCategoriesDictObjectId = [selectedCategoriesDict objectForKey:@"objectId"];
                
                if ([category.objectId isEqualToString:selectedCategoriesDictObjectId]) {
                    
                    [user addSelectedCategoriesObject:category];
                }
                
            }
        }
        
        [usersArray addObject:user];
    }
    
    self.usersArray = [usersArray copy];
    
    NSLog(@"3rd method");
    [self printArray:self.usersArray];
    
     NSError *error = nil;
     
     if (![self.managedObjectContext save:&error]) {
     
     NSLog(@"%@", [error localizedDescription]);
     }
}

// КОНЕЦ - ЭТИ МЕТОДЫ УЖЕ ДЛЯ refresh КОГДА МЫ С ПОЛНОЦЕННОЙ БД НА СЕРВЕРЕ ЗАКАЧИВАЕМ В ЛОКАЛЬНУЮ БД АТРИБУТЫ И СВЯЗИ

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewsSearch" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsSearch.sqlite"];
    
    NSError *error = nil;
//    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        
        /*
         // Report any error we got.
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
         dict[NSLocalizedFailureReasonErrorKey] = failureReason;
         dict[NSUnderlyingErrorKey] = error;
         error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
         // Replace this with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         */
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
/*
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"Error"
                                        message:[error localizedDescription]
                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            
                                            handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
*/ 
        }
    }
}

@end
