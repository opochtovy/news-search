//
//  ITBServerManager.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

// 1.1.1 - это класс singleton для общения с сервером

#import "ITBServerManager.h"

#import "ITBUser.h"

#import "ITBLoginViewController.h"
#import "ITBAccessToken.h"

#define APPID   @"lQETMCXVV6efIe7LsllbrEix0pZtmT02isLhGeGn"
#define RESTAPIKEY   @"0rwsYi5iHx1XZzwABjzlwiJZ0f266W7IUkHqcE7B"
#define CONTENT_API   @"application/json"

#define BASE_URL   @"https://api.parse.com"

@interface ITBServerManager () <NSURLConnectionDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSURL *baseUrl;

@property (strong, nonatomic) ITBAccessToken *accessToken;

@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *apiReturnXMLData;

@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (copy, nonatomic) NSString *currentElement;

@end

@implementation ITBServerManager

// 1.1.3
+ (ITBServerManager *)sharedManager {
    
    static ITBServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[ITBServerManager alloc] init];
        
    });
    
    return manager;
}

- (id)initWithBaseURL:(NSURL* ) url {
    
    self = [super init];
    
    if (self) {
        
        self.baseUrl = url;
        
    }
    
    return self;
}

- (void)authorizeUserForLogin:(ITBLoginViewController *) loginVC
                    onSuccess:(void(^)(ITBUser *user)) success
                    onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    [loginVC loginWithCompletionBlock:^(ITBAccessToken *token) {
        
        self.accessToken = token;
        
    }];
    
}

- (void)postUserOnSuccess:(void(^)(ITBUser *user))success
               onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure
{
    
    NSString *restCallString = [NSString stringWithFormat:@"%@/1/users?X-Parse-Application-Id=%@&X-Parse-REST-API-Key=%@&Content-Type=%@&", BASE_URL, APPID, RESTAPIKEY, CONTENT_API];
    
    NSURL *restURL = [NSURL URLWithString:restCallString];
    
//    NSURLRequest *restRequest = [NSURLRequest requestWithURL:restURL];

    NSMutableURLRequest *restRequest = [NSMutableURLRequest requestWithURL:restURL                                                       cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData                                                   timeoutInterval:10];

    [restRequest setHTTPMethod:@"POST"];
    
    // HTTPBody
    NSString *postString = @"username=user2&password=1111";
    [restRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (self.currentConnection)
    {
        [self.currentConnection cancel];
        self.currentConnection = nil;
        self.apiReturnXMLData = nil;
    }
    
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:restRequest delegate:self];
    
    self.apiReturnXMLData = [NSMutableData data];
    
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    
    [self.apiReturnXMLData setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    
    [self.apiReturnXMLData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    
    NSLog(@"URL Connection Failed!");
    self.currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    self.xmlParser = [[NSXMLParser alloc] initWithData:self.apiReturnXMLData];
    
    [self.xmlParser setDelegate:self];
    
    [self.xmlParser parse];

    self.currentConnection = nil;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if( [elementName isEqualToString:@"Error"])
    {
        NSLog(@"Web API Error!");
    }
    
    //
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
    
    //
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    
    self.apiReturnXMLData = nil;
}

@end
