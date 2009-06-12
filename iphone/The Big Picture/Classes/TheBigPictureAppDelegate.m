//
//  TheBigPictureAppDelegate.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import "TheBigPictureAppDelegate.h"
#import "RootViewController.h"


@implementation TheBigPictureAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {

}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
