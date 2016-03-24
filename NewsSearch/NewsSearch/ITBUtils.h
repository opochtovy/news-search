//
//  ITBUtils.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 03.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    
    ITBSortingTypeHot,
    ITBSortingTypeNew,
    ITBSortingTypeCreated,
    ITBSortingTypeFavourites,
    ITBSortingTypeGeolocation
    
} ITBSortingType;

extern NSString * const login;
extern NSString * const logout;
extern NSString * const beforeLogin;

extern NSString * const kSettingsUsername;
extern NSString * const kSettingsObjectId;
extern NSString * const kSettingsSessionToken;
extern NSString * const kSettingsChosenSortingType;
extern NSString * const kSettingsChosenSortingName;
extern NSString * const kSettingsLatitude;
extern NSString * const kSettingsLongitude;

extern NSString * const appId;
extern NSString * const restApiKey;
extern NSString * const json;
extern NSString * const jpg;
extern NSString * const baseUrl;

extern CLLocationDistance const maxDistance;
extern CLLocationDegrees const grodnoLatitude;
extern CLLocationDegrees const grodnoLongitude;
extern CLLocationDegrees const minskLatitude;
extern CLLocationDegrees const minskLongitude;

extern NSString * const ITBUserEntityName;
extern NSString * const ITBNewsEntityName;
extern NSString * const ITBCategoryEntityName;
extern NSString * const ITBPhotoEntityName;

extern NSString * const classesUrl;
extern NSString * const usersUrl;

extern NSString * const noConnectionTitle;
extern NSString * const noConnectionMessage;
extern NSString * const okAction;
extern NSString * const contextSavingError;
extern NSString * const bgContextSavingError;

extern NSString * const nothingPredicateFormat;
extern NSString * const frcRatingDescriptorKey;
extern NSString * const createdAtDescriptorKey;
extern NSString * const titleDescriptorKey;

extern NSString * const bgImage;

extern NSString * const resultsDictKey;
extern NSString * const codeDictKey;
extern NSString * const objectIdDictKey;
extern NSString * const usernameDictKey;
extern NSString * const passwordDictKey;
extern NSString * const likedNewsDictKey;
extern NSString * const selectedCategoriesDictKey;
extern NSString * const titleDictKey;
extern NSString * const messageDictKey;
extern NSString * const latitudeDictKey;
extern NSString * const longitudeDictKey;
extern NSString * const authorDictKey;
extern NSString * const categoryDictKey;
extern NSString * const likeAddedUsersDictKey;
extern NSString * const photosDictKey;
extern NSString * const thumbnailPhotosDictKey;
extern NSString * const signedUsersDictKey;
extern NSString * const nameDictKey;
extern NSString * const urlDictKey;

extern NSString * const updateObjectMethodSelector;
extern NSString * const initObjectMethodSelector;
extern NSString * const objectForKeyMethodSelector;

NSDate* convertToNSDateFromUTC(NSDate *utcDate);

NSDictionary* checkNetworkHeaders(NSString *sessionToken);
NSDictionary* getHeaders();
NSDictionary* postHeaders(NSString *contentType);
NSDictionary* userRelationsHeaders(NSString *sessionToken, NSString *contentType);

NSDictionary* classDict(NSString *classNameType, NSString *objectId);


