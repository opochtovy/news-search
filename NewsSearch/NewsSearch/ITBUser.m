//
//  ITBUser.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBUser.h"
#import "ITBCategory.h"
#import "ITBNews.h"

#import "ITBUtils.h"

#import "NSManagedObject+ITBUpdateObjectWithDict.h"

@implementation ITBUser

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    ITBUser *user = [NSEntityDescription insertNewObjectForEntityForName:ITBUserEntityName inManagedObjectContext:context];
    
    user.username = [dict objectForKey:usernameDictKey];
    user.objectId = [dict objectForKey:objectIdDictKey];
    user.sessionToken = [dict objectForKey:sessionTokenDictKey];
    
    user.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    user.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
    
    user.code = [dict objectForKey:codeDictKey];
    user.error = [dict objectForKey:errorDictKey];
    
    return user;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    self.username = [dict objectForKey:usernameDictKey];
    self.objectId = [dict objectForKey:objectIdDictKey];
    self.sessionToken = [dict objectForKey:sessionTokenDictKey];
    
    self.createdAt = convertToNSDateFromUTC([dict objectForKey:createdAtDictKey]);
    self.updatedAt = convertToNSDateFromUTC([dict objectForKey:updatedAtDictKey]);
    
    self.code = [dict objectForKey:codeDictKey];
    self.error = [dict objectForKey:errorDictKey];
}

@end
