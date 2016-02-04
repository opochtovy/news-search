//
//  ITBServerManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// 1.1.1 - это класс singleton для общения с сервером

#import <Foundation/Foundation.h>

@class ITBUser;
@class ITBLoginViewController;

@interface ITBServerManager : NSObject

// 1.1.2 - конструктор singleton
+ (ITBServerManager *)sharedManager;

- (void)authorizeUserForLogin:(ITBLoginViewController *) loginVC
                             onSuccess:(void(^)(ITBUser *user)) success
            onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)postUserOnSuccess:(void(^)(ITBUser *user))success
                onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

@end
