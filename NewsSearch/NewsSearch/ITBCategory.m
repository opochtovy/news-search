//
//  ITBCategory.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 24.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBCategory.h"
#import "ITBNews.h"
#import "ITBUser.h"

@implementation ITBCategory

// Insert code here to add functionality to your managed object subclass

- (id)insertObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    ITBCategory* category = (ITBCategory* )[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"ITBCategory" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    
    if (category != nil) {
        
        category.title = [userDict objectForKey:@"title"];
        category.objectId = [userDict objectForKey:@"objectId"];
        
        category.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
        category.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
        
    }
    
    return category;
}

- (void)updateObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context
{
    
    self.title = [userDict objectForKey:@"title"];
    self.objectId = [userDict objectForKey:@"objectId"];
    
    self.createdAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"createdAt"]];
    self.updatedAt = [self convertToNSDateFromUTC:[userDict objectForKey:@"updatedAt"]];
}

- (NSDate* ) convertToNSDateFromUTC:(NSDate* ) utcDate {
    
    NSString* string = [NSString stringWithFormat:@"%@", utcDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *date = [formatter dateFromString:string];
    
    return date;
    
}

@end
