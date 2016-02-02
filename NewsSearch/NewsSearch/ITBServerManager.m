//
//  ITBServerManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// 1.1.1 - это класс singleton для общения с сервером

#import "ITBServerManager.h"

@interface ITBServerManager ()

@property (strong, nonatomic) NSURL *baseUrl;

@end

@implementation ITBServerManager

// 1.1.3
+ (ITBServerManager *)sharedManager {
    
    static ITBServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[ITBServerManager alloc] init];
/*
        // добавлю сюда вызов Авторизации
        [manager authorizeUser:^(OPUser *user) {
            
            NSLog(@"%@ %@", user.firstName, user.lastName);
        }];
*/
    });
    
    return manager;
}

// 1.1.4
- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.baseUrl = [NSURL URLWithString:@"https://api.parse.com/"];
        
    }
    
    return self;
}

@end
