//
//  ITBNewsAPI+TestMethods.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 29.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI.h"

@interface ITBNewsAPI (TestMethods)



// TEST



- (void)fetchCurrentUserForObjectId:(NSString* ) objectId;


- (void) printAllObjectsOfLocalDB;
- (void)fetchAllObjects;

// осталось отправить на сервер новый self.currentUser.categories
- (void) updateCategories;

@end
