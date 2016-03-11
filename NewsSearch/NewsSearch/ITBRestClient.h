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
- (void)loadImageForURL:(NSString *)url onSuccess:(void(^)(UIImage *image))success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

// осталось переделать
- (void)uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser *)user onSuccess:(void(^)(BOOL isSuccess))success;
//- (void)getCurrentUser:(NSString *)objectId onSuccess:(void(^)(NSDictionary *dict))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

@end
