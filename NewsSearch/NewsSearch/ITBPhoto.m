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

#import "NSManagedObject+ITBUpdateObjectWithDict.h"

@implementation ITBPhoto

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    ITBPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:ITBPhotoEntityName inManagedObjectContext:context];
    
    photo.name = [dict objectForKey:nameDictKey];
    photo.url = [dict objectForKey:urlDictKey];
    photo.objectId = [dict objectForKey:objectIdDictKey];
    
    return photo;
}

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context {
    
    self.name = [dict objectForKey:nameDictKey];
    self.url = [dict objectForKey:urlDictKey];
    self.objectId = [dict objectForKey:objectIdDictKey];
}

@end
