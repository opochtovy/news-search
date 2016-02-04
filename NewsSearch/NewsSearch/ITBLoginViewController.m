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

@property (copy, nonatomic) ITBLoginCompletionBlock completionBlock;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

//@property (strong, nonatomic) ITBAccessToken *accessToken;

- (IBAction)actionCancel:(UIBarButtonItem *)sender;

@end

@implementation ITBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Login";
    
    NSString *urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    self.webView.delegate = self;
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    self.webView.delegate = nil;
}

#pragma mark - Private Methods

- (void)loginWithCompletionBlock:(ITBLoginCompletionBlock) completionBlock {
    
    self.completionBlock = completionBlock;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", request);
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    return YES;
}

#pragma mark - Actions

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
