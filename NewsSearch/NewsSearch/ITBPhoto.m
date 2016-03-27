//
//  ITBPhoto.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBPhoto.h"
#import "ITBNews.h"

#import "ITBUtils.h"
#import "ITBNewsAPI.h"

@implementation ITBPhoto

+ (id)initObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context {
    
    ITBPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:@"ITBPhoto" inManagedObjectContext:context];
    
    photo.name = [photoDict objectForKey:@"name"];
    photo.url = [photoDict objectForKey:@"url"];
    photo.objectId = [photoDict objectForKey:@"objectId"];
    
    return photo;
}

- (void)updateObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context {
    
    self.name = [photoDict objectForKey:@"name"];
    self.url = [photoDict objectForKey:@"url"];
    self.objectId = [photoDict objectForKey:@"objectId"];
}

@end
