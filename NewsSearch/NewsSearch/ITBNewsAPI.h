//
//  ITBNewsAPI.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class ITBNews, ITBCategory, ITBUser, ITBPhoto;

@interface ITBNewsAPI : NSObject

@property (strong, nonatomic) ITBUser *currentUser;

+ (ITBNewsAPI *)sharedInstance;

- (NSManagedObjectContext *)getContextForFRC;
- (void)saveBgContext;

- (void)saveCurrentUser;
- (void)loadCurrentUser;

- (void)logOut;

- (void)checkNetworkConnectionOnSuccess:(void(^)(BOOL isConnected))success;
- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(ITBUser *user, BOOL isConnected))success;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(BOOL isConnected))success;
- (void)getUsersOnSuccess:(void(^)(NSSet *usernames, BOOL isConnected))success;

- (void)loadImageForUrlString:(NSString *)urlString onSuccess:(void(^)(NSData *data))success;

- (void)createNewObjectsForPhotoDataArray:(NSArray *)photos thumbnailPhotoDataArray:(NSArray *)thumbnailPhotos onSuccess:(void(^)(NSDictionary *responseBody))success;
- (void)createCustomNewsForTitle:(NSString *)title message:(NSString *)message categoryTitle:(NSString *)categoryTitle photosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(BOOL isSuccess))success;
- (void)uploadPhotosForCreatingNewsToServerForPhotoDataArray:(NSArray *)photoDataArray thumbnailPhotoDataArray:(NSArray *)thumbnailPhotoDataArray photoObjectsArray:(NSArray *)photosArray thumbnailPhotoObjectsArray:(NSArray *)thumbnailPhotosArray onSuccess:(void(^)(NSDictionary *responseBody))success;

- (void)createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success;
- (void)updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success;

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectsForEntity:(NSString *)entityName usingContext:(NSManagedObjectContext *)context;

- (NSArray *)fetchObjectsInBackgroundForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate;

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess))success;

- (void)deleteNewsItem:(ITBNews *)newsItem;

@end
