//
//  ITBLoginViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 02.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBLoginViewController.h"

#import "ITBServerManager.h"

#import "ITBUser.h"

@interface ITBLoginViewController ()

- (IBAction)actionCancel:(UIBarButtonItem *)sender;

@end

@implementation ITBLoginViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
//        [self authorizeUser];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Login";
    
    [self authorizeUser];
    
//    [self.delegate changeTitleForLoginButton:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)authorizeUser {
    
    [[ITBServerManager sharedManager]
     authorizeUserOnSuccess:^(ITBUser *user)
    {
        [self.delegate changeTitleForLoginButton:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
     onFailure:^(NSError *error, NSInteger statusCode)
    {
        
    }];
    
}

#pragma mark - Actions

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
