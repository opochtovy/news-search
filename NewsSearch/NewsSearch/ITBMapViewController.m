//
//  ITBMapViewController.m
//  NewsSearch
//
//  Created by Oleg Pochtovy on 20.03.16.
//  Copyright © 2016 Oleg Pochtovy. All rights reserved.
//

#import "ITBMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ITBNewsAPI.h"
#import "ITBNews.h"

#import "ITBMapAnnotation.h"

#import "ITBUtils.h"

static const CLLocationDistance regionRadius = 50000;

static NSString * const annotationTitle = @"Location of news to select";

static NSString * const errorTitle = @"Error";
static NSString * const errorMessage = @"Failed to Get Your Location";
static NSString * const invalidCoordsMessage = @"Please type the correct values for latitude and longitude!";

@interface ITBMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) ITBMapAnnotation *newsLocation;

@end

@implementation ITBMapViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.latitudeField.delegate = self;
    self.longitudeField.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    NSInteger status = [CLLocationManager authorizationStatus];
    
    if ( (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse) ) {
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *latNumber = [userDefaults objectForKey:kSettingsLatitude];
    NSNumber *longNumber = [userDefaults objectForKey:kSettingsLongitude];
    
    double latitude = (([latNumber isEqual:@0]) && ([longNumber isEqual:@0])) ? grodnoLatitude : [latNumber doubleValue];
    double longitude = (([latNumber isEqual:@0]) && ([longNumber isEqual:@0])) ? grodnoLongitude : [longNumber doubleValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    self.latitudeField.text = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.longitudeField.text = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    [self centerMapOnLocation:location];
    
    self.newsLocation = [[ITBMapAnnotation alloc] init];
    self.newsLocation.title = annotationTitle;
    self.newsLocation.coordinate = location.coordinate;
    [self.mapView addAnnotation:self.newsLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)centerMapOnLocation:(CLLocation *)location {
    
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius);
    [self.mapView setRegion:coordinateRegion animated:YES];
    
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSInteger status = [CLLocationManager authorizationStatus];
    
    if ( (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse) ) {
        
        [self.locationManager startUpdatingLocation];
    }
    
    [self showAlertWithTitle:errorTitle message:errorMessage];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.latitudeField]) {
        
        [self.longitudeField becomeFirstResponder];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)actionBackToCategories:(UIBarButtonItem *)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    double latitude = [self.latitudeField.text doubleValue];
    NSNumber *latNumber = [NSNumber numberWithDouble:latitude];
    double longitude = [self.longitudeField.text doubleValue];
    NSNumber *longNumber = [NSNumber numberWithDouble:longitude];
    
    [userDefaults setObject:latNumber forKey:kSettingsLatitude];
    [userDefaults setObject:longNumber forKey:kSettingsLongitude];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionChangeLocation:(UIBarButtonItem *)sender {
    
    CGFloat latitude = [self.latitudeField.text doubleValue];
    CGFloat longitude = [self.longitudeField.text doubleValue];
    
    if ((latitude <= 90.f) && (latitude >= -90.f) && (longitude >= -180.f) && (longitude <= 180.f)) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self centerMapOnLocation:location];
        
        self.newsLocation.coordinate = location.coordinate;
        
        NSArray *news = [[ITBNewsAPI sharedInstance] fetchObjectsInBackgroundForEntity:ITBNewsEntityName withSortDescriptors:nil predicate:nil];
        
        CLLocation *currentUserLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        for (ITBNews *newsItem in news) {
            
            CLLocation *newsItemLocation = [[CLLocation alloc] initWithLatitude:[newsItem.latitude doubleValue] longitude:[newsItem.longitude doubleValue]];
            
            CLLocationDistance distance = [newsItemLocation distanceFromLocation:currentUserLocation];
            
            BOOL isValid = (distance <= maxDistance) ? YES : NO;
            newsItem.isValidByGeolocation = [NSNumber numberWithBool:isValid];
        }
        
        [[ITBNewsAPI sharedInstance] saveBgContext];
        
    } else {
        
        [self showAlertWithTitle:errorTitle message:invalidCoordsMessage];
    }
    
}

@end
