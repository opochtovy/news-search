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

@property (assign, nonatomic) ITBPickerType chosenPickerType;

@property (copy, nonatomic) NSArray *photosArray;
@property (copy, nonatomic) NSArray *thumbnailPhotosArray;

@property (strong, nonatomic) ITBNews *newsItem;

@end

@implementation ITBCustomNewsDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.newsItem = [self.delegate sendNewsItemTo:self];
    
    self.titleLabel.text = self.newsItem.title;
    self.messageLabel.text = self.newsItem.message;
    
    self.photosArray = [self.newsItem.photos allObjects];
    self.thumbnailPhotosArray = [self.newsItem.thumbnailPhotos allObjects];
    
    self.thumbnailPhotosCollectionView.dataSource = self;
    self.thumbnailPhotosCollectionView.delegate = self;
    
    self.thumbnailPhotosCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cork.png"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// UICollectionViewDelegateFlowLayout

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
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 10, 50, 10);
}

@end
