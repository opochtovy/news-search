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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during authorization UserOnSuccess: %@", responseBody);
            
            if (error == nil) {
                
                success(responseBody);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
        } else {
            
//            NSLog(@"There is no connection to server");
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            if (error == nil) {
                
                success(responseBody);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            NSArray* dictsArray = [responseBody objectForKey:@"results"];
            
            if (error == nil) {
                
                success(dictsArray);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
        }
        
    }];
    
    [task resume];
}

- (void)checkNetworkConnectionWithSessionToken:(NSString* ) sessionToken
                                     onSuccess:(void(^)(BOOL isSuccess)) success
                                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/me"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": sessionToken };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
//            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
//            NSLog(@"JSON during checkNetworkConnectionWithSessionToken : %@", responseBody);
            
            if (error == nil) {
                
                success(YES);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
            success(NO);
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//            NSLog(@"JSON during getting %@ : %@", className, responseBody);
            
            NSArray* dictsArray = [responseBody objectForKey:@"results"];
            
            if (error == nil) {
                
                if (success != nil) {
                    success(dictsArray);
                }
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//            NSLog(@"JSON during getting current user : %@", responseBody);
            
            if (error == nil) {
                
                success(responseBody);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
        }
        
    }];
    
    [task resume];
}

#pragma mark - Methods for updating of relations to server

- (void) uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser* ) user
                                                                onSuccess:(void(^)(BOOL isSuccess)) success {
    
    dispatch_group_t group = dispatch_group_create();
    
    [self
     getCurrentUser:user.objectId
     onSuccess:^(NSDictionary *dict)
     {
         NSDictionary *headers = @{ @"x-parse-application-id": appId,
                                    @"x-parse-rest-api-key": restApiKey,
                                    @"content-type": json };
         
         NSMutableArray* oldLikedNewsDicts = [[dict objectForKey:@"likedNews"] mutableCopy];
         
         NSMutableArray* newLikedNewsArray = [[user.likedNews allObjects] mutableCopy];
         
         if ([newLikedNewsArray count] == 0) {
             
             if ([oldLikedNewsDicts count] == 0) {
             
             } else {
                 
                 for (NSDictionary* oldLikedNewsDict in oldLikedNewsDicts) {
                     
                     NSString* objectId = [oldLikedNewsDict objectForKey:@"objectId"];
                     
                     NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                     
                     NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"Remove", @"objects": @[ user.objectId ] } };
                     
                     dispatch_group_enter(group);
                     [self
                      uploadToServerRelationsForObjectId:objectId
                      forUrlString:urlString
                      withHeaders:headers
                      withParameters:parameters
                      onSuccess:^(NSDate *updatedAt)
                     {
                         dispatch_group_leave(group);
                     }
                      onFailure:^(NSError *error, NSInteger statusCode) {
                          
                          dispatch_group_leave(group);
                      }];
                     
                 }
             }
             
         } else {
             
             if ([oldLikedNewsDicts count] == 0) {
                 
                 for (ITBNews* newsItem in newLikedNewsArray) {
                     
                     NSString* objectId = newsItem.objectId;
                     
                     NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                     
                     NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"AddUnique", @"objects": @[ user.objectId ] } };
                     
                     dispatch_group_enter(group);
                     [self
                      uploadToServerRelationsForObjectId:objectId
                      forUrlString:urlString
                      withHeaders:headers
                      withParameters:parameters
                      onSuccess:^(NSDate *updatedAt)
                      {
                          dispatch_group_leave(group);
                      }
                      onFailure:^(NSError *error, NSInteger statusCode) {
                          
                          dispatch_group_leave(group);
                      }];
                     
                 }
                 
             } else {
                 
                 for (int i = (int)[oldLikedNewsDicts count] - 1; i>=0; i--) {
                     
                     NSDictionary* oldLikedNewsDict = [oldLikedNewsDicts objectAtIndex:i];
                     
                     for (int j = (int)[newLikedNewsArray count] - 1; j>=0; j--) {
                         
                         ITBNews* newsItem = [newLikedNewsArray objectAtIndex:j];
                         
                         if ([newsItem.objectId isEqualToString:[oldLikedNewsDict objectForKey:@"objectId"]]) {
                             
                             [newLikedNewsArray removeObject:newsItem];
                             [oldLikedNewsDicts removeObject:oldLikedNewsDict];
                             
                         }
                         
                         
                     }
                 }
                 
                 if ([oldLikedNewsDicts count] > 0) {
                     
                     for (NSDictionary* oldLikedNewsDict in oldLikedNewsDicts) {
                         
                         NSString* objectId = [oldLikedNewsDict objectForKey:@"objectId"];
                         
                         NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                         
                         NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"Remove", @"objects": @[ user.objectId ] } };
                         
                         dispatch_group_enter(group);
                         [self
                          uploadToServerRelationsForObjectId:objectId
                          forUrlString:urlString
                          withHeaders:headers
                          withParameters:parameters
                          onSuccess:^(NSDate *updatedAt)
                          {
                              
                              dispatch_group_leave(group);
                          }
                          onFailure:^(NSError *error, NSInteger statusCode) {
                              
                              dispatch_group_leave(group);
                          }];
                         
                     }
                     
                 } else if ([newLikedNewsArray count] > 0) {
                     
                     for (ITBNews* newsItem in newLikedNewsArray) {
                         
                         NSString* objectId = newsItem.objectId;
                         
                         NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                         
                         NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"AddUnique", @"objects": @[ user.objectId ] } };
                         
                         dispatch_group_enter(group);
                         [self
                          uploadToServerRelationsForObjectId:objectId
                          forUrlString:urlString
                          withHeaders:headers
                          withParameters:parameters
                          onSuccess:^(NSDate *updatedAt)
                          {
                              
                              dispatch_group_leave(group);
                          }
                          onFailure:^(NSError *error, NSInteger statusCode) {
                              
                              dispatch_group_leave(group);
                          }];
                         
                     }
                     
                 }
                 
             }
             
         }
         
         NSMutableArray* oldSelectedCategoriesDicts = [[dict objectForKey:@"selectedCategories"] mutableCopy];
         
         NSMutableArray* newSelectedCategoriesArray = [[user.selectedCategories allObjects] mutableCopy];
         
         if ([newSelectedCategoriesArray count] == 0) {
             
             if ([oldSelectedCategoriesDicts count] == 0) {
                 
             }  else {
                 
                 for (NSDictionary* oldSelectedCategoryDict in oldLikedNewsDicts) {
                     
                     NSString* objectId = [oldSelectedCategoryDict objectForKey:@"objectId"];
                     
                     NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                     
                     NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"Remove", @"objects": @[ user.objectId ] } };
                     
                     dispatch_group_enter(group);
                     [self
                      uploadToServerRelationsForObjectId:objectId
                      forUrlString:urlString
                      withHeaders:headers
                      withParameters:parameters
                      onSuccess:^(NSDate *updatedAt)
                      {
                          
                          dispatch_group_leave(group);
                      }
                      onFailure:^(NSError *error, NSInteger statusCode) {
                          
                          dispatch_group_leave(group);
                      }];
                     
                 }
                 
             }
             
         } else {
             
             if ([oldSelectedCategoriesDicts count] == 0) {
                 
                 for (ITBCategory* category in newSelectedCategoriesArray) {
                     
                     NSString* objectId = category.objectId;
                     
                     NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                     
                     NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"AddUnique", @"objects": @[ user.objectId ] } };
                     
                     dispatch_group_enter(group);
                     [self
                      uploadToServerRelationsForObjectId:objectId
                      forUrlString:urlString
                      withHeaders:headers
                      withParameters:parameters
                      onSuccess:^(NSDate *updatedAt)
                      {
                          
                          dispatch_group_leave(group);
                      }
                      onFailure:^(NSError *error, NSInteger statusCode) {
                          
                          dispatch_group_leave(group);
                      }];
                     
                 }
                 
             }  else {
                 
                 for (int i = (int)[oldSelectedCategoriesDicts count] - 1; i>=0; i--) {
                     
                     NSDictionary* oldSelectedCategoryDict = [oldSelectedCategoriesDicts objectAtIndex:i];
                     
                     for (int j = (int)[newSelectedCategoriesArray count] - 1; j>=0; j--) {
                         
                         ITBCategory* category = [newSelectedCategoriesArray objectAtIndex:j];
                         
                         if ([category.objectId isEqualToString:[oldSelectedCategoryDict objectForKey:@"objectId"]]) {
                             
                             [newSelectedCategoriesArray removeObject:category];
                             [oldSelectedCategoriesDicts removeObject:oldSelectedCategoryDict];
                             
                         }
                         
                         
                     }
                 }
                 
                 if ([oldSelectedCategoriesDicts count] > 0) {
                     
                     for (NSDictionary* oldSelectedCategoryDict in oldSelectedCategoriesDicts) {
                         
                         NSString* objectId = [oldSelectedCategoryDict objectForKey:@"objectId"];
                         
                         NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                         
                         NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"Remove", @"objects": @[ user.objectId ] } };
                         
                         dispatch_group_enter(group);
                         [self
                          uploadToServerRelationsForObjectId:objectId
                          forUrlString:urlString
                          withHeaders:headers
                          withParameters:parameters
                          onSuccess:^(NSDate *updatedAt)
                          {
                              
                              dispatch_group_leave(group);
                          }
                          onFailure:^(NSError *error, NSInteger statusCode) {
                              
                              dispatch_group_leave(group);
                          }];
                         
                     }
                     
                 } else if ([newSelectedCategoriesArray count] > 0) {
                     
                     for (ITBCategory* category in newSelectedCategoriesArray) {
                         
                         NSString* objectId = category.objectId;
                         
                         NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                         
                         NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"AddUnique", @"objects": @[ user.objectId ] } };
                         
                         dispatch_group_enter(group);
                         [self
                          uploadToServerRelationsForObjectId:objectId
                          forUrlString:urlString
                          withHeaders:headers
                          withParameters:parameters
                          onSuccess:^(NSDate *updatedAt)
                          {
                              
                              dispatch_group_leave(group);
                          }
                          onFailure:^(NSError *error, NSInteger statusCode) {
                              
                              dispatch_group_leave(group);
                          }];
                         
                     }
                     
                 }
                 
             }
             
         }
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) { }];
    
    dispatch_group_enter(group);
    [self
     uploadToServerUserRelationsForCurrentUser:user
     onSuccess:^(NSDate *updatedAt)
     {
         
         dispatch_group_leave(group);
         
         
         success(YES);
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
         
         dispatch_group_leave(group);
     }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        success(YES);
    });
    
}

// methods for uploading current user changes to server before refreshing all data from server to local DB
- (void)uploadToServerUserRelationsForCurrentUser:(ITBUser* ) user
                                 onSuccess:(void(^)(NSDate* updatedAt)) success
                                 onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
    
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
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: signedUser.objectId, @"objectId", nil];
        
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
             onFailure:^(NSError *error, NSInteger statusCode) { }];
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
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: likeAddedUser.objectId, @"objectId", nil];
        
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
             onFailure:^(NSError *error, NSInteger statusCode) { }];
    
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            if (error == nil) {
                
                NSDate* updatedAt = [responseBody objectForKey:@"updatedAt"];
                
                success(updatedAt);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
        }
        
    }];
    
    [task resume];
}

- (void)uploadToServerRelationsForObjectId:(NSString* ) objectId
                              forUrlString:(NSString* ) urlString
                               withHeaders:(NSDictionary* ) headers
                                withParameters:(NSDictionary* ) parameters
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
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            if (error == nil) {
                
                NSDate* updatedAt = [responseBody objectForKey:@"updatedAt"];
                
                success(updatedAt);
                
            } else {
                
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            }
            
        } else {
            
//            NSLog(@"There is no connection to server");
        }
        
    }];
    
    [task resume];
}

- (void)updateCategoriesFromUser:(ITBUser* ) user
                       onSuccess:(void(^)(NSDate* updatedAt)) success
                       onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": user.sessionToken,
                               @"content-type": json };
    
    NSMutableArray* selectedCategoriesArray = [NSMutableArray array];
    
    for (ITBCategory* category in user.selectedCategories) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBCategory", @"className",
                              category.objectId, @"objectId", nil];
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"selectedCategories": selectedCategoriesArray };
    
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

#pragma mark - Delete methods
/*
- (void) deleteRelationsForNewsItem:(ITBNews* ) newsItem {
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBNews/%@", newsItem.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"Delete" } };
    
    [self updateObject:newsItem.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
     }
             onFailure:^(NSError *error, NSInteger statusCode) { }];
    
}

- (void) deleteRelationsForCategory:(ITBCategory* ) category
{
    
    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/classes/ITBCategory/%@", category.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSDictionary *parameters = @{ @"news": @{ @"__op": @"Delete" },
                                  @"signedUsers": @{ @"__op": @"Delete" } };
    
    [self updateObject:category.objectId
           withHeaders:headers
            withFields:parameters
          forUrlString:urlString
             onSuccess:^(NSDate *updatedAt)
     {
         
     }
             onFailure:^(NSError *error, NSInteger statusCode)
     {
         
         
     }];
}
 
 
 
 - (void) deleteRelationsForUser:(ITBUser* ) user {
 
 NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users/%@", user.objectId];
 
 NSDictionary *headers = @{ @"x-parse-application-id": appId,
 @"x-parse-rest-api-key": restApiKey,
 @"x-parse-session-token": user.sessionToken,
 @"content-type": json };
 
 NSDictionary *parameters = @{ @"likedNews": @{ @"__op": @"Delete" } };
 
 [self updateObject:user.objectId
 withHeaders:headers
 withFields:parameters
 forUrlString:urlString
 onSuccess:^(NSDate *updatedAt) { }
 onFailure:^(NSError *error, NSInteger statusCode) { }];
 }
*/


@end
