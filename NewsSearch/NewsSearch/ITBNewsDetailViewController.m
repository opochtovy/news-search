//
//  ITBNewsDetailViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 12.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBNewsDetailViewController.h"

@interface ITBNewsDetailViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *backButtonItem;
@property (strong, nonatomic) UIBarButtonItem *forwardButtonItem;

@end

@implementation ITBNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    [self.webView loadRequest:request];
    
    self.backButtonItem = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                           target:self
                           action:@selector(actionBack:)];
    
    self.forwardButtonItem = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                              target:self
                              action:@selector(actionForward:)];
    
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                          target:self
                                          action:@selector(actionRefresh:)];
    
    self.navigationItem.rightBarButtonItems = @[self.forwardButtonItem, refreshButtonItem, self.backButtonItem];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)refreshButtons {
    
    self.backButtonItem.enabled = [self.webView canGoBack];
    self.forwardButtonItem.enabled = [self.webView canGoForward];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.indicator stopAnimating];
    
    [self refreshButtons];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self.indicator stopAnimating];
    
    [self refreshButtons];
    
}

#pragma mark - Actions

- (void)actionBack:(UIBarButtonItem *)sender {
    
    if ([self.webView canGoBack]) {
        
        [self.webView goBack];
    }
    
}

- (void)actionForward:(UIBarButtonItem *)sender {
    
    if ([self.webView canGoForward]) {
        
        [self.webView goForward];
    }
    
}

- (void)actionRefresh:(UIBarButtonItem *)sender {
    
    [self.webView stopLoading];
    
    [self.webView reload];
    
}

@end
