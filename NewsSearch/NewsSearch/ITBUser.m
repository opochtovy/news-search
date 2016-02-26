//
//  ITBUser.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 25.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBUser.h"
#import "ITBCategory.h"
#import "ITBNews.h"

@implementation ITBUser

// Insert code here to add functionality to your managed object subclass

- (id)insertObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    //    ITBUser* user = [NSEntityDescription insertNewObjectForEntityForName:@"ITBUser" inManagedObjectContext:context];
    
    ITBUser* user = (ITBUser* )[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"ITBUser" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    
    if (user != nil) {
        
        user.username = [userDict objectForKey:@"username"];
        user.objectId = [userDict objectForKey:@"objectId"];
        user.sessionToken = [userDict objectForKey:@"sessionToken"];
        
        user.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
        user.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
        
        user.code = [userDict objectForKey:@"code"];
        user.error = [userDict objectForKey:@"error"];
        
    }
    
    return user;
}

- (void)updateObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    self.username = [userDict objectForKey:@"username"];
    self.objectId = [userDict objectForKey:@"objectId"];
    self.sessionToken = [userDict objectForKey:@"sessionToken"];
    
    self.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
    self.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
    
    self.code = [userDict objectForKey:@"code"];
    self.error = [userDict objectForKey:@"error"];
}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

@end
