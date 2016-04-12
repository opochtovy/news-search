//
//  ITBCustomNewsDetailViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 08.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

typedef enum {
    
    ITBPickerTypeLargePhoto,
    ITBPickerTypeThumbnailPhoto
    
} ITBPickerType;

#import "ITBCustomNewsDetailViewController.h"

#import "ITBNewsAPI.h"
#import "ITBUtils.h"

#import "ITBNews.h"
#import "ITBPhoto.h"

#import "ITBThumbnailPhotoCell.h"

static NSString * const ITBThumbnailPhotoCellReuseIdentifier = @"ITBThumbnailPhotoCell";

@interface ITBCustomNewsDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *thumbnailPhotosCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) ITBPickerType chosenPickerType;

@property (copy, nonatomic) NSArray *photosArray;
@property (copy, nonatomic) NSArray *thumbnailPhotosArray;

@property (strong, nonatomic) ITBNews *newsItem;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *closePhotoViewButton;

@end

@implementation ITBCustomNewsDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsItem = [self.delegate sendNewsItemTo:self];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", self.newsItem.objectID];
    NSArray *news = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:predicate];
    self.newsItem = [news firstObject];
    
    self.titleLabel.text = self.newsItem.title;
    self.messageTextView.text = self.newsItem.message;
    
    self.photosArray = [self.newsItem.photos allObjects];
    self.thumbnailPhotosArray = [self.newsItem.thumbnailPhotos allObjects];
    
    self.thumbnailPhotosCollectionView.dataSource = self;
    self.thumbnailPhotosCollectionView.delegate = self;
    self.thumbnailPhotosCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgImage]];
    
    self.photoView.backgroundColor = [UIColor lightTextColor];
    [self.photoView setHidden:YES];
    self.photoView.alpha = 0.f;
    
    self.closePhotoViewButton.enabled = NO;
    
    self.messageTextView.scrollEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.messageTextView.scrollEnabled = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.thumbnailPhotosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ITBThumbnailPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ITBThumbnailPhotoCellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[ITBThumbnailPhotoCell alloc] init];
        
    }
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
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
    
    __weak ITBCustomNewsDetailViewController *weakSelf = self;
    
    if (!self.closePhotoViewButton.enabled) {
        
        self.closePhotoViewButton.enabled = YES;
        
        [self.activityIndicator startAnimating];
        
        [self.photoImageView setContentMode:UIViewContentModeScaleAspectFit];
        self.photoImageView.image = nil;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [weakSelf.photoView setHidden:NO];
            weakSelf.photoView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
        }];
        
        ITBPhoto *photo = [self.photosArray objectAtIndex:indexPath.row];

        if (photo.imageData == nil) {
            
            [self.activityIndicator startAnimating];
            
            [[ITBNewsAPI sharedInstance] loadImageForUrlString:photo.url onSuccess:^(NSData *data) {
                
                if (data != nil) {
                    
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    photo.imageData = data;
                    
                    [[ITBNewsAPI sharedInstance] saveBgContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        weakSelf.photoImageView.image = image;
                        [weakSelf.activityIndicator stopAnimating];
                    });
                    
                }
                
            }];
            
        } else {
            
            [self.activityIndicator stopAnimating];
            self.photoImageView.image = [UIImage imageWithData:photo.imageData];
        }
        
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        return CGSizeMake(80, 80);
        
    } else {
        
        return CGSizeMake(120, 120);
        
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        return UIEdgeInsetsMake(5, 10, 5, 10);
        
    } else {
        
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
}

#pragma mark - IBActions

- (IBAction)actionClosePhotoView:(UIButton *)sender {
    
    __weak ITBCustomNewsDetailViewController *weakSelf = self;
    
    self.closePhotoViewButton.enabled = NO;
    
    [self.activityIndicator stopAnimating];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        [weakSelf.photoView setHidden:YES];
        weakSelf.photoView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
    }];
    
}

@end
