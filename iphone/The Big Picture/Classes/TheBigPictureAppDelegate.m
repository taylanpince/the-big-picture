//
//  TheBigPictureAppDelegate.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "TheBigPictureAppDelegate.h"
#import "RootViewController.h"


@implementation TheBigPictureAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize articleData, reachable;


- (void)updateReachability {
	CFHostRef serverHost;
	CFStringRef hostName = CFSTR("www.boston.com");
	CFStreamError error;
	CFDataRef data;
	Boolean success;
	SCNetworkConnectionFlags *flags;
	
	serverHost = CFHostCreateWithName(kCFAllocatorDefault, hostName);
	success = CFHostStartInfoResolution(serverHost, kCFHostReachability, &error);
	data = CFHostGetReachability(serverHost, NULL);
	flags = (SCNetworkConnectionFlags *)CFDataGetBytePtr(data);
	
	if (success && (*flags & kSCNetworkFlagsReachable) && !(*flags & kSCNetworkFlagsConnectionRequired)) {
		reachable = YES;
	} else {
		reachable = NO;
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"The Big Picture requires a network connection to retrieve data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];
	}
	
	CFRelease(serverHost);
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self updateReachability];
	
	articleData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"articleData"] mutableCopy];
	
	if (articleData == nil) {
		articleData = [[NSMutableDictionary alloc] init];
	}

	window.backgroundColor = [UIColor blackColor];
	navigationController.navigationBar.barStyle = UIBarStyleBlack;
	navigationController.navigationBar.translucent = YES;

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (BOOL)isNetworkReachable {
	return reachable;
}


- (void)saveApplicationData {
	[[NSUserDefaults standardUserDefaults] setObject:articleData forKey:@"articleData"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveApplicationData];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[self saveApplicationData];
}


- (void)dealloc {
	[articleData release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
