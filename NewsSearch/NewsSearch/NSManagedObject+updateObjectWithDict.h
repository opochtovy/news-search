//
//  NSManagedObject+updateObjectWithDict.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 25.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (updateObjectWithDict);

- (void)updateObjectWithDictionary:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end
