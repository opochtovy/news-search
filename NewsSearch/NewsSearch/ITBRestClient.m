//
//  ITBRestClient.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBRestClient.h"

#import "ITBUtils.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"
#import "ITBPhoto.h"

@interface ITBRestClient ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ITBRestClient

#pragma mark - Lifecycle

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    }
    
    return self;
}

#pragma mark - Public

- (void)makeRequestToServerForUrlString:(NSString *)urlString withHeaders:(NSDictionary *)headers withFields:(NSDictionary *)parameters withHTTPBody:(NSData *)data withHTTPMethod:(NSString *)method onSuccess:(void(^)(NSDictionary *responseBody))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod = method;
    
    if (headers != nil) {
        
        [request setAllHTTPHeaderFields:headers];
        
    }
    
    if (parameters != nil) {
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        [request setHTTPBody:postData];
        
    }
    
    if (data != nil) {
        
        [request setHTTPBody:data];
        
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
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

- (void)loadImageForURL:(NSString *)url onSuccess:(void(^)(UIImage *image))success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:0 error:&error];
        
        if (error) {
            
            failure(error, error.code);
            
        } else {
            
            UIImage *image = [UIImage imageWithData:imageData];
            
            success(image);
        }
        
    });
}

- (void)uploadToServerRelationsForObjectId:(NSString *)objectId forUrlString:(NSString *)urlString withHeaders:(NSDictionary *)headers withParameters:(NSDictionary *)parameters onSuccess:(void(^)(NSDate *updatedAt))success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod = @"PUT";
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            if (error == nil) {
                
                NSDate *updatedAt = [responseBody objectForKey:@"updatedAt"];
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

- (void)uploadToServerUserRelationsForCurrentUser:(ITBUser *)user onSuccess:(void(^)(NSDate *updatedAt))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/users/%@", user.objectId];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": user.sessionToken,
                               @"content-type": json };
    
    NSMutableArray *likedNewsArray = [NSMutableArray array];
    
    for (ITBNews *newsItem in user.likedNews) {
        
        NSDictionary *dict = @{ @"__type": @"Pointer",
                                @"className": @"ITBNews",
                                @"objectId": newsItem.objectId };
        
        [likedNewsArray addObject:dict];
    }
    
    NSMutableArray *selectedCategoriesArray = [NSMutableArray array];
    
    for (ITBCategory *category in user.selectedCategories) {
        
        NSDictionary *dict = @{ @"__type": @"Pointer",
                                @"className": @"ITBCategory",
                                @"objectId": category.objectId };
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"likedNews": likedNewsArray,
                                  @"selectedCategories": selectedCategoriesArray};
    
    [self updateObject:user.objectId withHeaders:headers withFields:parameters forUrlString:urlString onSuccess:^(NSDate *updatedAt) {
        
        success(updatedAt);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

// эти методы осталось переделать
- (void)uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser *)user onSuccess:(void(^)(BOOL isSuccess))success {
    
    dispatch_group_t group = dispatch_group_create();
    
    [self getCurrentUser:user.objectId onSuccess:^(NSDictionary *dict) {
        
        NSDictionary *headers = @{ @"x-parse-application-id": appId,
                                   @"x-parse-rest-api-key": restApiKey,
                                   @"content-type": json };
        
        NSMutableArray *oldLikedNewsDicts = [[dict objectForKey:@"likedNews"] mutableCopy];
        
        NSMutableArray *newLikedNewsArray = [[user.likedNews allObjects] mutableCopy];
        
        if ([newLikedNewsArray count] == 0) {
            
            if ([oldLikedNewsDicts count] == 0) {
                
            } else {
                
                for (NSDictionary *oldLikedNewsDict in oldLikedNewsDicts) {
                    
                    NSString *objectId = [oldLikedNewsDict objectForKey:@"objectId"];
                    
                    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                    
                    NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"Remove", @"objects": @[user.objectId] } };
                    
                    dispatch_group_enter(group);
                    [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                        
                        dispatch_group_leave(group);
                        
                    } onFailure:^(NSError *error, NSInteger statusCode) {
                        
                        dispatch_group_leave(group);
                    }];
                    
                }
            }
            
        } else {
            
            if ([oldLikedNewsDicts count] == 0) {
                
                for (ITBNews *newsItem in newLikedNewsArray) {
                    
                    NSString *objectId = newsItem.objectId;
                    
                    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                    
                    NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"AddUnique", @"objects": @[user.objectId] } };
                    
                    dispatch_group_enter(group);
                    [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                        
                        dispatch_group_leave(group);
                        
                    } onFailure:^(NSError *error, NSInteger statusCode) {
                        
                        dispatch_group_leave(group);
                    }];
                    
                }
                
            } else {
                
                for (int i = (int)[oldLikedNewsDicts count] - 1; i >= 0; i--) {
                    
                    NSDictionary *oldLikedNewsDict = [oldLikedNewsDicts objectAtIndex:i];
                    
                    for (int j = (int)[newLikedNewsArray count] - 1; j >= 0; j--) {
                        
                        ITBNews *newsItem = [newLikedNewsArray objectAtIndex:j];
                        
                        if ([newsItem.objectId isEqualToString:[oldLikedNewsDict objectForKey:@"objectId"]]) {
                            
                            [newLikedNewsArray removeObject:newsItem];
                            [oldLikedNewsDicts removeObject:oldLikedNewsDict];
                            
                        }
                    }
                }
                
                if ([oldLikedNewsDicts count] > 0) {
                    
                    for (NSDictionary *oldLikedNewsDict in oldLikedNewsDicts) {
                        
                        NSString *objectId = [oldLikedNewsDict objectForKey:@"objectId"];
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                        
                        NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"Remove", @"objects": @[user.objectId] } };
                        
                        dispatch_group_enter(group);
                        [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                            
                            dispatch_group_leave(group);
                            
                        } onFailure:^(NSError *error, NSInteger statusCode) {
                            
                            dispatch_group_leave(group);
                        }];
                    }
                } else if ([newLikedNewsArray count] > 0) {
                    
                    for (ITBNews *newsItem in newLikedNewsArray) {
                        
                        NSString *objectId = newsItem.objectId;
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews/%@", objectId];
                        
                        NSDictionary *parameters = @{ @"likeAddedUsers": @{ @"__op": @"AddUnique", @"objects": @[user.objectId] } };
                        
                        dispatch_group_enter(group);
                        [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                            
                            dispatch_group_leave(group);
                            
                        } onFailure:^(NSError *error, NSInteger statusCode) {
                            
                            dispatch_group_leave(group);
                        }];
                    }
                }
            }
        }
        
        NSMutableArray *oldSelectedCategoriesDicts = [[dict objectForKey:@"selectedCategories"] mutableCopy];
        
        NSMutableArray *newSelectedCategoriesArray = [[user.selectedCategories allObjects] mutableCopy];
        
        if ([newSelectedCategoriesArray count] == 0) {
            
            if ([oldSelectedCategoriesDicts count] != 0) {
                
                for (NSDictionary *oldSelectedCategoryDict in oldLikedNewsDicts) {
                    
                    NSString *objectId = [oldSelectedCategoryDict objectForKey:@"objectId"];
                    
                    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                    
                    NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"Remove", @"objects": @[user.objectId] } };
                    
                    dispatch_group_enter(group);
                    [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                        
                        dispatch_group_leave(group);
                        
                    } onFailure:^(NSError *error, NSInteger statusCode) {
                        
                        dispatch_group_leave(group);
                    }];
                }
            }
            
        } else {
            
            if ([oldSelectedCategoriesDicts count] == 0) {
                
                for (ITBCategory *category in newSelectedCategoriesArray) {
                    
                    NSString *objectId = category.objectId;
                    
                    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                    
                    NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"AddUnique", @"objects": @[user.objectId] } };
                    
                    dispatch_group_enter(group);
                    [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                        
                        dispatch_group_leave(group);
                        
                    } onFailure:^(NSError *error, NSInteger statusCode) {
                        
                        dispatch_group_leave(group);
                    }];
                }
                
            } else {
                
                for (int i = (int)[oldSelectedCategoriesDicts count] - 1; i>=0; i--) {
                    
                    NSDictionary *oldSelectedCategoryDict = [oldSelectedCategoriesDicts objectAtIndex:i];
                    
                    for (int j = (int)[newSelectedCategoriesArray count] - 1; j>=0; j--) {
                        
                        ITBCategory *category = [newSelectedCategoriesArray objectAtIndex:j];
                        
                        if ([category.objectId isEqualToString:[oldSelectedCategoryDict objectForKey:@"objectId"]]) {
                            
                            [newSelectedCategoriesArray removeObject:category];
                            [oldSelectedCategoriesDicts removeObject:oldSelectedCategoryDict];
                        }
                    }
                }
                
                if ([oldSelectedCategoriesDicts count] > 0) {
                    
                    for (NSDictionary *oldSelectedCategoryDict in oldSelectedCategoriesDicts) {
                        
                        NSString *objectId = [oldSelectedCategoryDict objectForKey:@"objectId"];
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                        
                        NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"Remove", @"objects": @[user.objectId] } };
                        
                        dispatch_group_enter(group);
                        [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                            
                            dispatch_group_leave(group);
                            
                        } onFailure:^(NSError *error, NSInteger statusCode) {
                            
                            dispatch_group_leave(group);
                            
                        }];
                    }
                    
                } else if ([newSelectedCategoriesArray count] > 0) {
                    
                    for (ITBCategory *category in newSelectedCategoriesArray) {
                        
                        NSString *objectId = category.objectId;
                        
                        NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory/%@", objectId];
                        
                        NSDictionary *parameters = @{ @"signedUsers": @{ @"__op": @"AddUnique", @"objects": @[user.objectId] } };
                        
                        dispatch_group_enter(group);
                        [self uploadToServerRelationsForObjectId:objectId forUrlString:urlString withHeaders:headers withParameters:parameters onSuccess:^(NSDate *updatedAt) {
                            
                            dispatch_group_leave(group);
                            
                        } onFailure:^(NSError *error, NSInteger statusCode) {
                            
                            dispatch_group_leave(group);
                            
                        }];
                    }
                }
            }
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    dispatch_group_enter(group);
    [self uploadToServerUserRelationsForCurrentUser:user onSuccess:^(NSDate *updatedAt) {
        
        dispatch_group_leave(group);
        
        success(YES);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        success(YES);
        
    });
}

- (void)getCurrentUser:(NSString *)objectId onSuccess:(void(^)(NSDictionary *dict))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/users/%@", objectId];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
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

- (void)updateObject:(NSString *)objectId withHeaders:(NSDictionary *)headers withFields:(NSDictionary *)parameters forUrlString:(NSString *)urlString onSuccess:(void(^)(NSDate *updatedAt))success onFailure:(void(^)(NSError *error, NSInteger statusCode))failure {
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod = @"PUT";
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSDictionary *responseBody = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
            
//        NSLog(@"JSON during getting NewsOnSuccess : %@", responseBody);
            
            if (error == nil) {
                
                NSDate *updatedAt = [responseBody objectForKey:@"updatedAt"];
                
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

@end
