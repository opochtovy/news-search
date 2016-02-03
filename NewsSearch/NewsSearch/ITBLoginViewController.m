//
//  ITBLoginViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginViewController.h"
#import "ITBAccessToken.h"

@interface ITBLoginViewController () <UIWebViewDelegate>

//@property (copy, nonatomic) ITBLoginCompletionBlock completionBlock;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) ITBAccessToken *accessToken;

@end

@implementation ITBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Login";
    
    // ...
    
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    self.webView.delegate = nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //
    
    return YES;
}

@end
