//
//  ITBNews.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 22.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ITBCategory, ITBPhoto, ITBUser;

NS_ASSUME_NONNULL_BEGIN

@interface ITBNews : NSManagedObject

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "ITBNews+CoreDataProperties.h"
