//
//  ITBServerManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// класс singleton для общения с сервером

#import "ITBServerManager.h"

#import "ITBDataManager.h"

#import "ITBUser.h"
#import "ITBNews.h" // надо заменить на ITBNewsCD.h

#import "ITBNewsCD.h"
#import "ITBCategoryCD.h"
#import "ITBUserCD.h"

NSString *const appId = @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn";
NSString *const restApiKey = @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B";
NSString *const json = @"application/json";

NSString *const baseUrl = @"https://api.parse.com";

@interface ITBServerManager ()

//@property (strong, nonatomic) NSURL *baseUrl;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ITBServerManager

+ (ITBServerManager *)sharedManager {
    
    static ITBServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[ITBServerManager alloc] init];
        
    });
    
    return manager;
}

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:nil
                                                         delegateQueue:nil];
    }
    
    return self;
}

#pragma mark - Client-Server API

- (void)authorizeWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(ITBUser* user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    //    baseUrl
    //    @"/1/login?&username="
    //    self.usernameField.text
    //    @"&password="
    //    self.passwordField.text
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@%@%@",
                           @"https://api.parse.com/1/login?&username=",
                           username,
                           @"&password=",
                           password];
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
//        NSLog(@"JSON during authorization UserOnSuccess: %@", responseBody);
        
        if (error == nil) {

            ITBUser *user = [[ITBUser alloc] initWithServerResponse:responseBody];
            
            success(user);

            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    
}

// register new user
- (void)registerWithUsername:(NSString* ) username
                withPassword:(NSString* ) password
                   onSuccess:(void(^)(ITBUser* user)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"POST";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    [request setAllHTTPHeaderFields:headers];
    
    NSDictionary *parameters = @{ @"username": username,
                                  @"password": password };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        if (error == nil) {
            
            ITBUser *user = [[ITBUser alloc] initWithServerResponse:responseBody];
            
            [ITBDataManager sharedManager].currentUser = user;
            
            success(user);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
        
    }];
    
    [task resume];
}

- (void)getUsersOnSuccess:(void(^)(NSArray *users)) success
                 onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
        if (error == nil) {
            
            NSMutableArray *objectsArray = [NSMutableArray array];
            
            for (NSDictionary *dict in dictsArray) {
                
                ITBUser *user = [[ITBUser alloc] initWithServerResponse:dict];
                
                [objectsArray addObject:user];
            }
            
            if (success != nil) {
                success([objectsArray copy]);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

#pragma mark - ТЕСТОВЫЕ МЕТОДЫ

// === методы для получения с сервера всех объектов нужного класса - ТЕСТОВЫЕ МЕТОДЫ

// method to get users from server for saving them to local DB
- (void)getAllUsersOnSuccess:(void(^)(NSArray *users)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting AllUsersOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
        if (error == nil) {
            
            // уберу код из оригинального метода т.к. я перехожу от загрузки новостей с сервера к загрузке с локальной БД -> и мне нужен array of dicts вместо array of models (ITBNews)
            if (success != nil) {
                success(dictsArray);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

// оригинальная версия этого метода - getting news after login as user - my first successful realization (SERVER)
- (void)getNewsOnSuccess:(void(^)(NSArray *news)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
         if (error == nil) {
/*
             NSMutableArray *objectsArray = [NSMutableArray array];
             
             for (NSDictionary *dict in dictsArray) {
                 
                 ITBNews *news = [[ITBNews alloc] initWithServerResponse:dict];
                 
                 for (ITBUser* user in news.likedUsers) {
                     
                     if ([user isEqual:self.currentUser]) {
                         
                         news.isLikedByCurrentUser = YES;
                     }
                 }
                 
                 [objectsArray addObject:news];
             }
 
             if (success != nil) {
                 success([objectsArray copy]);
             }
*/
             
         } else {
         
         // Failure
         NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
         }
    }];
    
    [task resume];
}

// getting news after login as user
- (void)getAllNewsOnSuccess:(void(^)(NSArray *news)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
        if (error == nil) {
            
            // уберу код из оригинального метода т.к. я перехожу от загрузки новостей с сервера к загрузке с локальной БД -> и мне нужен array of dicts вместо array of models (ITBNews)
            if (success != nil) {
                success(dictsArray);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

- (void)getCategoriesOnSuccess:(void(^)(NSArray *categories)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting CategoriesOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
        if (error == nil) {
            
            if (success != nil) {
                success(dictsArray);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    
    
}

// метод для создания тестовых связей - этот метод нужен для создания локальной БД из атрибутов объектов с сервера, затем создаем связи вручную и затем копируем эти связи на parser.com
- (void) createLocalDataSource {
    
    // в этой реализации метода я просто имею на сервере атрибуты объектов без связей, затем скачиваю их в локальную БД, вручную придумываю связи, сохраняю и передаю эти связи на сервер:
    // 1. удаляю все объекты с локальной БД и сначала с сервера скачиваю все атрибуты для объектов ITBNewsCD, ITBCategoryCD, ITBUserCD
    // 2. далее устанавливаю в методе addRelationsManually2 связи в локальной БД и сохраняю в permanent store
    // 3. с помощью методов updateRelationsForNews, updateRelationsForCategories и updateRelationsForUsers закачиваю связи с локальной БД на сервер
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // установка связей вручную сначала локально а потом эти связи закачиваю на сервер
    
    // 1 - сначала загружаю news
    // getAllNewsOnSuccess:onFailure: - это get запрос на parse.com для получения JSON со всеми news
    [self
     getAllNewsOnSuccess:^(NSArray *news) {
         
         // addNewsToLocalDBFromLoadedArray: - это метод для создания объектов класса ITBNewsCD
         [[ITBDataManager sharedManager] addNewsToLocalDBFromLoadedArray:news];
         
         // 2 - далее загружаю categories
         [self
          getCategoriesOnSuccess:^(NSArray *categories) {
              
              [[ITBDataManager sharedManager] addCategoriesToLocalDBFromLoadedArray:categories];
              
              // 3 - и в конце загружаю users с установкой всех связей
              [self
               getAllUsersOnSuccess:^(NSArray *users) {
                   
                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                   
                   [[ITBDataManager sharedManager] addUsersToLocalDBFromLoadedArray:users];
                   
                   [[ITBDataManager sharedManager] addRelationsManually2];
                   
                   [self updateRelationsForNews];
                   [self updateRelationsForCategories];
                   [self updateRelationsForUsers];
                   
                   //                   dispatch_async(dispatch_get_main_queue(), ^{
                   //                       [self.tableView reloadData];
                   //                   });
                   
                   //                   self.fetchedResultsController = nil;
                   //                   [self.tableView reloadData];
                   
                   NSLog(@"after refreshing");
                   [[ITBDataManager sharedManager] printAllObjects];
               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
               }];
              
          }
          onFailure:^(NSError *error, NSInteger statusCode) {
              
          }];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
}

- (void) updateRelationsForNews {
    
    for (ITBNewsCD* newsItem in [ITBDataManager sharedManager].newsArray) {
        
        [self
         updateAllRelationsForNewsItem:newsItem
         onSuccess:^(NSDate *updatedAt)
         {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode)
         {
             
         }];
    }
}

- (void) updateRelationsForCategories {
    
    for (ITBCategoryCD* category in [ITBDataManager sharedManager].categoriesArray) {
        
        [self
         updateAllRelationsForCategory:category
         onSuccess:^(NSDate *updatedAt)
         {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode)
         {
             
         }];
    }
}

- (void) updateRelationsForUsers {
    
    for (ITBUserCD* user in [ITBDataManager sharedManager].usersArray) {
        
        [self
         updateAllRelationsForUser:user
         onSuccess:^(NSDate *updatedAt)
         {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode)
         {
             
         }];
    }
}

- (void) uploadRatingAndSelectedCategoriesFromLocalToServer {
    
    // 1 - user.likedNews and user.selectedCategories
    [self
     uploadToServerUserRelationsForUser:[ITBDataManager sharedManager].currentUserCD
     onSuccess:^(NSDate *updatedAt)
     {
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
    
    // 2 - category.signedUsers
    for (ITBCategoryCD* category in [ITBDataManager sharedManager].currentUserCD.selectedCategories) {
        
        [self
         uploadToServerCategoryRelationsForCategory:category
         onSuccess:^(NSDate *updatedAt)
         {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode)
         {
             
         }];
        
    }
    
    // 3 - news.likeAddedUsers
    for (ITBNewsCD* newsItem in [ITBDataManager sharedManager].currentUserCD.likedNews) {
        
        [self
         uploadToServerNewsRelationsForNewsItem:newsItem
         onSuccess:^(NSDate *updatedAt)
         {
             
         }
         onFailure:^(NSError *error, NSInteger statusCode)
         {
             
         }];
        
    }
    
}

// this method is universal for updating ANY object with ANY fields by ANY urlString
- (void)updateObject:(NSString* ) objectId
         withHeaders:(NSDictionary* ) headers
          withFields:(NSDictionary* ) parameters
        forUrlString:(NSString* ) urlString
           onSuccess:(void(^)(NSDate* updatedAt)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"PUT";
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        if (error == nil) {
            
            NSDate* updatedAt = [responseBody objectForKey:@"updatedAt"];
            
            success(updatedAt);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
        
    }];
    
    [task resume];
}

- (void)updateRatingFromUserForNewsItem:(ITBNews* ) news
                              onSuccess:(void(^)(NSDate* updatedAt)) success
                              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", news.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSString* operation = news.isLikedByCurrentUser ? @"AddUnique" : @"Remove"; // здесь идет наоборот т.к. к этому моменту news.isLikedByCurrentUser уже поменялся а я смотрел по старому значению (до нажатия на кнопку + или -)
    
    NSDictionary *parameters = @{ @"likedUsers": @{ @"__op": operation, @"objects": @[ [ITBDataManager sharedManager].currentUser.objectId ] } };
    
    [self updateObject:news.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS !!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
    
}

- (void)updateCategoriesFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", [ITBDataManager sharedManager].currentUserCD.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": [ITBDataManager sharedManager].currentUser.sessionToken,
                               @"content-type": json };
    
    NSSet* selectedCategories = [ITBDataManager sharedManager].currentUserCD.selectedCategories;
//    NSArray* selectedCategoriesArray = [selectedCategories allObjects];
    
#warning - is difference what to put in NSDictionary *parameters - NSSet or NSArray
    
    NSDictionary *parameters = @{ @"categories": selectedCategories };
    
    [self updateObject:[ITBDataManager sharedManager].currentUserCD.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS !!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}

// 1st manual relation udpating to server from local DB
- (void)updateAllRelationsForNewsItem:(ITBNewsCD* ) news
                                     onSuccess:(void(^)(NSDate* updatedAt)) success
                                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", news.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSMutableArray* likeAddedUsersArray = [NSMutableArray array];
    
    for (ITBUserCD* user in news.likeAddedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              user.objectId, @"objectId", nil];
        
        [likeAddedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likeAddedUsers": likeAddedUsersArray,
                                  @"author": @{ @"__type": @"Pointer", @"className": @"_User", @"objectId": news.author.objectId },
                                  @"category": @{ @"__type": @"Pointer", @"className": @"ITBCategory", @"objectId": news.category.objectId }};

    
    [self updateObject:news.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for NEWS!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}

// 2nd manual relation udpating to server from local DB
- (void)updateAllRelationsForCategory:(ITBCategoryCD* ) category
                                onSuccess:(void(^)(NSDate* updatedAt)) success
                            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", category.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
/*
    NSMutableArray* likeAddedUsersArray = [NSMutableArray array];
    
    for (ITBUserCD* user in news.likeAddedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              user.objectId, @"objectId", nil];
        
        [likeAddedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likeAddedUsers": likeAddedUsersArray,
*/
    NSMutableArray* newsArray = [NSMutableArray array];
    for (ITBNewsCD* newsItem in category.news) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBNews", @"className",
                              newsItem.objectId, @"objectId", nil];
        
        [newsArray addObject:dict];
    }
    
    NSMutableArray* signedUsersArray = [NSMutableArray array];
    for (ITBUserCD* user in category.signedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              user.objectId, @"objectId", nil];
        
        [signedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"news": newsArray,
                                  @"signedUsers": signedUsersArray};
    
    [self updateObject:category.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for categories!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
    
}

//3rd manual relation udpating to server from local DB
- (void)updateAllRelationsForUser:(ITBUserCD* ) user
                        onSuccess:(void(^)(NSDate* updatedAt)) success
                        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": [ITBDataManager sharedManager].currentUser.sessionToken,
                               @"content-type": json };
    
    NSMutableArray* createdNewsArray = [NSMutableArray array];
    for (ITBNewsCD* newsItem in user.createdNews) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBNews", @"className",
                              newsItem.objectId, @"objectId", nil];
        
        [createdNewsArray addObject:dict];
    }
    
    NSMutableArray* likedNewsArray = [NSMutableArray array];
    for (ITBNewsCD* newsItem in user.likedNews) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBNews", @"className",
                              newsItem.objectId, @"objectId", nil];
        
        [likedNewsArray addObject:dict];
    }
    
    NSMutableArray* selectedCategoriesArray = [NSMutableArray array];
    for (ITBCategoryCD* category in user.selectedCategories) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBCategory", @"className",
                              category.objectId, @"objectId", nil];
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"createdNews": createdNewsArray,
                                  @"likedNews": likedNewsArray,
                                  @"selectedCategories": selectedCategoriesArray};
    
    [self updateObject:[ITBDataManager sharedManager].currentUserCD.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for USERS!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
         
     }];
    
}

#pragma mark - МЕТОДЫ ОБНОВЛЯЮЩИЕ СВЯЗИ НА СЕРВЕР

// === МЕТОДЫ ОБНОВЛЯЮЩИЕ СВЯЗИ НА СЕРВЕР

// methods for uploading current user changes to server before refreshing all data from server to local DB
- (void)uploadToServerUserRelationsForUser:(ITBUserCD* ) user
                         onSuccess:(void(^)(NSDate* updatedAt)) success
                         onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": [ITBDataManager sharedManager].currentUser.sessionToken,
                               @"content-type": json };
    
    NSMutableArray* likedNewsArray = [NSMutableArray array];
    for (ITBNewsCD* newsItem in user.likedNews) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBNews", @"className",
                              newsItem.objectId, @"objectId", nil];
        
        [likedNewsArray addObject:dict];
    }
    
    NSMutableArray* selectedCategoriesArray = [NSMutableArray array];
    for (ITBCategoryCD* category in user.selectedCategories) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBCategory", @"className",
                              category.objectId, @"objectId", nil];
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likedNews": likedNewsArray,
                                  @"selectedCategories": selectedCategoriesArray};
    
    [self updateObject:[ITBDataManager sharedManager].currentUserCD.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for USERS!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
         
     }];
    
}

- (void)uploadToServerCategoryRelationsForCategory:(ITBCategoryCD* ) category
                                  onSuccess:(void(^)(NSDate* updatedAt)) success
                                 onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", category.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSMutableArray* signedUsersArray = [NSMutableArray array];
    for (ITBUserCD* user in category.signedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              user.objectId, @"objectId", nil];
        
        [signedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"signedUsers": signedUsersArray};
    
    [self updateObject:category.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for categories!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}

- (void)uploadToServerNewsRelationsForNewsItem:(ITBNewsCD* ) newsItem
                             onSuccess:(void(^)(NSDate* updatedAt)) success
                             onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", newsItem.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSMutableArray* likeAddedUsersArray = [NSMutableArray array];
    
    for (ITBUserCD* user in newsItem.likeAddedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              user.objectId, @"objectId", nil];
        
        [likeAddedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likeAddedUsers": likeAddedUsersArray };
    
    
    [self updateObject:newsItem.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS updating all relations for NEWS!!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}

// original first method (когда я делал серверное приложение)
/*
- (void)updateCategoriesFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", [ITBDataManager sharedManager].currentUser.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": [ITBDataManager sharedManager].currentUser.sessionToken,
                               @"content-type": json };
    
    NSDictionary *parameters = @{ @"categories": [ITBDataManager sharedManager].currentUser.categories };
    
    [self updateObject:[ITBDataManager sharedManager].currentUser.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS !!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
    
    
}
*/

- (void)updateLikedNewsFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", [ITBDataManager sharedManager].currentUserCD.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": [ITBDataManager sharedManager].currentUser.sessionToken,
                               @"content-type": json };
    
    NSSet* selectedCategories = [ITBDataManager sharedManager].currentUserCD.selectedCategories;
    //    NSArray* selectedCategoriesArray = [selectedCategories allObjects];
    
#warning - is difference what to put in NSDictionary *parameters - NSSet or NSArray
    
    NSDictionary *parameters = @{ @"categories": selectedCategories };
    
    [self updateObject:[ITBDataManager sharedManager].currentUserCD.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         NSLog(@"SUCCESS !!! ");
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}

#pragma mark - method for refreshButton

- (void) updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess)) success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // сначала загружаю на сервер сделанные изменения текущего пользователя
    [self uploadRatingAndSelectedCategoriesFromLocalToServer];
    
    // 1 - сначала загружаю news
    [self
     getAllNewsOnSuccess:^(NSArray *news) {
         
         // 2 - далее загружаю categories
         [self
          getCategoriesOnSuccess:^(NSArray *categories) {
              
              // 3 - и в конце загружаю users с установкой всех связей
              [self
               getAllUsersOnSuccess:^(NSArray *users) {
                   
                   NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: news, @"news",
                                         categories, @"categories",
                                         users, @"users", nil];
                   
                   [[ITBDataManager sharedManager] addAllObjectsToLocalDBForDict:dict onSuccess:^(BOOL isSuccess) {
                       
                       success(isSuccess);
                   }];
                   
                   NSLog(@"after refreshing");
                   [[ITBDataManager sharedManager] printAllObjects];
               }
               onFailure:^(NSError *error, NSInteger statusCode) {
                   
               }];
              
          }
          onFailure:^(NSError *error, NSInteger statusCode) {
              
          }];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
    //    [self createLocalDataSource];
}

@end
