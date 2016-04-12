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

static NSString * const urlSessionTaskError = @"URL Session Task Failed:";

static NSString * const addOperation = @"AddUnique";
static NSString * const removeOperation = @"Remove";

static NSString * const opDictKey = @"__op";
static NSString * const objectsDictKey = @"objects";

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
                
                NSLog(@"%@ %@", urlSessionTaskError, [error localizedDescription]);
            }
        } else {
            
            success(nil);
        }
        
    }];
    
    [task resume];
  
}

- (void)loadDataForUrlString:(NSString *)urlString onSuccess:(void(^)(NSData *data))success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSURLSessionDownloadTask *getImageTask = [self.session downloadTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            
            NSData *data = [NSData dataWithContentsOfURL:location];
            success(data);
            
        } else {
            success(nil);
        }
    }];
    
    [getImageTask resume];
    
}

- (void)changeObject:(id)object forEntityName:(NSString *)entityName inRelation:(NSString *)relation ofCurrentUser:(ITBUser *)user forGroup:(dispatch_group_t)group {
    
    NSString *objectId = nil;
    NSString *operation = addOperation;
    
    objectId = [object valueForKey:objectIdDictKey];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        
        operation = removeOperation;
    
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@", classesUrl, entityName, objectId];
    
    NSDictionary *parameters = @{ relation: @{ opDictKey: operation, objectsDictKey: @[user.objectId] } };
    
    dispatch_group_enter(group);
    [self makeRequestToServerForUrlString:urlString withHeaders:postHeaders(json) withFields:parameters withHTTPBody:nil withHTTPMethod:@"PUT" onSuccess:^(NSDictionary *responseBody) {
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
        
    }];
}

- (void)uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:(ITBUser *)user onSuccess:(void(^)(BOOL isSuccess))success {
    
    __weak ITBRestClient *weakSelf = self;
    
    dispatch_group_t group = dispatch_group_create();
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", usersUrl, user.objectId];
    
    [self makeRequestToServerForUrlString:urlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
        
        NSMutableArray *oldLikedNewsDicts = [[responseBody objectForKey:likedNewsDictKey] mutableCopy];
        
        NSMutableArray *newLikedNewsArray = [[user.likedNews allObjects] mutableCopy];
        
        if ( ([oldLikedNewsDicts count] > 0) && ([newLikedNewsArray count] > 0) ) {
            
            for (int i = (int)[oldLikedNewsDicts count] - 1; i >= 0; i--) {
                
                NSDictionary *oldLikedNewsDict = [oldLikedNewsDicts objectAtIndex:i];
                
                for (int j = (int)[newLikedNewsArray count] - 1; j >= 0; j--) {
                    
                    ITBNews *newsItem = [newLikedNewsArray objectAtIndex:j];
                    
                    if ([newsItem.objectId isEqualToString:[oldLikedNewsDict objectForKey:objectIdDictKey]]) {
                        
                        [newLikedNewsArray removeObject:newsItem];
                        [oldLikedNewsDicts removeObject:oldLikedNewsDict];
                        
                    }
                }
            }
        }
        
        if ([newLikedNewsArray count] > 0) {
            
            for (ITBNews *newsItem in newLikedNewsArray) {
                
                [weakSelf changeObject:newsItem forEntityName:ITBNewsEntityName inRelation:likeAddedUsersDictKey ofCurrentUser:user forGroup:group];
            }
            
        }
        
        if ([oldLikedNewsDicts count] > 0) {
            
            for (NSDictionary *oldLikedNewsDict in oldLikedNewsDicts) {
                
                [weakSelf changeObject:oldLikedNewsDict forEntityName:ITBNewsEntityName inRelation:likeAddedUsersDictKey ofCurrentUser:user forGroup:group];
            }
        }
        
        NSMutableArray *oldSelectedCategoriesDicts = [[responseBody objectForKey:selectedCategoriesDictKey] mutableCopy];
        
        NSMutableArray *newSelectedCategoriesArray = [[user.selectedCategories allObjects] mutableCopy];
        
        if ( ([oldSelectedCategoriesDicts count] > 0) && ([newSelectedCategoriesArray count] > 0) ) {
            
            for (int i = (int)[oldSelectedCategoriesDicts count] - 1; i>=0; i--) {
                
                NSDictionary *oldSelectedCategoryDict = [oldSelectedCategoriesDicts objectAtIndex:i];
                
                for (int j = (int)[newSelectedCategoriesArray count] - 1; j>=0; j--) {
                    
                    ITBCategory *category = [newSelectedCategoriesArray objectAtIndex:j];
                    
                    if ([category.objectId isEqualToString:[oldSelectedCategoryDict objectForKey:objectIdDictKey]]) {
                        
                        [newSelectedCategoriesArray removeObject:category];
                        [oldSelectedCategoriesDicts removeObject:oldSelectedCategoryDict];
                    }
                }
            }
            
        }
        
        if ([newSelectedCategoriesArray count] > 0) {
            
            for (ITBCategory *category in newSelectedCategoriesArray) {
                
                [weakSelf changeObject:category forEntityName:ITBCategoryEntityName inRelation:signedUsersDictKey ofCurrentUser:user forGroup:group];
            }
            
        }
        
        if ([oldSelectedCategoriesDicts count] > 0) {
            
            for (NSDictionary *oldSelectedCategoryDict in oldSelectedCategoriesDicts) {
                
                [weakSelf changeObject:oldSelectedCategoryDict forEntityName:ITBCategoryEntityName inRelation:signedUsersDictKey ofCurrentUser:user forGroup:group];
                
            }
            
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    NSDictionary *userRelationsHeadersDict = userRelationsHeaders(user.sessionToken, json);
    
    NSMutableArray *likedNewsArray = [NSMutableArray array];
    
    for (ITBNews *newsItem in user.likedNews) {
        
        NSDictionary *dict = classDict(ITBNewsEntityName, newsItem.objectId);
        
        [likedNewsArray addObject:dict];
    }
    
    NSMutableArray *selectedCategoriesArray = [NSMutableArray array];
    
    for (ITBCategory *category in user.selectedCategories) {
        
        NSDictionary *dict = classDict(ITBCategoryEntityName, category.objectId);
        
        [selectedCategoriesArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ likedNewsDictKey: likedNewsArray,
                                  selectedCategoriesDictKey: selectedCategoriesArray};
    
    dispatch_group_enter(group);
    [self makeRequestToServerForUrlString:urlString withHeaders:userRelationsHeadersDict withFields:parameters withHTTPBody:nil withHTTPMethod:@"PUT" onSuccess:^(NSDictionary *responseBody) {
        
        dispatch_group_leave(group);
        
        success(YES);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        success(YES);
        
    });
}

@end
