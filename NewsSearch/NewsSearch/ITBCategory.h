//
//  ITBCategory.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ITBNews, ITBUser;

NS_ASSUME_NONNULL_BEGIN

@interface ITBCategory : NSManagedObject

+ (id)initObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "ITBCategory+CoreDataProperties.h"
