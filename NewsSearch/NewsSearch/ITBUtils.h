//
//  ITBUtils.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 03.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    ITBSortingTypeHot, // 0
    ITBSortingTypeNew, // 1
    ITBSortingTypeCreated, // 2
    ITBSortingTypeFavourites // 3
    
} ITBSortingType;

typedef enum {
    
    ITBObjectSynced = 0,
    ITBObjectCreated,
    ITBObjectDeleted,
    
} ITBObjectSyncStatus;

extern NSString * const login;
extern NSString * const logout;
extern NSString * const beforeLogin;

extern NSString * const kSettingsUsername;
extern NSString * const kSettingsObjectId;
extern NSString * const kSettingsSessionToken;
extern NSString * const kSettingsChosenSortingType;
extern NSString * const kSettingsChosenSortingName;

extern NSString * const appId;
extern NSString * const restApiKey;
extern NSString * const json;
extern NSString * const jpg;
extern NSString * const baseUrl;

NSDate* convertToNSDateFromUTC(NSDate *utcDate);


