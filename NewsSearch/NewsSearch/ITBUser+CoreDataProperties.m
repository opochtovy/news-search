//
//  ITBUser+CoreDataProperties.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 24.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBUser+CoreDataProperties.h"

@implementation ITBUser (CoreDataProperties)

@dynamic createdAt;
@dynamic objectId;
@dynamic updatedAt;
@dynamic username;
@dynamic sessionToken;
@dynamic code;
@dynamic error;
@dynamic createdNews;
@dynamic likedNews;
@dynamic selectedCategories;

@end
