//
//  ITBNewsAPI+TestMethods.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 29.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsAPI+TestMethods.h"

#import "ITBRestClient.h"
#import "ITBCoreDataManager.h"

@interface ITBNewsAPI ()

@property (strong, nonatomic) ITBRestClient* restClient;
@property (strong, nonatomic) ITBCoreDataManager* coreDataManager;

@end

@implementation ITBNewsAPI (TestMethods)

- (void)deleteLocalDB
{
    [self.coreDataManager deleteAllObjects];
}

- (void)deleteAllUsersLocally
{
    
    [self.coreDataManager deleteAllUsers];
    
    //    NSManagedObjectContext* context = [self.coreDataManager getCurrentThreadContext];
    //
    //    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //
    //    NSEntityDescription *description = [NSEntityDescription
    //                                        entityForName:@"ITBUser"
    //                                        inManagedObjectContext:context];
    //
    //    [request setEntity:description];
    //
    //    NSError *requestError = nil;
    //
    //    NSArray *resultArray = [context executeFetchRequest:request error:&requestError];
    //
    //    for (id object in resultArray) {
    //
    //        [context deleteObject:object];
    //    }
    //    
    //    [self.coreDataManager saveCurrentContext:context];
}



- (void)fetchCurrentUserForObjectId:(NSString* ) objectId
{
    
    self.currentUser = [self.coreDataManager fetchCurrentUserForObjectId:objectId];
}

- (void)fetchAllObjects {
    
    NSLog(@"All news:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBNews"];
    
    NSLog(@"All categories:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBCategory"];
    
    NSLog(@"All users:");
    
    [self.coreDataManager printAllObjectsForName:@"ITBUser"];
}

- (void) printAllObjectsOfLocalDB
{
    [self.coreDataManager printAllObjectsForName:@"ITBNews"];
    [self.coreDataManager printAllObjectsForName:@"ITBCategory"];
    [self.coreDataManager printAllObjectsForName:@"ITBUser"];
}

- (void) updateCategories {
    
    [self.restClient
     updateCategoriesFromUser:self.currentUser
     onSuccess:^(NSDate *updatedAt)
     {
         
         
     }
     onFailure:^(NSError *error, NSInteger statusCode)
     {
         
     }];
}

@end
