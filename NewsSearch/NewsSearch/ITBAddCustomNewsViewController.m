//
//  ITBAddCustomNewsViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 10.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

typedef enum {
    
    ITBPickerTypeLargePhoto, // 0
    ITBPickerTypeThumbnailPhoto // 1
    
} ITBPickerType;

#import "ITBAddCustomNewsViewController.h"

#import "ITBNewsAPI.h"
#import "ITBUtils.h"

#import "ITBPhoto.h"

#import "ITBCategoryPickerViewController.h"

static NSString * const pickCategorySegueId = @"pickCategory";

@interface ITBAddCustomNewsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ITBCategoryToCreateNewsPickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *categoryField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailPhotoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) ITBPickerType chosenPickerType;

@property (strong, nonatomic) NSMutableArray *photoDataArray;
@property (strong, nonatomic) NSMutableArray *thumbnailPhotoDataArray;

@property (strong, nonatomic) NSIndexPath *chosenCategoryIndexPath;

@end

@implementation ITBAddCustomNewsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Create news";
    
    self.titleField.delegate = self;
    self.categoryField.delegate = self;
    self.messageTextView.delegate = self;
    
    self.photoDataArray = [NSMutableArray array];
    self.thumbnailPhotoDataArray = [NSMutableArray array];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    
    UIBarButtonItem *postNewsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(actionPostNews:)];
    [self.navigationItem setRightBarButtonItem:postNewsButton animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:pickCategorySegueId]) {
        
        ITBCategoryPickerViewController *pickerVC = [segue destinationViewController];
        
        pickerVC.delegate = self;
        
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = (UIImage *) [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    if (self.chosenPickerType == ITBPickerTypeLargePhoto) {
        
        self.photoView.image = chosenImage;
        
        [self.photoDataArray addObject:imageData];
        
    } else {
        
        self.thumbnailPhotoView.image = chosenImage;
        
        [self.thumbnailPhotoDataArray addObject:imageData];
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

#pragma mark - ITBCategoryToCreateNewsPickerDelegate

- (void)reloadCategoryFrom:(ITBCategoryPickerViewController *)categoryPickerVC withCategoryTitle:(NSString *)title indexPath:(NSIndexPath *)indexPath {
    
    self.chosenCategoryIndexPath = indexPath;
    
    self.categoryField.text = title;
}

- (NSIndexPath *)sendCategoryCheckmarkIndexTo:(ITBCategoryPickerViewController *)categoryVC {
    
    return self.chosenCategoryIndexPath;
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

#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)actionPostNews:(UIBarButtonItem *)sender {
    
    if ( (self.titleField.text.length == 0) || (self.messageTextView.text.length == 0) ) {
        
        NSString *title = @"Text error";
        NSString *message = @"You must enter title and message for news";
        
        [self showAlertWithTitle:title message:message];
        
    } else if (self.categoryField.text.length == 0) {
        
        NSString *title = @"Category error";
        NSString *message = @"You must select category for news";
        
        [self showAlertWithTitle:title message:message];
        
    } else if ([self.photoDataArray count] != [self.thumbnailPhotoDataArray count]) {
        
        NSString *title = @"Photos error";
        NSString *message = @"For each original photo you need to choose the thumbnail photo (in the same order)";
        
        [self showAlertWithTitle:title message:message];
        
    } else {
        
        [self.activityIndicator startAnimating];
        
        [[ITBNewsAPI sharedInstance] checkNetworkConnectionOnSuccess:^(BOOL isSuccess) {
            
            if (isSuccess) {
                
                if ([self.photoDataArray count] > 0) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    
                    [[ITBNewsAPI sharedInstance] uploadPhotosForCreatingNewsToServerForPhotosArray:self.photoDataArray thumbnailPhotos:self.thumbnailPhotoDataArray onSuccess:^(NSDictionary *responseBody) {
                        
                        NSArray *photos = [responseBody objectForKey:@"photos"];
                        NSArray *thumbnailPhotos = [responseBody objectForKey:@"thumbnailPhotos"];
                        
                        [[ITBNewsAPI sharedInstance] createCustomNewsForTitle:self.titleField.text message:self.messageTextView.text categoryTitle:self.categoryField.text photosArray:photos thumbnailPhotos:thumbnailPhotos onSuccess:^(BOOL isSuccess) {
                            
                            [self.activityIndicator stopAnimating];
                            
                        }];
                        
                    }];
                    
                } else {
                    
                    [[ITBNewsAPI sharedInstance] createCustomNewsForTitle:self.titleField.text message:self.messageTextView.text categoryTitle:self.categoryField.text photosArray:nil thumbnailPhotos:nil onSuccess:^(BOOL isSuccess) {
                        
                        [self.activityIndicator stopAnimating];
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }];
                    
                }
                
            }
            
        }];
    }
    
}

#pragma mark - Private

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
