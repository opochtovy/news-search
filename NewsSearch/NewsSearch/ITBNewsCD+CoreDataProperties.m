//
//  ITBNewsCD+CoreDataProperties.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 17.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ITBNewsCD+CoreDataProperties.h"

@implementation ITBNewsCD (CoreDataProperties)

@dynamic createdAt;
@dynamic newsURL;
@dynamic objectId;
@dynamic title;
@dynamic updatedAt;
@dynamic rating;
@dynamic author;
@dynamic category;
@dynamic likeAddedUsers;

/*
- (void)setFirstName:(NSString *)firstName {
    
    //    _firstName = firstName; // !!!!!! такую строку нельзя написать !!!!!!!!!
    
    [self willChangeValueForKey:@"firstName"];
    
    [self setPrimitiveValue:firstName forKey:@"firstName"];
    
    [self didChangeValueForKey:@"firstName"];
}
*/

- (void)addLikeAddedUsersObject:(ITBUserCD *)value {
    
    [self willChangeValueForKey:@"likeAddedUsers"];
    
    NSLog(@"rating was changed");
    
// @property (nullable, nonatomic, retain) NSSet<ITBUserCD *> *likeAddedUsers;
    NSMutableSet* set = [[self primitiveValueForKey:@"likeAddedUsers"] mutableCopy];
    [set addObject:value];
    [self setPrimitiveValue:[set copy] forKey:@"likeAddedUsers"];
    
    NSNumber* ratingNumber = [self primitiveValueForKey:@"rating"];
    NSInteger ratingInt = [ratingNumber integerValue];
    [self setPrimitiveValue:[NSNumber numberWithInteger:++ratingInt] forKey:@"rating"];
    
    [self didChangeValueForKey:@"likeAddedUsers"];
}


- (void)removeLikeAddedUsersObject:(ITBUserCD *)value {
    
    [self willChangeValueForKey:@"likeAddedUsers"];
    
    NSMutableSet* set = [[self primitiveValueForKey:@"likeAddedUsers"] mutableCopy];
    [set removeObject:value];
    [self setPrimitiveValue:[set copy] forKey:@"likeAddedUsers"];
    
    NSNumber* ratingNumber = [self primitiveValueForKey:@"rating"];
    NSInteger ratingInt = [ratingNumber integerValue];
    [self setPrimitiveValue:[NSNumber numberWithInteger:--ratingInt] forKey:@"rating"];
    
    [self didChangeValueForKey:@"likeAddedUsers"];
    
}
- (void)addLikeAddedUsers:(NSSet<ITBUserCD *> *)values {
    
    [self willChangeValueForKey:@"likeAddedUsers"];
    
    NSMutableSet* set = [[self primitiveValueForKey:@"likeAddedUsers"] mutableCopy];
    for (ITBUserCD* value in values) {
        [set addObject:value];
    }
    [self setPrimitiveValue:[set copy] forKey:@"likeAddedUsers"];
    
    NSNumber* ratingNumber = [self primitiveValueForKey:@"rating"];
    NSInteger ratingInt = [ratingNumber integerValue];
    [self setPrimitiveValue:[NSNumber numberWithInteger:ratingInt+[values count]] forKey:@"rating"];
    
    [self didChangeValueForKey:@"likeAddedUsers"];
    
}
- (void)removeLikeAddedUsers:(NSSet<ITBUserCD *> *)values {
    
    [self willChangeValueForKey:@"likeAddedUsers"];
    
    NSMutableSet* set = [[self primitiveValueForKey:@"likeAddedUsers"] mutableCopy];
    for (ITBUserCD* value in values) {
        [set removeObject:value];
    }
    [self setPrimitiveValue:[set copy] forKey:@"likeAddedUsers"];
    
    NSNumber* ratingNumber = [self primitiveValueForKey:@"rating"];
    NSInteger ratingInt = [ratingNumber integerValue];
    [self setPrimitiveValue:[NSNumber numberWithInteger:ratingInt-[values count]] forKey:@"rating"];
    
    [self didChangeValueForKey:@"likeAddedUsers"];

}

@end
