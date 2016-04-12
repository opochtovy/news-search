//
//  ITBNews.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 22.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBPhoto.h"
#import "ITBUser.h"

#import "ITBUtils.h"

#import "NSManagedObject+ITBUpdateObjectWithDict.h"

@implementation ITBNews

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    ITBNews *newsItem = [NSEntityDescription insertNewObjectForEntityForName:ITBNewsEntityName inManagedObjectContext:context];
    
    newsItem.title = [dict objectForKey:titleDictKey];
    newsItem.message = [dict objectForKey:messageDictKey];
    newsItem.newsURL = [dict objectForKey:newsURLDictKey];
    newsItem.objectId = [dict objectForKey:objectIdDictKey];
    
    newsItem.latitude = [dict objectForKey:latitudeDictKey];
    newsItem.longitude = [dict objectForKey:longitudeDictKey];
    
    newsItem.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    newsItem.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
    
    NSInteger ratingInt = [[dict objectForKey:likeAddedUsersDictKey] count];
    
    newsItem.rating = [NSNumber numberWithInteger:ratingInt];
    
    newsItem.frcRating = newsItem.rating;
    
    return newsItem;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    self.title = [dict objectForKey:titleDictKey];
    self.message = [dict objectForKey:messageDictKey];
    self.newsURL = [dict objectForKey:newsURLDictKey];
    self.objectId = [dict objectForKey:objectIdDictKey];
    
    self.latitude = [dict objectForKey:latitudeDictKey];
    self.longitude = [dict objectForKey:longitudeDictKey];
    
    self.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    self.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
    
    NSInteger ratingInt = [[dict objectForKey:likeAddedUsersDictKey] count];
    self.rating = [NSNumber numberWithInteger:ratingInt];
    
    self.frcRating = self.rating;
}

@end
