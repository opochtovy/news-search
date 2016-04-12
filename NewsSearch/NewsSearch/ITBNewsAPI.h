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

@property (assign, nonatomic) BOOL isSomethingInDBSaving;

+ (ITBNewsAPI *)sharedInstance;

- (void)saveBgContext;
- (NSManagedObjectContext *)getMainContext;

- (void)saveCurrentUser;
- (void)loadCurrentUser;

- (void)logOut;

- (void)checkNetworkConnectionOnSuccess:(void(^)(BOOL isConnected))success;
- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password rememberSwitchValue:(BOOL)isRemember onSuccess:(void(^)(ITBUser *user, BOOL isConnected))success;
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

- (NSArray *)fetchObjectsForMainContextForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate;

- (void)deleteNewsItemInBgContextForObjectId:(NSString *)objectId;

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess))success;

- (void)hideSharingButtonsForNews:(NSArray *)objectIDsArray withCompletionHandler:(void(^)(BOOL isSuccess))completionHandler;
- (void)showLocalDatabaseForNews:(NSArray *)objectIDsArray withCompletionHandler:(void(^)(BOOL isSuccess))completionHandler;
- (void)refreshNewsWithCompletionHandler:(void(^)(BOOL isSuccess))completionHandler;

- (NSFetchRequest *)prepareFetchRequestForFRC;

- (void)getNewsCellForNewsObjectID:(NSManagedObjectID *)objectID;
- (void)newsCellDidSelectTitleForNewsObjectID:(NSManagedObjectID *)objectID withCompletionHandler:(void(^)(BOOL isSuccess))completionHandler;
- (void)newsCellDidSelectHide:(NSManagedObjectID *)objectID withCompletionHandler:(void(^)(BOOL isSuccess))completionHandler;
- (void)newsCellDidAddToFavouritesForNewsObjectID:(NSManagedObjectID *)objectID;
- (void)prefetchValidByGeolocationNewsWithCompletionHandler:(void(^)(NSArray *newsArray))completion;

@end
