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

- (void)updateObjectWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context {
    
    self.username = [userDict objectForKey:@"username"];
    self.objectId = [userDict objectForKey:@"objectId"];
    self.sessionToken = [userDict objectForKey:@"sessionToken"];
    
    self.createdAt = convertToNSDateFromUTC([userDict objectForKey:@"createdAt"]);
    self.updatedAt = convertToNSDateFromUTC([userDict objectForKey:@"updatedAt"]);
    
    self.code = [userDict objectForKey:@"code"];
    self.error = [userDict objectForKey:@"error"];
}

@end
