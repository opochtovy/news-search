//
//  ITBNews+CoreDataProperties.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 28.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBNews+CoreDataProperties.h"

@implementation ITBNews (CoreDataProperties)

@dynamic createdAt;
@dynamic newsURL;
@dynamic objectId;
@dynamic rating;
@dynamic title;
@dynamic updatedAt;
@dynamic isLikedByCurrentUser;
@dynamic author;
@dynamic category;
@dynamic likeAddedUsers;

@end
