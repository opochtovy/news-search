//
//  ITBRestClient.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITBNews;
@class ITBCategory;
@class ITBUser;

@interface ITBRestClient : NSObject

- (void)authorizeWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(NSDictionary* userDict)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)registerWithUsername:(NSString* ) username
                withPassword:(NSString* ) password
                   onSuccess:(void(^)(NSDictionary* userDict)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getUsersOnSuccess:(void(^)(NSArray *dicts)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end
