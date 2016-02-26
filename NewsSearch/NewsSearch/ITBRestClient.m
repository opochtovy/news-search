//
//  ITBRestClient.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBRestClient.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"

NSString *const appId = @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn";
NSString *const restApiKey = @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B";
NSString *const json = @"application/json";

NSString *const baseUrl = @"https://api.parse.com";

@interface ITBRestClient ()

@property (strong, nonatomic) NSURLSession *session;


@end

@implementation ITBRestClient

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
                    onSuccess:(void(^)(NSDictionary* userDict)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
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
            
            success(responseBody);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
    
}

- (void)registerWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(NSDictionary* userDict)) success
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
            
            success(responseBody);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
        
    }];
    
    [task resume];
    
}

- (void)getUsersOnSuccess:(void(^)(NSArray *dicts)) success
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
            
            success(dictsArray);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

- (void)getAllObjectsForClassName:(NSString* ) className
                        onSuccess:(void(^)(NSArray *dicts)) success
                        onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/%@", className];
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
        
        NSLog(@"JSON during getting %@ : %@", className, responseBody);
        
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

- (void)getCurrentUser:(NSString* ) objectId
             onSuccess:(void(^)(NSDictionary *dict)) success
             onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", objectId];
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
        
        NSLog(@"JSON during getting current user : %@", responseBody);
        
        if (error == nil) {
            
            success(responseBody);
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

#pragma mark - МЕТОДЫ ОБНОВЛЯЮЩИЕ СВЯЗИ НА СЕРВЕР

- (void) uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser* ) user
                                                                onSuccess:(void(^)(BOOL isSuccess)) success {
    
    __block NSInteger counter = 0;
    
    // 1 - user.likedNews and user.selectedCategories
    [self
     uploadToServerUserRelationsForCurrentUser:user
     onSuccess:^(NSDate *updatedAt)
     {
         
         ++counter;
         
         if (counter == 3) {
             
             success(YES);
         }

     }
     onFailure:^(NSError *error, NSInteger statusCode) { }];
    
    // 2 - category.signedUsers
    __block NSInteger categoriesCounter = 0;
    
    for (ITBCategory* category in user.selectedCategories) {
        
        [self
         uploadToServerCategoryRelationsForCategory:category
         onSuccess:^(NSDate *updatedAt)
         {
             ++categoriesCounter;
             
             if (categoriesCounter == [user.selectedCategories count]) {
                 
                 ++counter;
                 
                 if (counter == 3) {
                     
                     success(YES);
                 }
                 
             }
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) { }];
        
    }
    
    // 3 - news.likeAddedUsers
    __block NSInteger newsCounter = 0;
    
    for (ITBNews* newsItem in user.likedNews) {
        
        [self
         uploadToServerNewsRelationsForNewsItem:newsItem
         onSuccess:^(NSDate *updatedAt)
         {
             ++newsCounter;
             
             if (newsCounter == [user.likedNews count]) {
                 
                 ++counter;
                 
                 if (counter == 3) {
                     
                     success(YES);
                 }
                 
             }
             
         }
         onFailure:^(NSError *error, NSInteger statusCode) { }];
    }
    
}

// methods for uploading current user changes to server before refreshing all data from server to local DB
- (void)uploadToServerUserRelationsForCurrentUser:(ITBUser* ) user
                                 onSuccess:(void(^)(NSDate* updatedAt)) success
                                 onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSLog(@"user.sessionToken = %@", user.sessionToken);
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
    
//    NSLog(@"user.objectId - %@", user.objectId);
//    NSLog(@"[user.likedNews count] - %li", (long)[user.likedNews count]);
//    NSLog(@"[user.selectedCategories count] - %li", (long)[user.selectedCategories count]);
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": user.sessionToken,
                               @"content-type": json };

    NSMutableArray* likedNewsArray = [NSMutableArray array];
    for (ITBNews* newsItem in user.likedNews) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBNews", @"className",
                              newsItem.objectId, @"objectId", nil];
        
        [likedNewsArray addObject:dict];
    }
    
    NSMutableArray* selectedCategoriesArray = [NSMutableArray array];
    
    for (ITBCategory* category in user.selectedCategories) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBCategory", @"className",
                              category.objectId, @"objectId", nil];
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likedNews": likedNewsArray,
                                  @"selectedCategories": selectedCategoriesArray};

    [self updateObject:user.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
     }];
 
}

- (void)uploadToServerCategoryRelationsForCategory:(ITBCategory* ) category
                                         onSuccess:(void(^)(NSDate* updatedAt)) success
                                         onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", category.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSMutableArray* signedUsersArray = [NSMutableArray array];
    
    for (ITBUser* signedUser in category.signedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              signedUser.objectId, @"objectId", nil];
        
        [signedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"signedUsers": signedUsersArray};
    
    [self updateObject:category.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         success(updatedAt);
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
     }];
}

- (void)uploadToServerNewsRelationsForNewsItem:(ITBNews* ) newsItem
                                     onSuccess:(void(^)(NSDate* updatedAt)) success
                                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", newsItem.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSMutableArray* likeAddedUsersArray = [NSMutableArray array];
    
    for (ITBUser* likeAddedUser in newsItem.likeAddedUsers) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"_User", @"className",
                              likeAddedUser.objectId, @"objectId", nil];
        
        [likeAddedUsersArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likeAddedUsers": likeAddedUsersArray };
    
    
    [self updateObject:newsItem.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         success(updatedAt);
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
     }];
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

@end
