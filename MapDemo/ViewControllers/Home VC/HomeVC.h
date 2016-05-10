//
//  HomeVC.h
//  MapDemo
//
//  Created by Jayesh Patel on 06/04/16.
//  Copyright © 2016 Jayesh Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface HomeVC : UIViewController <MKMapViewDelegate,  CLLocationManagerDelegate>

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;

@end
