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
@class ITBLoginViewController;

@interface ITBServerManager : NSObject

@property (strong, nonatomic) ITBUser *currentUser;

+ (ITBServerManager *)sharedManager;

- (void)authorizeUserByRequest;


- (void)authorizeUserOnSuccess:(void(^)(ITBUser* user)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)logoutUserOnSuccess:(void(^)(ITBUser* user)) success
                     onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getNewsOnSuccess:(void(^)(NSArray *news)) success
                   onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;


@end
