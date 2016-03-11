//
//  ITBCustomNewsDetailViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

typedef enum {
    
    ITBPickerTypeLargePhoto, // 0
    ITBPickerTypeThumbnailPhoto // 1
    
} ITBPickerType;

#import "ITBCustomNewsDetailViewController.h"

#import "ITBNewsAPI.h"

#import "ITBNews.h"
#import "ITBPhoto.h"

#import "ITBThumbnailPhotoCell.h"

@interface ITBCustomNewsDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *thumbnailPhotosCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) ITBPickerType chosenPickerType;

@property (copy, nonatomic) NSArray *photosArray;
@property (copy, nonatomic) NSArray *thumbnailPhotosArray;

@property (strong, nonatomic) ITBNews *newsItem;

@property (strong, nonatomic) UIButton *closePhotoViewButton;
@property (strong, nonatomic) UIImageView *photoImageView;

@end

@implementation ITBCustomNewsDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsItem = [self.delegate sendNewsItemTo:self];
    
    self.titleLabel.text = self.newsItem.title;
    self.messageLabel.text = self.newsItem.message;
    
    self.photosArray = [self.newsItem.photos allObjects];
    self.thumbnailPhotosArray = [self.newsItem.thumbnailPhotos allObjects];
    
    self.thumbnailPhotosCollectionView.dataSource = self;
    self.thumbnailPhotosCollectionView.delegate = self;
    
    self.thumbnailPhotosCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    
    self.photoView.backgroundColor = [UIColor lightTextColor];
    
    [self.photoView setHidden:YES];
    self.photoView.alpha = 0.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.thumbnailPhotosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ITBThumbnailPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ITBThumbnailPhotoCell" forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[ITBThumbnailPhotoCell alloc] init];
        
    }
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];

    cell.thumbnailPhoto = [self.thumbnailPhotosArray objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.activityIndicator startAnimating];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(closePhotoView:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Close" forState:UIControlStateNormal];
    button.frame = CGRectMake(self.photoView.frame.size.width - 100.0, 10.0, 90.0, 40.0);
    button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.closePhotoViewButton = button;
    
    CGRect rect = CGRectMake(0, 0, self.photoView.frame.size.width, self.photoView.frame.size.height);
    self.photoImageView = [[UIImageView alloc] initWithFrame:rect];
    self.photoImageView.image = nil;
    [self.photoView addSubview:self.photoImageView];
    
    [self.photoView addSubview:self.closePhotoViewButton];
    
    [self.photoView setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        
        self.photoView.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
    }];
    
    __weak ITBCustomNewsDetailViewController *weakSelf = self;
    
    ITBPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];
    
    [photo setImageWithURL:photo.url onSuccess:^(UIImage * _Nonnull image) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            weakSelf.photoImageView.image = image;
            [weakSelf.activityIndicator stopAnimating];
        });
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 10, 50, 10);
}

- (void)closePhotoView:(UIButton *)sender {
    
    [self.activityIndicator stopAnimating];
    
    [self.closePhotoViewButton removeFromSuperview];
    [self.photoImageView removeFromSuperview];
    
    [self.photoView setHidden:YES];
    [UIView animateWithDuration:0.25 animations:^{
        
        self.photoView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
    }];
}

@end
