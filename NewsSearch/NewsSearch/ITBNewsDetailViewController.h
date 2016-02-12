//
//  ITBNewsDetailViewController.h
//  NewsSearch
//
//  Created by Oleg Pochtovy on 12.02.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITBNewsDetailViewController : UIViewController <UIWebViewDelegate>

//@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *url;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
