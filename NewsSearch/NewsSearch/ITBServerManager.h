//
//  ITBServerManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// класс singleton для общения с сервером

#import <Foundation/Foundation.h>

@class ITBUser;
@class ITBNews;

@interface ITBServerManager : NSObject

@property (strong, nonatomic) ITBUser *currentUser;

+ (ITBServerManager *)sharedManager;

- (void)authorizeWithUsername:(NSString* ) username
         withPassword:(NSString* ) password
            onSuccess:(void(^)(ITBUser* user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)registerWithUsername:(NSString* ) username
                 withPassword:(NSString* ) password
                    onSuccess:(void(^)(ITBUser* user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getUsersOnSuccess:(void(^)(NSArray *users)) success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getNewsOnSuccess:(void(^)(NSArray *news)) success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)updateRatingFromUserForNewsItem:(ITBNews* ) news
                              onSuccess:(void(^)(NSDate* updatedAt)) success
                              onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)updateCategoriesFromUserOnSuccess:(void(^)(NSDate* updatedAt)) success
                                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;



@end
