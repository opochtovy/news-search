//
//  ITBCategory.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategory.h"
#import "ITBNews.h"
#import "ITBUser.h"

#import "ITBUtils.h"

@implementation ITBCategory

+ (id)initObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    ITBCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ITBCategory" inManagedObjectContext:context];
    
    category.title = [userDict objectForKey:@"title"];
    category.objectId = [userDict objectForKey:@"objectId"];
    
    category.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    category.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
    
    return category;
}

- (void)updateObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    self.title = [userDict objectForKey:@"title"];
    self.objectId = [userDict objectForKey:@"objectId"];
    
    self.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    self.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
}

@end
