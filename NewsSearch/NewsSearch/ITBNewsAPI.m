//
//  ITBNewsAPI.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI.h"

#import "ITBUtils.h"

#import "ITBRestClient.h"
#import "ITBCoreDataManager.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"
#import "ITBPhoto.h"

static NSString * const defaultTitle = @"News";

static NSString * const checkNetworkUrl = @"https://api.parse.com/1/users/me";
static NSString * const authorizationUrl = @"https://api.parse.com/1/login?&username=";
static NSString * const passwordSection = @"&password=";
static NSString * const filesUrl = @"https://api.parse.com/1/files/";

static NSString * const userClass = @"_User";
static NSString * const testValue = @"test";

static NSString * const photoNamePath = @"photo";
static NSString * const thumbPhotoNamePath = @"thumbnailPhoto";
static NSString * const jpgExtension = @".jpg";

static NSString * const uploadPhotoError = @"There is no valid photo";

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

- (NSManagedObjectContext *)bgManagedObjectContext {
    
    if (_bgManagedObjectContext == nil) {
        
        _bgManagedObjectContext = [_coreDataManager bgManagedObjectContext];
        [_bgManagedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    }
    
    return _bgManagedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveMainContext {
    
    [self.coreDataManager saveMainContext];
}

- (void)saveBgContext {
    
    [[self.coreDataManager bgManagedObjectContext] performBlockAndWait:^{
        
        [self.coreDataManager saveBgContext];
        
    }];
    
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
        NSArray *users = [self.coreDataManager fetchObjectsForName:ITBUserEntityName withSortDescriptor:nil predicate:predicate inContext:self.mainManagedObjectContext];
        
        self.currentUser = [users firstObject];
        
    }
}

#pragma mark - Public

- (void)checkNetworkConnectionOnSuccess:(void(^)(BOOL isConnected))success {
    
    if (self.currentUser.sessionToken != nil) {
        
        NSDictionary *headers = checkNetworkHeaders(self.currentUser.sessionToken);
        
        [self.restClient makeRequestToServerForUrlString:checkNetworkUrl withHeaders:headers withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            BOOL isConnected = (responseBody == nil) ? NO : YES;
            
            success(isConnected);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        [self loadCurrentUser];
        
        success(NO);
    }
}

- (void)authorizeWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(ITBUser *user, BOOL isConnected))success {
    
    NSString *urlString = [NSString stringWithFormat: @"%@%@%@%@", authorizationUrl, username, passwordSection, password];
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
        
        NSInteger code = [[responseBody objectForKey:codeDictKey] integerValue];
        
        if (responseBody == nil) {
            
            success(nil, NO);
            
        } else if (code == 0) {
            
            NSString *objectId = [responseBody objectForKey:objectIdDictKey];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];

            NSManagedObjectContext *context = self.mainManagedObjectContext;
            
            NSArray *users = [self.coreDataManager fetchObjectsForName:ITBUserEntityName withSortDescriptor:nil predicate:predicate inContext:context];
            
            ITBUser *user = [users firstObject];
            
            [user updateObjectWithDictionary:responseBody inContext:context];
            
            if (user == nil) {
                
                user = [ITBUser initObjectWithDictionary:responseBody inContext:context];
            }
            
            self.currentUser = user;
            [self saveCurrentUser];

            [self saveMainContext];
            
            success(user, YES);
            
        } else {
            
            success(nil, YES);
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password onSuccess:(void(^)(BOOL isConnected))success {
    
    NSDictionary *parameters = @{ usernameDictKey: username,
                                  passwordDictKey: password };
    
    [self.restClient makeRequestToServerForUrlString:usersUrl withHeaders:postHeaders(json) withFields:parameters withHTTPBody:nil withHTTPMethod:@"POST" onSuccess:^(NSDictionary *responseBody) {
        
        BOOL isConnected = (responseBody == nil) ? NO : YES;
        
        success(isConnected);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void)getUsersOnSuccess:(void(^)(NSSet *usernames, BOOL isConnected))success {
    
    [self.restClient makeRequestToServerForUrlString:usersUrl withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
        
        if (responseBody == nil) {
            
            success(nil, NO);
            
        } else {
            
            NSArray *dictsArray = [responseBody objectForKey:resultsDictKey];
            
            NSMutableArray *usernamesArray = [NSMutableArray array];
            
            for (NSDictionary *dict in dictsArray) {
                
                NSString *username = [dict objectForKey:usernameDictKey];
                
                [usernamesArray addObject:username];
            }
            
            NSSet *usernamesSet = [NSSet setWithArray:usernamesArray];
            
            success(usernamesSet, YES);
            
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (void)createNewObjectsForPhotoDataArray:(NSArray *)photos thumbnailPhotoDataArray:(NSArray *)thumbnailPhotos onSuccess:(void(^)(NSDictionary *responseBody))success {
    
    if ([photos count] == 0) {
        
        success(nil);
        
    } else {
        
        NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
        
        [context performBlock:^{
            
            NSMutableArray *photosArray = [NSMutableArray array];
            NSMutableArray *thumbnailPhotosArray = [NSMutableArray array];
            
            dispatch_group_t group = dispatch_group_create();
            
            for (int i=0; i < [photos count]; i++) {
                
                NSData *photoData = [photos objectAtIndex:i];
                
                dispatch_group_enter(group);
                [self createPhotoOnServerOnSuccess:^(ITBPhoto *photo) {
                    
                    photo.imageData = photoData;
                    
                    [photosArray addObject:photo];
                    
                    dispatch_group_leave(group);
                    
                }];
                
                NSData *thumbnailPhotoData = [thumbnailPhotos objectAtIndex:i];
                
                dispatch_group_enter(group);
                [self createPhotoOnServerOnSuccess:^(ITBPhoto *photo) {
                    
                    photo.imageData = thumbnailPhotoData;
                    
                    [thumbnailPhotosArray addObject:photo];
                    
                    dispatch_group_leave(group);
                    
                }];
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                
                NSDictionary *allPhotos = @{photosDictKey: [photosArray copy], thumbnailPhotosDictKey: [thumbnailPhotosArray copy]};
                
                success(allPhotos);
                
            });
            
        }];
        
    }
}

- (void)createCustomNewsForTitle:(NSString *)title message:(NSString *)message categoryTitle:(NSString *)categoryTitle photosArray:(NSArray *)photos thumbnailPhotos:(NSArray *)thumbnailPhotos onSuccess:(void(^)(BOOL isSuccess))success {
    
    NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
    
    [context performBlock:^{
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBNewsEntityName];
        
        NSDictionary *headers = postHeaders(json);
        
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"title == %@", categoryTitle];
        NSArray *categories = [self.coreDataManager fetchObjectsForName:ITBCategoryEntityName withSortDescriptor:nil predicate:categoryPredicate inContext:context];
        ITBCategory *category = [categories firstObject];
        
        NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.currentUser.objectId];
        NSArray *users = [self.coreDataManager fetchObjectsForName:ITBUserEntityName withSortDescriptor:nil predicate:userPredicate inContext:context];
        ITBUser *user = [users firstObject];
        
        NSMutableArray *photosArray = [NSMutableArray array];
        for (ITBPhoto *photo in photos) {
            
            NSDictionary *dict = classDict(ITBPhotoEntityName, photo.objectId);
            
            [photosArray addObject:dict];
        }
        
        NSMutableArray *thumbnailPhotosArray = [NSMutableArray array];
        for (ITBPhoto *thumbnailPhoto in thumbnailPhotos) {
            
            NSDictionary *dict = classDict(ITBPhotoEntityName, thumbnailPhoto.objectId);
            
            [thumbnailPhotosArray addObject:dict];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *latNumber = [userDefaults objectForKey:kSettingsLatitude];
        NSNumber *longNumber = [userDefaults objectForKey:kSettingsLongitude];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     title, titleDictKey,
                                     message, messageDictKey,
                                     (latNumber != nil) ? latNumber : [NSNumber numberWithDouble:grodnoLatitude], latitudeDictKey,
                                     (longNumber != nil) ? longNumber : [NSNumber numberWithDouble:grodnoLongitude], longitudeDictKey,
                                     classDict(userClass, self.currentUser.objectId), authorDictKey,
                                     classDict(ITBCategoryEntityName, category.objectId), categoryDictKey, nil];
        
        if ([photos count] > 0) {
            
            [dict setObject:photosArray forKey:photosDictKey];
            [dict setObject:thumbnailPhotosArray forKey:thumbnailPhotosDictKey];
        }
        
        NSDictionary *parameters = [dict copy];
        
        [self.restClient makeRequestToServerForUrlString:urlString withHeaders:headers withFields:parameters withHTTPBody:nil withHTTPMethod:@"POST" onSuccess:^(NSDictionary *responseBody) {
            
            ITBNews *newsItem = [ITBNews initObjectWithDictionary:responseBody inContext:context];
            newsItem.title = title;
            newsItem.message = message;
            
            newsItem.author = user;
            newsItem.category = category;
            
            for (ITBPhoto *photo in photos) {
                
                [newsItem addPhotosObject:photo];
                
                ITBPhoto *thumbnailPhoto = [thumbnailPhotos objectAtIndex:[photos indexOfObject:photo]];
                [newsItem addThumbnailPhotosObject:thumbnailPhoto];
            }
            
            [self.coreDataManager saveBgContext];
            
            success(YES);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }];
}

- (void)uploadPhotosForCreatingNewsToServerForPhotoDataArray:(NSArray *)photoDataArray thumbnailPhotoDataArray:(NSArray *)thumbnailPhotoDataArray photoObjectsArray:(NSArray *)photosArray thumbnailPhotoObjectsArray:(NSArray *)thumbnailPhotosArray onSuccess:(void(^)(NSDictionary *responseBody))success {
    
    NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
    
    [context performBlock:^{
    
        dispatch_group_t group = dispatch_group_create();
        
        for (NSData *photoData in photoDataArray) {
            
            NSInteger photoIndex = [photoDataArray indexOfObject:photoData];
            
            NSString *photoName = [NSString stringWithFormat:@"%@%i%@", photoNamePath, (int)photoIndex, jpgExtension];
            
            if (photoData != nil) {
                
                dispatch_group_enter(group);
                [self uploadPhotoToServerForName:photoName withData:photoData onSuccess:^(NSDictionary *responseBody) {
                    
                    if (responseBody != nil) {
                        
                        NSString *name = [responseBody objectForKey:nameDictKey];
                        NSString *url = [responseBody objectForKey:urlDictKey];
                        
                        ITBPhoto *photo = [photosArray objectAtIndex:photoIndex];
                        photo.name = name;
                        photo.url = url;
                        
                        NSDictionary *parameters = @{ nameDictKey: name,
                                                      urlDictKey: url };
                        
                        [self udpatePhotoOnServerForObjectId:photo.objectId withFields:parameters onSuccess:^(BOOL isSuccess) {
                            
                            dispatch_group_leave(group);
                            
                        }];
                        
                    } else {
                        
                        dispatch_group_leave(group);
                    }
                    
                    NSData *thumbnailPhotoData = [thumbnailPhotoDataArray objectAtIndex:photoIndex];
                    
                    NSString *thumbnailPhotoName = [NSString stringWithFormat:@"%@%i%@", thumbPhotoNamePath, (int)photoIndex, jpgExtension];
                    
                    if (thumbnailPhotoData != nil) {
                        
                        dispatch_group_enter(group);
                        [self uploadPhotoToServerForName:thumbnailPhotoName withData:thumbnailPhotoData onSuccess:^(NSDictionary *responseBody) {
                            
                            if (responseBody != nil) {
                                
                                NSString *name = [responseBody objectForKey:nameDictKey];
                                NSString *url = [responseBody objectForKey:urlDictKey];
                                
                                ITBPhoto *thumbnailPhoto = [thumbnailPhotosArray objectAtIndex:photoIndex];
                                thumbnailPhoto.name = name;
                                thumbnailPhoto.url = url;
                                
                                NSDictionary *parameters = @{ nameDictKey: name,
                                                              urlDictKey: url };
                                
                                [self udpatePhotoOnServerForObjectId:thumbnailPhoto.objectId withFields:parameters onSuccess:^(BOOL isSuccess) {
                                    
                                    dispatch_group_leave(group);
                                    
                                }];
                                
                            } else {
                                
                                dispatch_group_leave(group);
                            }
                            
                        }];
                    }
                    
                }];
            }
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            [self.coreDataManager saveBgContext];
            
            NSDictionary *allPhotos = nil;
            
            if ([photosArray count] > 0) {
                
                allPhotos = @{photosDictKey: [photosArray copy], thumbnailPhotosDictKey: [thumbnailPhotosArray copy]};
            }
            
            success(allPhotos);
            
        });
        
    }];
}

- (void)createPhotoOnServerOnSuccess:(void(^)(ITBPhoto *photo))success {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBPhotoEntityName];
    
    NSDictionary *parameters = @{ nameDictKey: testValue,
                                  urlDictKey: testValue };
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:postHeaders(json) withFields:parameters withHTTPBody:nil withHTTPMethod:@"POST" onSuccess:^(NSDictionary *responseBody) {
        
        NSString *objectId = [responseBody objectForKey:objectIdDictKey];
        
        if (objectId != nil) {
            
            ITBPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:ITBPhotoEntityName inManagedObjectContext:[self.coreDataManager bgManagedObjectContext]];
            
            photo.objectId = objectId;
            
            success(photo);
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)uploadPhotoToServerForName:(NSString *)name withData:(NSData *)data onSuccess:(void(^)(NSDictionary *responseBody))success {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", filesUrl, name];
    
    if (data != nil) {
        
        [self.restClient makeRequestToServerForUrlString:urlString withHeaders:postHeaders(jpg) withFields:nil withHTTPBody:data withHTTPMethod:@"POST" onSuccess:^(NSDictionary *responseBody) {
            
            success(responseBody);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        NSLog(@"%@", uploadPhotoError);
    }
    
}

- (void)udpatePhotoOnServerForObjectId:(NSString *)objectId withFields:(NSDictionary *)parameters onSuccess:(void(^)(BOOL isSuccess))success {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@", classesUrl, ITBPhotoEntityName, objectId];
    
    [self.restClient makeRequestToServerForUrlString:urlString withHeaders:postHeaders(json) withFields:parameters withHTTPBody:nil withHTTPMethod:@"PUT" onSuccess:^(NSDictionary *responseBody) {
            
            success(YES);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)createLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
    
    [context performBlock:^{
        
        dispatch_group_t group = dispatch_group_create();
        
        __block ITBUser *user;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *objectId = [userDefaults objectForKey:kSettingsObjectId];
        NSString *sessionToken = [userDefaults objectForKey:kSettingsSessionToken];
        
        NSString *userUrlString = [NSString stringWithFormat:@"%@/%@", usersUrl, objectId];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:userUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
            
            NSArray *users = [self.coreDataManager fetchObjectsForName:ITBUserEntityName withSortDescriptor:nil predicate:predicate inContext:context];
            
            user = [users firstObject];
            
            [user updateObjectWithDictionary:responseBody inContext:context];
            user.sessionToken = sessionToken;
            
            dispatch_group_leave(group);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            dispatch_group_leave(group);
        }];
        
        NSString *newsUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBNewsEntityName];
        
        __block NSArray *news = [NSArray array];
        __block NSArray *newsDicts = [NSArray array];
        
        __block NSArray *categories = [NSArray array];
        __block NSArray *categoryDicts = [NSArray array];
        
        __block NSArray *photos = [NSArray array];
        __block NSArray *photoDicts = [NSArray array];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:newsUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            newsDicts = [responseBody objectForKey:resultsDictKey];
            
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
        
        NSString *categoryUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBCategoryEntityName];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:categoryUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            categoryDicts = [responseBody objectForKey:resultsDictKey];
            
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
        
        NSString *photoUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBPhotoEntityName];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:photoUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            photoDicts = [responseBody objectForKey:resultsDictKey];
            
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
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            [self.coreDataManager addRelationsToLocalDBFromNewsDictsArray:newsDicts forNewsArray:news fromCategoryDictsArray:categoryDicts forCategoriesArray:categories fromPhotoDictsArray:photoDicts forPhotosArray:photos forUser:user usingContext:context onSuccess:^(BOOL isSuccess) {
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                success(isSuccess);
                
            }];
 
        });
        
    }];
}

- (void)getFromServerUpdatedDictsArray:(NSMutableArray *)updatedDictsArray withUpdatedLocalObjectsArray:(NSMutableArray *)updatedArray usingFromServerDictsArray:(NSMutableArray *)dictsArray withLocalObjectsArray:(NSMutableArray *)array forClass:(id)EntityClass inContext:(NSManagedObjectContext *)context {
    
    for (int i = (int)[dictsArray count] - 1; i>=0; i--) {
        
        NSDictionary *dict = [dictsArray objectAtIndex:i];
        
        for (int j = (int)[array count] - 1; j>=0; j--) {
            
            id object = [array objectAtIndex:j];
            
            NSString *objectId = nil;
            if (object != nil) {
                
                SEL selector = NSSelectorFromString(objectIdDictKey);
                IMP imp = [object methodForSelector:selector];
                NSString *(*func)(id, SEL) = (void *)imp;
                objectId = func(object, selector);
                
            }
            
            if ([objectId isEqualToString:[dict objectForKey:objectIdDictKey]]) {
                
                [updatedArray addObject:object];
                [updatedDictsArray addObject:dict];
                
                [array removeObject:object];
                [dictsArray removeObject:dict];
                
            }
        }
    }
    
    for (NSDictionary *dict in updatedDictsArray) {
        
        id object = [updatedArray objectAtIndex:[updatedDictsArray indexOfObject:dict]];
        
        if (object != nil) {
            
            SEL selector = NSSelectorFromString(updateObjectMethodSelector);
            IMP imp = [object methodForSelector:selector];
            void (*func)(id, SEL, NSDictionary *, NSManagedObjectContext *) = (void *)imp;
            func(object, selector, dict, context);
            
        }
    }
    
    if ([array count] > 0) {
        
        for (id object in array) {
            [context deleteObject:object];
        }
    }
    
    if ([dictsArray count] > 0) {
        
        for (NSDictionary *dict in dictsArray) {
            
            if (EntityClass != nil) {
                
                SEL selector = NSSelectorFromString(initObjectMethodSelector);
                IMP imp = [EntityClass methodForSelector:selector];
                id (*func)(id, SEL, NSDictionary *, NSManagedObjectContext *) = (void *)imp;
                id object = EntityClass ? func(EntityClass, selector, dict, context) : nil;
                
                [updatedArray addObject:object];
                [updatedDictsArray addObject:dict];
                
            }
        }
    }
}

- (void)updateLocalDataSourceOnSuccess:(void(^)(BOOL isSuccess))success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
    
    [context performBlock:^{
        
        dispatch_group_t group = dispatch_group_create();
        
        __block NSMutableArray *updatedNewsDicts = [NSMutableArray array];
        __block NSMutableArray *updatedNews = [NSMutableArray array];
        __block NSMutableArray *updatedCategoryDicts = [NSMutableArray array];
        __block NSMutableArray *updatedCategories = [NSMutableArray array];
        __block NSMutableArray *updatedPhotoDicts = [NSMutableArray array];
        __block NSMutableArray *updatedPhotos = [NSMutableArray array];
        __block ITBUser *user;
        
        NSString *userUrlString = [NSString stringWithFormat:@"%@/%@", usersUrl, self.currentUser.objectId];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:userUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.currentUser.objectId];
            NSArray *users = [self.coreDataManager fetchObjectsForName:ITBUserEntityName withSortDescriptor:nil predicate:predicate inContext:context];
            
            user = [users firstObject];
            [user updateObjectWithDictionary:responseBody inContext:context];
            user.sessionToken = self.currentUser.sessionToken;
            
            dispatch_group_leave(group);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            dispatch_group_leave(group);
            
        }];
        
        NSString *newsUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBNewsEntityName];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:newsUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            NSMutableArray *newsDicts = [[responseBody objectForKey:resultsDictKey] mutableCopy];
            NSMutableArray *newsArray = [ [self.coreDataManager allObjectsForName:ITBNewsEntityName usingContext:context] mutableCopy];
            
            [self getFromServerUpdatedDictsArray:updatedNewsDicts withUpdatedLocalObjectsArray:updatedNews usingFromServerDictsArray:newsDicts withLocalObjectsArray:newsArray forClass:[ITBNews class] inContext:context];
            
            dispatch_group_leave(group);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            dispatch_group_leave(group);
        }];
        
        NSString *categoryUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBCategoryEntityName];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:categoryUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            NSMutableArray *categoryDicts = [[responseBody objectForKey:resultsDictKey] mutableCopy];
            NSMutableArray *categoriesArray = [ [self.coreDataManager allObjectsForName:ITBCategoryEntityName usingContext:context] mutableCopy];
            
            [self getFromServerUpdatedDictsArray:updatedCategoryDicts withUpdatedLocalObjectsArray:updatedCategories usingFromServerDictsArray:categoryDicts withLocalObjectsArray:categoriesArray forClass:[ITBCategory class] inContext:context];
            
            dispatch_group_leave(group);
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
            dispatch_group_leave(group);
        }];
        
        NSString *photoUrlString = [NSString stringWithFormat:@"%@%@", classesUrl, ITBPhotoEntityName];
        
        dispatch_group_enter(group);
        [self.restClient makeRequestToServerForUrlString:photoUrlString withHeaders:getHeaders() withFields:nil withHTTPBody:nil withHTTPMethod:@"GET" onSuccess:^(NSDictionary *responseBody) {
            
            NSMutableArray *photoDicts = [[responseBody objectForKey:resultsDictKey] mutableCopy];
            NSMutableArray *photosArray = [ [self.coreDataManager allObjectsForName:ITBPhotoEntityName usingContext:context] mutableCopy];
            
            [self getFromServerUpdatedDictsArray:updatedPhotoDicts withUpdatedLocalObjectsArray:updatedPhotos usingFromServerDictsArray:photoDicts withLocalObjectsArray:photosArray forClass:[ITBPhoto class] inContext:context];
            
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
        
    }];
}

- (void)logOut {
    
    self.currentUser = nil;
    [self saveCurrentUser];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@0 forKey:kSettingsChosenSortingType];
    [userDefaults setObject:defaultTitle forKey:kSettingsChosenSortingName];
}

- (void)loadImageForUrlString:(NSString *)urlString onSuccess:(void(^)(NSData *data))success {
    
    [self.restClient loadDataForUrlString:urlString onSuccess:^(NSData *data) {
        
        success(data);
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    
    return [self.coreDataManager fetchObjectsForName:entityName withSortDescriptor:descriptors predicate:predicate inContext:context];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entityName usingContext:(NSManagedObjectContext *)context {
    
    return [self.coreDataManager allObjectsForName:entityName usingContext:context];
    
}

- (NSArray *)fetchObjectsInBackgroundForEntity:(NSString *)entityName withSortDescriptors:(NSArray *)descriptors predicate:(NSPredicate *)predicate {
    
    NSManagedObjectContext *context = [self.coreDataManager bgManagedObjectContext];
    
    __block NSArray *result;
    
    [context performBlockAndWait:^{
        
        result = [self.coreDataManager fetchObjectsForName:entityName withSortDescriptor:descriptors predicate:predicate inContext:context];
        
    }];
    
    return result;
}

- (void)updateCurrentUserFromLocalToServerOnSuccess:(void(^)(BOOL isSuccess))success {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (self.currentUser.sessionToken != nil) {
        
        [self.restClient uploadRatingAndSelectedCategoriesFromLocalToServerForCurrentUser:self.currentUser onSuccess:^(BOOL isSuccess) {
            
            success(isSuccess);
            
        }];
    }
}

@end
