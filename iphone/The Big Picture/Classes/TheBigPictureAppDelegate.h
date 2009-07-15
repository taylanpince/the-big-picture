//
//  TheBigPictureAppDelegate.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

@class ConnectionView;

@interface TheBigPictureAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSMutableDictionary *articleData;
	
	ConnectionView *loader;
	
	BOOL reachable;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableDictionary *articleData;

@property (nonatomic, retain) ConnectionView *loader;

@property (nonatomic, assign) BOOL reachable;

- (BOOL)isNetworkReachable;

@end
