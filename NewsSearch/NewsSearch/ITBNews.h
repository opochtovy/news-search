//
//  ITBNews.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITBNews : NSObject

@property (strong, nonatomic) NSString* objectId;
@property (strong, nonatomic) NSString* newsURL;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSNumber* rating;
@property (strong, nonatomic) NSDate* createdAt;
@property (strong, nonatomic) NSDate* updatedAt;

//@property (strong, nonatomic) NSString* imageURL;

- (id)initWithServerResponse:(NSDictionary *) responseObject;

@end
