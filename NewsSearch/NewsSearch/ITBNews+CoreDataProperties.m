//
//  ITBNews+CoreDataProperties.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 01.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBNews+CoreDataProperties.h"

@implementation ITBNews (CoreDataProperties)

@dynamic createdAt;
@dynamic isLikedByCurrentUser;
@dynamic newsURL;
@dynamic objectId;
@dynamic rating;
@dynamic title;
@dynamic updatedAt;
@dynamic isTitlePressed;
@dynamic author;
@dynamic category;
@dynamic likeAddedUsers;
@dynamic toFavouritesAddedUsers;

@end
