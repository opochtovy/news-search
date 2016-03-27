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

#import "NSManagedObject+updateObjectWithDict.h"

#import "ITBUtils.h"

@implementation ITBUser

+ (id)initObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    NSLog(@"user was created");
    
    ITBUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUser" inManagedObjectContext:context];
    
    user.username = [userDict objectForKey:@"username"];
    user.objectId = [userDict objectForKey:@"objectId"];
    user.sessionToken = [userDict objectForKey:@"sessionToken"];
    
    user.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    user.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
    
    user.code = [userDict objectForKey:@"code"];
    user.error = [userDict objectForKey:@"error"];
    
    return user;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    [super updateObjectWithDictionary:dict inContext:context];
    
    self.username = [dict objectForKey:@"username"];
    self.objectId = [dict objectForKey:@"objectId"];
    self.sessionToken = [dict objectForKey:@"sessionToken"];
    
    self.createdAt = convertToNSDateFromUTC([dict objectForKey:@"createdAt"]);
    self.updatedAt = convertToNSDateFromUTC([dict objectForKey:@"updatedAt"]);
    
    self.code = [dict objectForKey:@"code"];
    self.error = [dict objectForKey:@"error"];
}

@end
