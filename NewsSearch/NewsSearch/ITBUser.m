//
//  ITBUser.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBUser.h"

@implementation ITBUser

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    
    if (self) {
        
        self.username = [responseObject objectForKey:@"username"];
        self.objectId = [responseObject objectForKey:@"objectId"];
        self.sessionToken = [responseObject objectForKey:@"sessionToken"];
        self.createdAt = [responseObject objectForKey:@"createdAt"];
        self.updatedAt = [responseObject objectForKey:@"updatedAt"];
        
        self.code = [responseObject objectForKey:@"code"];
        self.error = [responseObject objectForKey:@"error"];
        
    }
    
    return self;
    
}

@end
