//
//  ITBServerManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// 1.1.1 - это класс singleton для общения с сервером

#import "ITBServerManager.h"

#import "ITBUser.h"
#import "ITBNews.h"

NSString *const appId = @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn";
NSString *const restApiKey = @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B";
NSString *const contentApi = @"application/json";
NSString *const baseUrl = @"https://api.parse.com";

@interface ITBServerManager ()

//@property (strong, nonatomic) NSURL *baseUrl;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ITBServerManager

// 1.1.3
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
    
    if (self) {

//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:nil
                                                         delegateQueue:nil];
    }
    
    return self;
}

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
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@%@%@%@",
                           baseUrl,
                           @"/1/login?&username=",
                           username,
                           @"&password=",
                           password];
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn",
                               @"x-parse-rest-api-key": @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B" };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during authorization UserOnSuccess: %@", responseBody);
        
        if (error == nil) {

            ITBUser *user = [[ITBUser alloc] initWithServerResponse:responseBody];
            
            self.currentUser = user;
            
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
    
    NSDictionary *headers = @{ @"x-parse-application-id": @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn",
                               @"x-parse-rest-api-key": @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B",
                               @"content-type": @"application/json" };
    
    NSDictionary *parameters = @{ @"username": username,
                                  @"password": password };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        if (error == nil) {
            
            ITBUser *user = [[ITBUser alloc] initWithServerResponse:responseBody];
            
            self.currentUser = user;
            
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
    
    NSDictionary *headers = @{ @"x-parse-application-id": @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn",
                               @"x-parse-rest-api-key": @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B" };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
        NSArray* dictsArray = [responseBody objectForKey:@"results"];
        
        if (error == nil) {
            
            NSMutableArray *objectsArray = [NSMutableArray array];
            
            for (NSDictionary *dict in dictsArray) {
                
                ITBUser *user = [[ITBUser alloc] initWithServerResponse:dict];
                
                [objectsArray addObject:user];
            }
            
            if (success) {
                success([objectsArray copy]);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

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
    
    NSDictionary *headers = @{ @"x-parse-application-id": @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn",
                               @"x-parse-rest-api-key": @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B" };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask* task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        
        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
        
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
            
            if (success) {
                success([objectsArray copy]);
            }
            
        } else {
            
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    
    [task resume];
}

// update ITBNews object with specified fields in parameters 
- (void)updateObject:(NSString* ) objectId
                withFields:(NSDictionary* ) parameters
        forUrlString:(NSString* ) urlString
                   onSuccess:(void(^)(NSDate* updatedAt)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
//    NSString *urlString = [NSString stringWithFormat: @"https://api.parse.com/1/users"];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    request.HTTPMethod = @"PUT";
    
    NSDictionary *headers = @{ @"x-parse-application-id": @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn",
                               @"x-parse-rest-api-key": @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B",
                               @"content-type": @"application/json" };
/*
    NSDictionary *parameters = @{ @"username": username,
                                  @"password": password };
*/
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
