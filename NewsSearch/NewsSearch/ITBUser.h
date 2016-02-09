//
//  ITBUser.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITBUser : NSObject

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* objectId;
@property (strong, nonatomic) NSString* sessionToken;
@property (strong, nonatomic) NSDate* createdAt;
@property (strong, nonatomic) NSDate* updatedAt;

- (id)initWithServerResponse:(NSDictionary *) responseObject;

@end
