//
//  ITBRestClient.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ITBNews;
@class ITBCategory;
@class ITBUser;

@interface ITBRestClient : NSObject

- (void)makeRequestToServerForUrlString:(NSString *)urlString withHeaders:(NSDictionary *)headers withFields:(NSDictionary *)parameters withHTTPBody:(NSData *)data withHTTPMethod:(NSString *)method onSuccess:(void(^)(NSDictionary *responseBody))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;
- (void)loadDataForUrlString:(NSString *)urlString onSuccess:(void(^)(NSData *data))success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser *)user onSuccess:(void(^)(BOOL isSuccess))success;

@end
