//
//  ITBAddCustomNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

typedef enum {
    
    ITBPickerTypeLargePhoto,
    ITBPickerTypeThumbnailPhoto
    
} ITBPickerType;

#import "ITBAddCustomNewsViewController.h"

#import "ITBNewsAPI.h"
#import "ITBUtils.h"

#import "ITBNews.h"
#import "ITBCategory.h"
#import "ITBPhoto.h"

#import "ITBAddPhotoCell.h"

static NSString * const addCustomNewstitle = @"Create news";

static NSString * const ITBAddPhotoCellReuseIdentifier = @"ITBAddPhotoCell";

static NSString * const textErrorTitle = @"Text error";
static NSString * const textErrorMessage = @"You must enter title and message for news";
static NSString * const categoryErrorTitle = @"Category error";
static NSString * const categoryErrorMessage = @"You must select category for news";
static NSString * const photosErrorTitle = @"Photos error";
static NSString * const photosErrorMessage = @"For each original photo you need to choose the thumbnail photo (in the same order)";
static NSString * const chooseCategoryTitle = @"Choose a category";

@interface ITBAddCustomNewsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ITBAddPhotoCellDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postNewsButton;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *categoryField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *thumbnailPhotosCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) ITBPickerType chosenPickerType;

@property (strong, nonatomic) NSMutableArray *photoDataArray;
@property (strong, nonatomic) NSMutableArray *thumbnailPhotoDataArray;

@property (assign, nonatomic) NSInteger chosenCategoryIndex;

@property (strong, nonatomic) NSMutableArray *photosArray;
@property (strong, nonatomic) NSMutableArray *thumbnailPhotosArray;

@property (copy, nonatomic) NSArray *allCategoriesArray;

@end

@implementation ITBAddCustomNewsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navBarItem.title = NSLocalizedString(addCustomNewstitle, nil);
    
    self.titleField.delegate = self;
    self.categoryField.delegate = self;
    self.messageTextView.delegate = self;
    
    self.photoDataArray = [NSMutableArray array];
    self.thumbnailPhotoDataArray = [NSMutableArray array];
    
    self.photosArray = [NSMutableArray array];
    self.thumbnailPhotosArray = [NSMutableArray array];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.navBarItem.leftBarButtonItems = nil;
        
    }
    
    self.thumbnailPhotosCollectionView.dataSource = self;
    self.thumbnailPhotosCollectionView.delegate = self;
    self.thumbnailPhotosCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgImage]];
    
    self.photosCollectionView.dataSource = self;
    self.photosCollectionView.delegate = self;
    self.photosCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgImage]];
    
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:titleDescriptorKey ascending:YES];
    
    self.allCategoriesArray = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBCategoryEntityName withSortDescriptors:@[titleDescriptor] predicate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = (UIImage *) [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    if (self.chosenPickerType == ITBPickerTypeLargePhoto) {
        
        [self.photosArray addObject:chosenImage];
        [self.photoDataArray addObject:imageData];
        
        [self.photosCollectionView reloadData];
        
    } else {
        
        [self.thumbnailPhotosArray addObject:chosenImage];
        [self.thumbnailPhotoDataArray addObject:imageData];
        
        [self.thumbnailPhotosCollectionView reloadData];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.categoryField]) {
        
        return NO;
        
    }
    
    return YES;
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.thumbnailPhotosCollectionView]) {
        
        return [self.thumbnailPhotosArray count];
        
    } else {
        
        return [self.photosArray count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ITBAddPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ITBAddPhotoCellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[ITBAddPhotoCell alloc] init];
        
    }
    
    cell.delegate = self;
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([collectionView isEqual:self.thumbnailPhotosCollectionView]) {
        
        cell.imageView.image = [self.thumbnailPhotosArray objectAtIndex:indexPath.row];
        cell.collectionType = 1;
        
    } else {
        
        cell.imageView.image = [self.photosArray objectAtIndex:indexPath.row];
        cell.collectionType = 0;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.thumbnailPhotosCollectionView]) {
        
        return CGSizeMake(110, 50);
        
    } else {
        
        return CGSizeMake(110, 110);
    }

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark - ITBAddPhotoCellDelegate

- (void)addPhotoCellDidTapRemove:(ITBAddPhotoCell *)cell forCollectionType:(ITBCollectionType)type {
    
    if (type == 0) {
        
        NSIndexPath *indexPath = [self.photosCollectionView indexPathForCell:cell];
        
        [self.photosArray removeObjectAtIndex:indexPath.row];
        [self.photoDataArray removeObjectAtIndex:indexPath.row];
        
        [self.photosCollectionView reloadData];
        
    } else {
        
        NSIndexPath *indexPath = [self.thumbnailPhotosCollectionView indexPathForCell:cell];
        
        [self.thumbnailPhotosArray removeObjectAtIndex:indexPath.row];
        [self.thumbnailPhotoDataArray removeObjectAtIndex:indexPath.row];
        
        [self.thumbnailPhotosCollectionView reloadData];
        
    }
}

#pragma mark - IBActions

- (IBAction)selectPhoto:(UIButton *)sender {
    
    self.chosenPickerType = ITBPickerTypeLargePhoto;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectThumbnailPhoto:(UIButton *)sender {
    
    self.chosenPickerType = ITBPickerTypeThumbnailPhoto;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)actionPostNews:(UIBarButtonItem *)sender {
    
    if ( (self.titleField.text.length == 0) || (self.messageTextView.text.length == 0) ) {
        
        [self showAlertWithTitle:textErrorTitle message:textErrorMessage];
        
    } else if (self.categoryField.text.length == 0) {
        
        [self showAlertWithTitle:categoryErrorTitle message:categoryErrorMessage];
        
    } else if ([self.photosArray count] != [self.thumbnailPhotosArray count]) {
        
        [self showAlertWithTitle:photosErrorTitle message:photosErrorMessage];
        
    } else {
        
        [self.activityIndicator startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        [[ITBNewsAPI sharedInstance] checkNetworkConnectionOnSuccess:^(BOOL isConnected) {
            
            if (isConnected) {
                
                [[ITBNewsAPI sharedInstance] createNewObjectsForPhotoDataArray:self.photoDataArray thumbnailPhotoDataArray:self.thumbnailPhotoDataArray onSuccess:^(NSDictionary *responseBody) {
                    
                    NSArray *photos = [responseBody objectForKey:photosDictKey];
                    NSArray *thumbnailPhotos = [responseBody objectForKey:thumbnailPhotosDictKey];
                    
                    [[ITBNewsAPI sharedInstance] createCustomNewsForTitle:self.titleField.text message:self.messageTextView.text categoryTitle:self.categoryField.text photosArray:photos thumbnailPhotos:thumbnailPhotos onSuccess:^(BOOL isSuccess) {

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            [[ITBNewsAPI sharedInstance] uploadPhotosForCreatingNewsToServerForPhotoDataArray:self.photoDataArray thumbnailPhotoDataArray:self.thumbnailPhotoDataArray photoObjectsArray:photos thumbnailPhotoObjectsArray:thumbnailPhotos onSuccess:^(NSDictionary *responseBody) {
                                
                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                
                            }];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self.activityIndicator stopAnimating];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            });
                        });

                    }];
                    
                }];
                
            }
            
        }];
    }
    
}

#pragma mark - Actions

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)actionPickCategory:(UIButton *)sender {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:chooseCategoryTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (ITBCategory *category in self.allCategoriesArray) {
        
        UIAlertAction *pickCategory = [UIAlertAction actionWithTitle:category.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            self.categoryField.text = category.title;
            
            self.chosenCategoryIndex = [self.allCategoriesArray indexOfObject:category];
            
        }];
        [actionSheet addAction:pickCategory];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

@end
