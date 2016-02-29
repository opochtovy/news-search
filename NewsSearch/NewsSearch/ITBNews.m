//
//  ITBNews.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 28.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBUser.h"

@implementation ITBNews

// Insert code here to add functionality to your managed object subclass

- (id)insertObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    ITBNews* newsItem = (ITBNews* )[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"ITBNews" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    
    if (newsItem != nil) {
        
        newsItem.title = [userDict objectForKey:@"title"];
        newsItem.newsURL = [userDict objectForKey:@"newsURL"];
        newsItem.objectId = [userDict objectForKey:@"objectId"];
        
        newsItem.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
        newsItem.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
        
        NSInteger ratingInt = [[userDict objectForKey:@"likeAddedUsers"] count];
        NSLog(@"checking for rating = %li", (long)ratingInt);
        
        newsItem.rating = [NSNumber numberWithInteger:ratingInt];
        
    }
    
    return newsItem;
}

- (void)updateObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    self.title = [userDict objectForKey:@"title"];
    self.newsURL = [userDict objectForKey:@"newsURL"];
    self.objectId = [userDict objectForKey:@"objectId"];
    
    self.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
    self.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
    
    NSInteger ratingInt = [[userDict objectForKey:@"likeAddedUsers"] count];
    self.rating = [NSNumber numberWithInteger:ratingInt];
}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

@end
