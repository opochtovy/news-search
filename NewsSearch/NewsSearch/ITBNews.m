//
//  ITBNews.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNews.h"

@implementation ITBNews

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    
    if (self) {
        
        self.objectId = [responseObject objectForKey:@"objectId"];
        self.newsURL = [responseObject objectForKey:@"newsURL"];
        self.title = [responseObject objectForKey:@"title"];
        self.message = [responseObject objectForKey:@"message"];
        self.category = [responseObject objectForKey:@"category"];
        
//        self.rating = [responseObject objectForKey:@"rating"];
        
        self.createdAt = [responseObject objectForKey:@"createdAt"];
        self.updatedAt = [responseObject objectForKey:@"updatedAt"];
        
        self.likedUsers = [responseObject objectForKey:@"likedUsers"];
//        self.rating = [self.likedUsers count]; // отпадает необходимость в этой проперти т.к. у меня есть [likedUsers count]
        
    }
    
    return self;
    
}

@end
