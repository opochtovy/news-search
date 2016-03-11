//
//  ITBNewsAPI.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class ITBNews, ITBCategory, ITBUser, ITBPhoto;

@interface ITBNewsAPI : NSObject

@property (strong, nonatomic) ITBUser *currentUser;

@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *syncManagedObjectContext;

+ (ITBNewsAPI *)sharedInstance;

- (void)saveSaveContext;
- (void)saveMainContext;

// NSUserDefaults
- (void)saveCurrentUser;
- (void)loadCurrentUser;

- (void)logOut;

// ITBRestClient
- (void)checkNetworkConnectionOnSuccess:(void(^)(BOOL isSuccess))success;
- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(ITBUser *user))success;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(BOOL isSuccess))success;
- (void)getUsersOnSuccess:(void(^)(NSSet *usernames))success;

- (void)loadImageForURL:(NSString *)url onSuccess:(void(^)(UIImage *image))success;

- (void)createCustomNewsForTitle:(NSString *)title message:(NSString *)message categoryTitle:(NSString *)categoryTitle photosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(BOOL isSuccess))success;
- (void)uploadPhotosForCreatingNewsToServerForPhotosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(NSDictionary *responseBody))success;
- (void)uploadPhotoToServerForName:(NSString *)name withData:(NSData *)data onSuccess:(void(^)(NSDictionary *responseBody))success;
- (void)createPhotoOnServerForName:(NSString *)name url:(NSString *)url onSuccess:(void(^)(ITBPhoto *photo))success;

// ITBCoreDataManager
- (void)createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success;
- (void)updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success;

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchObjectsForEntity:(NSString *)entityName usingContext:(NSManagedObjectContext *)context;

- (NSArray *)newsInLocalDB;

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess))success;


@end
