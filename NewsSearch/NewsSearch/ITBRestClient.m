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

@end
