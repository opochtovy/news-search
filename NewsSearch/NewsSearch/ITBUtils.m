//
//  ITBUtils.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 03.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBUtils.h"

#import <UIKit/UIKit.h>

NSString * const login = @"Login";
NSString * const logout = @"Logout";
NSString * const beforeLogin = @"You need to login for using our news network!";

NSString * const kSettingsUsername = @"username";
NSString * const kSettingsObjectId = @"objectId";
NSString * const kSettingsSessionToken = @"sessionToken";
NSString * const kSettingsChosenSortingType = @"chosenSortingType";
NSString * const kSettingsChosenSortingName = @"chosenSortingName";
NSString * const kSettingsLatitude = @"latitude";
NSString * const kSettingsLongitude = @"longitude";

NSString * const appId = @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn";
NSString * const restApiKey = @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B";
NSString * const json = @"application/json";
NSString * const jpg = @"image/jpeg";
NSString * const baseUrl = @"https://api.parse.com";

CLLocationDistance const maxDistance = 10000;
CLLocationDegrees const grodnoLatitude = 53.6884;
CLLocationDegrees const grodnoLongitude = 23.8258;
CLLocationDegrees const minskLatitude = 53.88;
CLLocationDegrees const minskLongitude = 27.56;

NSString * const ITBUserEntityName = @"ITBUser";
NSString * const ITBNewsEntityName = @"ITBNews";
NSString * const ITBCategoryEntityName = @"ITBCategory";
NSString * const ITBPhotoEntityName = @"ITBPhoto";

NSString * const classesUrl = @"https://api.parse.com/1/classes/";
NSString * const usersUrl = @"https://api.parse.com/1/users";

NSString * const noConnectionTitle = @"No connection!";
NSString * const noConnectionMessage = @"There is no active connection to Internet";
NSString * const okAction = @"Ok";
NSString * const contextSavingError = @"Error saving mainContext:";
NSString * const bgContextSavingError = @"Error saving background context:";

NSString * const nothingPredicateFormat = @"nothing";
NSString * const frcRatingDescriptorKey = @"frcRating";
NSString * const createdAtDescriptorKey = @"createdAt";
NSString * const titleDescriptorKey = @"title";

NSString * const bgImage = @"bg_cork.png";

NSString * const resultsDictKey = @"results";
NSString * const objectIdDictKey = @"objectId";
NSString * const createdAtDictKey = @"createdAt";
NSString * const updatedAtDictKey = @"updatedAt";

NSString * const codeDictKey = @"code";
NSString * const errorDictKey = @"error";
NSString * const sessionTokenDictKey = @"sessionToken";
NSString * const usernameDictKey = @"username";
NSString * const passwordDictKey = @"password";
NSString * const likedNewsDictKey = @"likedNews";
NSString * const selectedCategoriesDictKey = @"selectedCategories";

NSString * const titleDictKey = @"title";
NSString * const messageDictKey = @"message";
NSString * const newsURLDictKey = @"newsURL";
NSString * const latitudeDictKey = @"latitude";
NSString * const longitudeDictKey = @"longitude";
NSString * const authorDictKey = @"author";
NSString * const categoryDictKey = @"category";
NSString * const likeAddedUsersDictKey = @"likeAddedUsers";
NSString * const photosDictKey = @"photos";
NSString * const thumbnailPhotosDictKey = @"thumbnailPhotos";
NSString * const signedUsersDictKey = @"signedUsers";

NSString * const nameDictKey = @"name";
NSString * const urlDictKey = @"url";

NSString * const updateObjectMethodSelector = @"updateObjectWithDictionary:inContext:";
NSString * const initObjectMethodSelector = @"initObjectWithDictionary:inContext:";
NSString * const objectForKeyMethodSelector = @"objectForKey:";

NSDate* convertToNSDateFromUTC(NSDate *utcDate) {
    
    NSString *string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

NSDictionary* checkNetworkHeaders(NSString *sessionToken) {
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": sessionToken };
    
    return headers;
}

NSDictionary* getHeaders() {
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey };
    
    return headers;
}

NSDictionary* postHeaders(NSString *contentType) {
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"content-type": contentType };
    
    return headers;
}

NSDictionary* userRelationsHeaders(NSString *sessionToken, NSString *contentType) {
    
    NSDictionary *headers = @{ @"x-parse-application-id": appId,
                               @"x-parse-rest-api-key": restApiKey,
                               @"x-parse-session-token": sessionToken,
                               @"content-type": contentType };
    
    return headers;
}

NSDictionary* classDict(NSString *classNameType, NSString *objectId) {
    
    NSDictionary *dict = @{ @"__type": @"Pointer",
                               @"className": classNameType,
                               @"objectId": objectId };
    
    return dict;
}

UIAlertController* showAlertWithTitle(NSString *title, NSString *message) {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    return alert;
    
}
