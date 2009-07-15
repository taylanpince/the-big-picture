//
//  TheBigPictureAppDelegate.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

#import "TheBigPictureAppDelegate.h"
#import "RootViewController.h"
#import "ConnectionView.h"


@implementation TheBigPictureAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize articleData, reachable;
@synthesize loader;

- (void)initialize {
	[loader stopAnimating];
	
	articleData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"articleData"] mutableCopy];
	
	if (articleData == nil) {
		articleData = [[NSMutableDictionary alloc] init];
	}
	
	[window setBackgroundColor:[UIColor blackColor]];
	[navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	[navigationController.navigationBar setTranslucent:YES];
	
	[window insertSubview:[navigationController view] belowSubview:loader];
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)connectionDidFail {
	reachable = NO;
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"Big Picture requires a network connection to retrieve data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alertView show];
	[alertView release];
	
	[self initialize];
}


- (void)connectionDidSucceed {
	reachable = YES;
	
	[self initialize];
}


- (void)updateReachability {
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://boston.com/bigpicture/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (!connection) {
		[self connectionDidFail];
		[connection release];
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self connectionDidFail];
	[connection release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self connectionDidSucceed];
	[connection release];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	loader = [[ConnectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, window.frame.size.width, window.frame.size.height)];
	
	[window addSubview:loader];
	
	[self updateReachability];
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
	[loader release];
	[articleData release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
