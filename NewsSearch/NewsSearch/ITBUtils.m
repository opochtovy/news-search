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

NSString * const appId = @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn";
NSString * const restApiKey = @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B";
NSString * const json = @"application/json";
NSString * const jpg = @"image/jpeg";
NSString * const baseUrl = @"https://api.parse.com";

NSDate* convertToNSDateFromUTC(NSDate *utcDate) {
    
    NSString *string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}
