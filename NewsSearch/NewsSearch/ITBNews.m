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

#import "NSManagedObject+updateObjectWithDict.h"

#import "ITBUtils.h"

@implementation ITBNews

+ (id)initObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    ITBNews *newsItem = [NSEntityDescription insertNewObjectForEntityForName:@"ITBNews" inManagedObjectContext:context];
    
    newsItem.title = [userDict objectForKey:@"title"];
    newsItem.message = [userDict objectForKey:@"message"];
    newsItem.newsURL = [userDict objectForKey:@"newsURL"];
    newsItem.objectId = [userDict objectForKey:@"objectId"];
    
    newsItem.latitude = [userDict objectForKey:@"latitude"];
    newsItem.longitude = [userDict objectForKey:@"longitude"];
    
    newsItem.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    newsItem.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
    
    NSInteger ratingInt = [[userDict objectForKey:@"likeAddedUsers"] count];
    
    newsItem.rating = [NSNumber numberWithInteger:ratingInt];
    
    newsItem.frcRating = newsItem.rating;
    
    return newsItem;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    [super updateObjectWithDictionary:dict inContext:context];
    
    self.title = [dict objectForKey:@"title"];
    self.message = [dict objectForKey:@"message"];
    self.newsURL = [dict objectForKey:@"newsURL"];
    self.objectId = [dict objectForKey:@"objectId"];
    
    self.latitude = [dict objectForKey:@"latitude"];
    self.longitude = [dict objectForKey:@"longitude"];
    
    self.createdAt = convertToNSDateFromUTC([dict objectForKey:@"createdAt"]);
    self.updatedAt = convertToNSDateFromUTC([dict objectForKey:@"updatedAt"]);
    
    NSInteger ratingInt = [[dict objectForKey:@"likeAddedUsers"] count];
    self.rating = [NSNumber numberWithInteger:ratingInt];
    
    self.frcRating = self.rating;
}

@end
