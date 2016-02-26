//
//  ITBNews.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 24.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ITBCategory, ITBUser;

NS_ASSUME_NONNULL_BEGIN

@interface ITBNews : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (id)insertObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context;
- (void)updateObjectWithDictionary:(NSDictionary *) userDict inContext:(NSManagedObjectContext* ) context;

@end

NS_ASSUME_NONNULL_END

#import "ITBNews+CoreDataProperties.h"
