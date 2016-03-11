//
//  ITBNewsAPI.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI.h"

#import <UIKit/UIKit.h>

#import "ITBUtils.h"

#import "ITBRestClient.h"
#import "ITBCoreDataManager.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"
#import "ITBPhoto.h"

static NSString * const kSettingsInitialCompleteKey = @"initialSyncCompleted";
static NSString * const kSettingsSyncCompletedNotificationName = @"syncCompleted";

@interface ITBNewsAPI ()

@property (strong, nonatomic) ITBRestClient *restClient;
@property (strong, nonatomic) ITBCoreDataManager *coreDataManager;

@end

@implementation ITBNewsAPI

#pragma mark - Lifecycle

+ (ITBNewsAPI *)sharedInstance {
    
    static ITBNewsAPI *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[ITBNewsAPI alloc] init];
        
    });
    
    return sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    if (self != nil) {
        
        _restClient = [[ITBRestClient alloc] init];
        
        _coreDataManager = [[ITBCoreDataManager alloc] init];
        
        _mainManagedObjectContext = [_coreDataManager mainManagedObjectContext];
        _syncManagedObjectContext = [_coreDataManager syncManagedObjectContext];
        
        [self loadCurrentUser];
        
    }
    return self;
}

#pragma mark - Custom Accessors

- (NSManagedObjectContext *)mainManagedObjectContext {
    
    if (_mainManagedObjectContext == nil) {
        
        _mainManagedObjectContext = [_coreDataManager mainManagedObjectContext];
    }
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)syncManagedObjectContext {
    
    if (_syncManagedObjectContext == nil) {
        
        _syncManagedObjectContext = [_coreDataManager syncManagedObjectContext];
    }
    
    return _syncManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveMainContext {
    
    [self.coreDataManager saveMainContext];
}

- (void)saveSyncContext {
    
    [self.coreDataManager saveSyncContext];
}

- (void)saveSaveContext {
    
    [self.coreDataManager saveSaveContext];
}

#pragma mark - NSUserDefaults
 
- (void)saveCurrentUser {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.currentUser.username forKey:kSettingsUsername];
    [userDefaults setObject:self.currentUser.objectId forKey:kSettingsObjectId];
    [userDefaults setObject:self.currentUser.sessionToken forKey:kSettingsSessionToken];
    
    [userDefaults synchronize];
}
 
- (void)loadCurrentUser {
 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *objectId = [userDefaults objectForKey:kSettingsObjectId];
    
    if (objectId != nil) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
        NSArray *users = [self.coreDataManager fetchObjectsForName:@"ITBUser" withSortDescriptor:nil predicate:predicate inContext:self.mainManagedObjectContext];
        self.currentUser = [users firstObject];
        
    }
}

#pragma mark - Public

- (void)checkNetworkConnectionOnSuccess:(void(^)(BOOL isSuccess))success {
    
    if (self.currentUser.sessionToken != nil) {
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/users/me"];
        NSString *method = @"GET";
        
        NSDictionary *headers = @{ @"x-parse-application-id": appId,
                                   @"x-parse-rest-api-key": restApiKey,
                                   @"x-parse-session-token": self.currentUser.sessionToken };
        
        [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
            
            NSString *username = [responseBody objectForKey:@"username"];
            
            if (username != nil) {
                
                success(YES);
                
            }
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        [self loadCurrentUser];
    }
}

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(ITBUser *user))success {
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@%@%@", @"https://api.parse.com/1/login?&username=", username, @"&password=", password];
    
    NSString *method = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSInteger code = [[responseBody objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            
            NSString *objectId = [responseBody objectForKey:@"objectId"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];

            NSManagedObjectContext *context = self.mainManagedObjectContext;
            
            NSArray *users = [self.coreDataManager fetchObjectsForName:@"ITBUser" withSortDescriptor:nil predicate:predicate inContext:context];
            
            [context performBlockAndWait:^{
                
                ITBUser *user = [users firstObject];
                
                [user updateObjectWithDictionary:responseBody inContext:context];
                
                if (user == nil) {
                    
                    user = [ITBUser initObjectWithDictionary:responseBody inContext:context];
                }
                
                self.currentUser = user;
                [self saveCurrentUser];
                
                [self saveMainContext];
                
                success(user);
                
            }];
            
        } else {
            
            success(nil);
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)uploadPhotosForCreatingNewsToServerForPhotosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(NSDictionary *responseBody))success {
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *photosArray = [NSMutableArray array];
    NSMutableArray *thumbnailPhotosArray = [NSMutableArray array];
    
    for (NSData *photoData in photos) {
        
        NSInteger index = [photos indexOfObject:photoData];
        
        NSString *photoName = [NSString stringWithFormat:@"photo%i.jpg", (int)index];
        
        if (photoData != nil) {
            
            dispatch_group_enter(group);
            [self uploadPhotoToServerForName:photoName withData:photoData onSuccess:^(NSDictionary *responseBody) {
                
                NSString *name = [responseBody objectForKey:@"name"];
                NSString *url = [responseBody objectForKey:@"url"];
                
                [self createPhotoOnServerForName:name url:url onSuccess:^(ITBPhoto *photo) {
                    
                    [photosArray addObject:photo];
                    
                    dispatch_group_leave(group);
                    
                }];
                
            }];
            
            
        }
        
        NSData *thumbnailPhotoData = [thumbnailPhotos objectAtIndex:index];
        
        NSString *thumbnailPhotoName = [NSString stringWithFormat:@"thumbPhoto%i.jpg", index];
        
        dispatch_group_enter(group);
        if (thumbnailPhotoData != nil) {
            
            [self uploadPhotoToServerForName:thumbnailPhotoName withData:thumbnailPhotoData onSuccess:^(NSDictionary *responseBody) {
                
                NSString *name = [responseBody objectForKey:@"name"];
                NSString *url = [responseBody objectForKey:@"url"];
                
                [self createPhotoOnServerForName:name url:url onSuccess:^(ITBPhoto *photo) {
                    
                    [thumbnailPhotosArray addObject:photo];
                    
                    dispatch_group_leave(group);
                    
                }];
                
            }];
            
            
        }
        
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSDictionary *allPhotos = @{@"photos": [photosArray copy], @"thumbnailPhotos": [thumbnailPhotosArray copy]};
        
        success(allPhotos);
        
    });
}

- (void)uploadPhotoToServerForName:(NSString *)name withData:(NSData *)data onSuccess:(void(^)(NSDictionary *responseBody))success {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/files/%@", name];
    
    NSString *method = @"POST";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": jpg };
    
    if (data != nil) {
        
        [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:nil withHTTPBody:data withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
            
            success(responseBody);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        NSLog(@"there is no valid photo");
    }
    
}

- (void)createCustomNewsForTitle:(NSString *)title message:(NSString *)message categoryTitle:(NSString *)categoryTitle photosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(BOOL isSuccess))success {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews"];
    
    NSString *method = @"POST";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", categoryTitle];
    NSArray *categories = [self.coreDataManager fetchObjectsForName:@"ITBCategory" withSortDescriptor:nil predicate:predicate inContext:[self.coreDataManager syncManagedObjectContext]];
    ITBCategory *category = [categories firstObject];
    
    NSMutableArray *photosArray = [NSMutableArray array];
    for (ITBPhoto *photo in photos) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBPhoto", @"className",
                              photo.objectId, @"objectId", nil];
        
        [photosArray addObject:dict];
    }
    
    NSMutableArray *thumbnailPhotosArray = [NSMutableArray array];
    for (ITBPhoto *thumbnailPhoto in thumbnailPhotos) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pointer", @"__type",
                              @"ITBPhoto", @"className",
                              thumbnailPhoto.objectId, @"objectId", nil];
        
        [thumbnailPhotosArray addObject:dict];
    }
    
    NSDictionary *parameters = @{ @"title": title,
                                  @"message": message,
                                  @"author": @{ @"__type": @"Pointer", @"className": @"_User", @"objectId": self.currentUser.objectId },
                                  @"category": @{ @"__type": @"Pointer", @"className": @"ITBCategory", @"objectId": category.objectId },
                                  @"photos": photosArray,
                                  @"thumbnailPhotos": thumbnailPhotosArray };
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:parameters withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        ITBNews *newsItem = [ITBNews initObjectWithDictionary:responseBody inContext:[self.coreDataManager syncManagedObjectContext]];
        newsItem.title = title;
        newsItem.message = message;
        
        NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.currentUser.objectId];
        NSArray *users = [self.coreDataManager fetchObjectsForName:@"ITBUser" withSortDescriptor:nil predicate:userPredicate inContext:[self.coreDataManager syncManagedObjectContext]];
        ITBUser *user = [users firstObject];
        
        newsItem.author = user;
        newsItem.category = category;
        for (ITBPhoto *photo in photos) {
            
            [newsItem addPhotosObject:photo];
            
            ITBPhoto *thumbnailPhoto = [thumbnailPhotos objectAtIndex:[photos indexOfObject:photo]];
            [newsItem addThumbnailPhotosObject:thumbnailPhoto];
        }
        
        [self saveSyncContext];
        [self saveSaveContext];
        
        success(YES);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    
}

- (void)createPhotoOnServerForName:(NSString *)name url:(NSString *)url onSuccess:(void(^)(ITBPhoto *photo))success {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBPhoto"];
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                                     @"x-parse-rest-api-key": restApiKey,
                                     @"content-type": json };
    
    NSDictionary *parameters = @{ @"name": name,
                                  @"url": url };
    
    NSString *method = @"POST";
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:parameters withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSString *objectId = [responseBody objectForKey:@"objectId"];
        
        if (objectId != nil) {
            
            ITBPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:@"ITBPhoto" inManagedObjectContext:[self.coreDataManager syncManagedObjectContext]];
            
            photo.objectId = objectId;
            photo.name = name;
            photo.url = url;
            
            success(photo);
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSManagedObjectContext *context = [self.coreDataManager syncManagedObjectContext];
    
    NSString *method = @"GET";
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    
    dispatch_group_t group = dispatch_group_create();
    
    __block ITBUser *user;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *objectId = [userDefaults objectForKey:kSettingsObjectId];
    NSString *sessionToken = [userDefaults objectForKey:kSettingsSessionToken];
    
    NSString *userUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/users/%@", objectId];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:userUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
        
        NSArray *users = [self.coreDataManager fetchObjectsForName:@"ITBUser" withSortDescriptor:nil predicate:predicate inContext:context];
        
        user = [users firstObject];
        
        [user updateObjectWithDictionary:responseBody inContext:context];
        user.sessionToken = sessionToken;
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    NSString *newsUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews"];
    
    __block NSArray *news = [NSArray array];
    __block NSArray *newsDicts = [NSArray array];
    
    __block NSArray *categories = [NSArray array];
    __block NSArray *categoryDicts = [NSArray array];
    
    __block NSArray *photos = [NSArray array];
    __block NSArray *photoDicts = [NSArray array];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:newsUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        newsDicts = [responseBody objectForKey:@"results"];
        
        NSMutableArray *newsArray = [NSMutableArray array];
        for (NSDictionary *newsDict in newsDicts) {
            
            ITBNews *newsItem = [ITBNews initObjectWithDictionary:newsDict inContext:context];
            
            [newsArray addObject:newsItem];
        }
        news = [newsArray copy];
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    NSString *categoryUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory"];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:categoryUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        categoryDicts = [responseBody objectForKey:@"results"];
        
        NSMutableArray *categoriesArray = [NSMutableArray array];
        for (NSDictionary *catDict in categoryDicts) {
            
            ITBCategory *category = [ITBCategory initObjectWithDictionary:catDict inContext:context];
            
            [categoriesArray addObject:category];
        }
        categories = [categoriesArray copy];
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    NSString *photoUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBPhoto"];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:photoUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        photoDicts = [responseBody objectForKey:@"results"];
        
        NSMutableArray *photosArray = [NSMutableArray array];
        for (NSDictionary *photoDict in photoDicts) {
            
            ITBPhoto *photo = [ITBPhoto initObjectWithDictionary:photoDict inContext:context];
            
            [photosArray addObject:photo];
        }
        photos = [photosArray copy];
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{

        [self.coreDataManager addRelationsToLocalDBFromNewsDictsArray:newsDicts forNewsArray:news fromCategoryDictsArray:categoryDicts forCategoriesArray:categories fromPhotoDictsArray:photoDicts forPhotosArray:photos forUser:user usingContext:context onSuccess:^(BOOL isSuccess) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            success(isSuccess);
            
        }];
        
    });
}

- (void)updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success {
    
    dispatch_group_t group = dispatch_group_create();
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSManagedObjectContext *context = [self.coreDataManager syncManagedObjectContext];
    
    NSString *method = @"GET";
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    
    __block NSMutableArray *updatedNewsDicts = [NSMutableArray array];
    __block NSMutableArray *updatedNews = [NSMutableArray array];
    __block NSMutableArray *updatedCategoryDicts = [NSMutableArray array];
    __block NSMutableArray *updatedCategories = [NSMutableArray array];
    __block NSMutableArray *updatedPhotoDicts = [NSMutableArray array];
    __block NSMutableArray *updatedPhotos = [NSMutableArray array];
    __block ITBUser *user;
    
    NSString *userUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/users/%@", self.currentUser.objectId];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:userUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.currentUser.objectId];
        
        NSArray *users = [self.coreDataManager fetchObjectsForName:@"ITBUser" withSortDescriptor:nil predicate:predicate inContext:context];
        user = [users firstObject];
        
        [user updateObjectWithDictionary:responseBody inContext:context];
        
        user.sessionToken = self.currentUser.sessionToken;
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
        
    }];
    
    // ITBNews - синхронизация атрибутов всех объектов класса ITBNews
    NSString *newsUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBNews"];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:newsUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSMutableArray *newsDicts = [[responseBody objectForKey:@"results"] mutableCopy];
        
        NSMutableArray *newsArray = [ [self.coreDataManager allObjectsForName:@"ITBNews" usingContext:context] mutableCopy];
        
        // наполнение массива updatedNews (и updatedNewsDicts)
        for (int i = (int)[newsDicts count] - 1; i>=0; i--) {
            
            NSDictionary *newsDict = [newsDicts objectAtIndex:i];
            
            for (int j = (int)[newsArray count] - 1; j>=0; j--) {
                
                ITBNews *newsItem = [newsArray objectAtIndex:j];
                
                if ([newsItem.objectId isEqualToString:[newsDict objectForKey:@"objectId"]]) {
                    
                    [updatedNews addObject:newsItem];
                    [updatedNewsDicts addObject:newsDict];
                    
                    [newsArray removeObject:newsItem];
                    [newsDicts removeObject:newsDict];
                    
                }
            }
        }
        
        NSMutableArray *deletedNews = newsArray;
        NSMutableArray *insertedNewsDicts = newsDicts;
        
        // updating of attributes
        for (NSDictionary *newsDict in updatedNewsDicts) {
            
            ITBNews *newsItem = [updatedNews objectAtIndex:[updatedNewsDicts indexOfObject:newsDict]];
            [newsItem updateObjectWithDictionary:newsDict inContext:context];
        }
        
        // creating of attributes for inserted news and merge updated and inserted objects (and dicts)
        if ([insertedNewsDicts count] > 0) {
            
            for (NSDictionary *newsDict in insertedNewsDicts) {
                
                ITBNews *newsItem = [ITBNews initObjectWithDictionary:newsDict inContext:context];
                
                [updatedNews addObject:newsItem];
                [updatedNewsDicts addObject:newsItem];
            }
        }
        
        // deleting
        if ([deletedNews count] > 0) {
            
            for (id object in deletedNews) {
                [context deleteObject:object];
            }
        }
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    // ITBCategory - синхронизация атрибутов всех объектов класса ITBCategory
    NSString *categoryUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBCategory"];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:categoryUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSArray *dictsArray = [responseBody objectForKey:@"results"];
        NSMutableArray *categoryDicts = [dictsArray mutableCopy];
        
        NSMutableArray *categoriesArray = [ [self.coreDataManager allObjectsForName:@"ITBCategory" usingContext:context] mutableCopy];
        
        // наполнение массива updatedCategories (и updatedCategoryDicts)
        for (int i = (int)[categoryDicts count] - 1; i>=0; i--) {
            
            NSDictionary *categoryDict = [categoryDicts objectAtIndex:i];
            
            for (int j = (int)[categoriesArray count] - 1; j>=0; j--) {
                
                ITBCategory *category = [categoriesArray objectAtIndex:j];
                
                if ([category.objectId isEqualToString:[categoryDict objectForKey:@"objectId"]]) {
                    
                    [updatedCategories addObject:category];
                    [updatedCategoryDicts addObject:categoryDict];
                    
                    [categoriesArray removeObject:category];
                    [categoryDicts removeObject:categoryDict];
                }
            }
        }
        
        NSMutableArray *deletedCategories = categoriesArray;
        NSMutableArray *insertedCategoryDicts = categoryDicts;
        
        // updating of attributes
        for (NSDictionary *categoryDict in updatedCategoryDicts) {
            
            ITBCategory *category = [updatedCategories objectAtIndex:[updatedCategoryDicts indexOfObject:categoryDict]];
            
            [category updateObjectWithDictionary:categoryDict inContext:context];
        }
        
        // creating of attributes for inserted categories and merge updated and inserted objects (and dicts)
        if ([insertedCategoryDicts count] > 0) {
            
            for (NSDictionary *catDict in insertedCategoryDicts) {
                
                ITBCategory *category = [ITBCategory initObjectWithDictionary:catDict inContext:context];
                
                [updatedCategories addObject:category];
                [updatedCategoryDicts addObject:catDict];
                
            }
        }
        
        // deleting
        if ([deletedCategories count] > 0) {
            
            for (id object in deletedCategories) {
                [context deleteObject:object];
            }
        }
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    // ITBPhoto - синхронизация атрибутов всех объектов класса ITBPhoto
    NSString *photoUrlString = [NSString stringWithFormat:@"https://api.parse.com/1/classes/ITBPhoto"];
    
    dispatch_group_enter(group);
    [self.restClient makeRequestToServerForUrlString:photoUrlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSArray *dictsArray = [responseBody objectForKey:@"results"];
        NSMutableArray *photoDicts = [dictsArray mutableCopy];
        
        NSMutableArray *photosArray = [ [self.coreDataManager allObjectsForName:@"ITBPhoto" usingContext:context] mutableCopy];
        
        // наполнение массива updatedPhotos (и updatedPhotoDicts)
        for (int i = (int)[photoDicts count] - 1; i>=0; i--) {
            
            NSDictionary *photoDict = [photoDicts objectAtIndex:i];
            
            for (int j = (int)[photosArray count] - 1; j>=0; j--) {
                
                ITBPhoto *photo = [photosArray objectAtIndex:j];
                
                if ([photo.objectId isEqualToString:[photoDict objectForKey:@"objectId"]]) {
                    
                    [updatedPhotos addObject:photo];
                    [updatedPhotoDicts addObject:photoDict];
                    
                    [photosArray removeObject:photo];
                    [photoDicts removeObject:photoDict];
                }
            }
        }
        
        NSMutableArray *deletedPhotos = photosArray;
        NSMutableArray *insertedPhotoDicts = photoDicts;
        
        // updating of attributes
        for (NSDictionary *photoDict in updatedPhotoDicts) {
            
            ITBPhoto *photo = [updatedPhotos objectAtIndex:[updatedPhotoDicts indexOfObject:photoDict]];
            
            [photo updateObjectWithDictionary:photoDict inContext:context];
        }
        
        // creating of attributes for inserted photos and merge updated and inserted objects (and dicts)
        if ([insertedPhotoDicts count] > 0) {
            
            for (NSDictionary *photoDict in insertedPhotoDicts) {
                
                ITBPhoto *photo = [ITBPhoto initObjectWithDictionary:photoDict inContext:context];
                
                [updatedPhotos addObject:photo];
                [updatedPhotoDicts addObject:photoDict];
                
            }
        }
        
        // deleting
        if ([deletedPhotos count] > 0) {
            
            for (id object in deletedPhotos) {
                [context deleteObject:object];
            }
        }
        
        dispatch_group_leave(group);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        dispatch_group_leave(group);
    }];
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [self.coreDataManager addRelationsToLocalDBFromNewsDictsArray:updatedNewsDicts forNewsArray:updatedNews fromCategoryDictsArray:updatedCategoryDicts forCategoriesArray:updatedCategories fromPhotoDictsArray:updatedPhotoDicts forPhotosArray:updatedPhotos forUser:user usingContext:context onSuccess:^(BOOL isSuccess) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            success(isSuccess);
            
        }];
        
    });
}

- (void)logOut {
    
    self.currentUser = nil;
    [self saveCurrentUser];
}

- (void)loadImageForURL:(NSString *)url onSuccess:(void(^)(UIImage *image))success {
    
    [self.restClient loadImageForURL:url onSuccess:^(UIImage *image) {
        
        success(image);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    
    return [self.coreDataManager fetchObjectsForName:entityName withSortDescriptor:descriptors predicate:predicate inContext:context];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName usingContext:(NSManagedObjectContext *)context {
    
    return [self.coreDataManager allObjectsForName:entityName usingContext:context];
    
}

- (NSArray *)newsInLocalDB {
    
    NSArray *result = [self.coreDataManager allObjectsForName:@"ITBNews" usingContext:self.mainManagedObjectContext];
    
    return result;
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(BOOL isSuccess))success {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/users"];
    
    NSString *method = @"POST";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": json };
    
    NSDictionary *parameters = @{ @"username": username,
                                  @"password": password };
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:parameters withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSString *objectId = [responseBody objectForKey:@"objectId"];
        
        BOOL isSucces = (objectId == nil) ? NO : YES;
        
        success(isSucces);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void)getUsersOnSuccess:(void(^)(NSSet *usernames))success {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.parse.com/1/users"];
    
    NSString *method = @"GET";
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:method onSuccess:^(NSDictionary *responseBody) {
        
        NSArray *dictsArray = [responseBody objectForKey:@"results"];
        
        NSMutableArray *usernamesArray = [NSMutableArray array];
        
        for (NSDictionary *dict in dictsArray) {
            
            NSString *username = [dict objectForKey:@"username"];
            
            [usernamesArray addObject:username];
        }
        
        NSSet *usernamesSet = [NSSet setWithArray:usernamesArray];
        
        success(usernamesSet);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess))success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.currentUser.sessionToken != nil) {
        
        [self.restClient uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:self.currentUser onSuccess:^(BOOL isSuccess) {
            
            success(isSuccess);
            
        }];
    }
}

// deletion of local db

- (void)deleteLocalDB {
    
    [self.coreDataManager deleteAllObjects];
}

- (void)deleteAllUsersLocally {
    
    [self.coreDataManager deleteAllUsers];
}

@end
