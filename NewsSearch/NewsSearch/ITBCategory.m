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

#import "NSManagedObject+ITBUpdateObjectWithDict.h"

@implementation ITBCategory

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    ITBCategory *category = [NSEntityDescription insertNewObjectForEntityForName:ITBCategoryEntityName inManagedObjectContext:context];
    
    category.title = [dict objectForKey:titleDictKey];
    category.objectId = [dict objectForKey:objectIdDictKey];
    
    category.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    category.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
    
    return category;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    self.title = [dict objectForKey:titleDictKey];
    self.objectId = [dict objectForKey:objectIdDictKey];
    
    self.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    self.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
}

@end
