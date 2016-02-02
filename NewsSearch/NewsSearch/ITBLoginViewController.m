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

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation ITBLoginViewController

- (id)initWithCompletionBlock:(ITBLoginCompletionBlock) completionBlock {
    
    self = [super init];
    
    if (self) {
        
        self.completionBlock = completionBlock;
    }
    
    return self;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect r = self.view.bounds;
    r.origin = CGPointZero;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:r];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    // UIBarButtonItem cancel для отмены (будет находиться в navigationBar)
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Login";
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
    
    
    return YES;
}

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)item {
    
    if (self.completionBlock) {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
