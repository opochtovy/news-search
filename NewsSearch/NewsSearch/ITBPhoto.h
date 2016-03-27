//
//  ITBPhoto.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 15.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class ITBNews;

NS_ASSUME_NONNULL_BEGIN

@interface ITBPhoto : NSManagedObject

+ (id)initObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context;

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "ITBPhoto+CoreDataProperties.h"
