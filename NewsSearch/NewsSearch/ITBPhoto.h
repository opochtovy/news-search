//
//  ITBPhoto.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ITBPhoto : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (id)initObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context;

- (void)updateObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context;

- (void)setImageWithURL:(NSString *)url onSuccess:(void (^)(UIImage *image))success;

@end

NS_ASSUME_NONNULL_END

#import "ITBPhoto+CoreDataProperties.h"
