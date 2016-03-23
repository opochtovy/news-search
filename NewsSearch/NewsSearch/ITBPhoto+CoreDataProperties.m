//
//  ITBPhoto+CoreDataProperties.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBPhoto+CoreDataProperties.h"

@implementation ITBPhoto (CoreDataProperties)

@dynamic name;
@dynamic objectId;
@dynamic url;
@dynamic imageData;
@dynamic newsWithPhoto;
@dynamic newsWithThumbnailPhoto;

@end
