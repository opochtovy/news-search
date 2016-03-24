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

- (void)updateObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    self.title = [userDict objectForKey:@"title"];
    self.message = [userDict objectForKey:@"message"];
    self.newsURL = [userDict objectForKey:@"newsURL"];
    self.objectId = [userDict objectForKey:@"objectId"];
    
    self.latitude = [userDict objectForKey:@"latitude"];
    self.longitude = [userDict objectForKey:@"longitude"];
    
    self.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    self.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
    
    NSInteger ratingInt = [[userDict objectForKey:@"likeAddedUsers"] count];
    self.rating = [NSNumber numberWithInteger:ratingInt];
    
    self.frcRating = self.rating;
}

@end
