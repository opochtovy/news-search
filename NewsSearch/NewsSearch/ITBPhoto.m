//
//  ITBPhoto.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 09.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBPhoto.h"

#import "ITBNewsAPI.h"

#import "ITBUtils.h"

@implementation ITBPhoto

// Insert code here to add functionality to your managed object subclass

+ (id)initObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context {
    
    ITBPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:@"ITBPhoto" inManagedObjectContext:context];
    
    photo.name = [photoDict objectForKey:@"name"];
    photo.url = [photoDict objectForKey:@"url"];
    photo.objectId = [photoDict objectForKey:@"objectId"];
    
    return photo;
}

- (void)updateObjectWithDictionary:(NSDictionary *)photoDict inContext:(NSManagedObjectContext *)context {
    
    self.name = [photoDict objectForKey:@"name"];
    self.url = [photoDict objectForKey:@"url"];
    self.objectId = [photoDict objectForKey:@"objectId"];
}

- (void)setImageWithURL:(NSString *)url onSuccess:(void (^)(UIImage *image))success {
    
    [[ITBNewsAPI sharedInstance] loadImageForURL:url onSuccess:^(UIImage *image) {
        
        success(image);
        
    }];
}

@end
