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

//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
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
/*
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
         
         } else {
         
         // Failure
         NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
         }
    }];
    
    [task resume];
}
*/

// getting news after login as user
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
        
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
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

@end
