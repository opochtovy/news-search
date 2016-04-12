//
//  NSManagedObject+ITBUpdateObjectWithDict.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 31.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ITBUpdateObjectWithDict)

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end
