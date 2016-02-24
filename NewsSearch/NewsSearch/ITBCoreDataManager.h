//
//  ITBCoreDataManager.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 23.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@class ITBUser;

@interface ITBCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (ITBUser* )fetchCurrentUserForObjectId:(NSString* ) objectId;
- (NSArray* )fetchAllCategories;

@end
