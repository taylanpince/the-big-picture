//
//  ArticleViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleViewController.h"
#import "Article.h"
#import "RegexKitLite.h"


@implementation ArticleViewController

@synthesize article, imageList;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	imageList = [[NSMutableArray alloc] init];
	
	self.title = article.title;
	self.navigationController.navigationBar.translucent = YES;
	
	[self performSelectorInBackground:@selector(loadPage:) withObject:article.url];
}


- (void)doneLoadingPage:(NSString *)htmlData {
	NSString *imgRegEx = @"<img src=\"(.*?)\" class=\"bpImage\"";
	NSArray *imgMatches;
	
	imgMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:imgRegEx];
	
	for (NSArray *imgOptions in imgMatches) {
		[imageList addObject:[NSURL URLWithString:[imgOptions objectAtIndex:1]]];
	}
	
	[self performSelectorInBackground:@selector(loadImage:) withObject:[imageList objectAtIndex:0]];
}


- (void)loadPage:(NSURL *)pageURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	NSString *html = [NSString stringWithContentsOfURL:pageURL];
	
	[self performSelectorOnMainThread:@selector(doneLoadingPage:) withObject:html waitUntilDone:NO];
	
	[pool release];
}


- (void)doneLoadingImage:(UIImage *)image {
	CGSize initialSize = CGSizeMake((image.size.height * 460.0 / image.size.width), 460.0);
	CGPoint initialPosition = CGPointMake((320 - initialSize.width) / 2, 0.0);
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
	
	[self.view addSubview:scrollView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	
	[imageView setTransform:CGAffineTransformMakeRotation(-90 * M_PI / 180.0)];
	
	imageView.frame = CGRectMake(initialPosition.x, initialPosition.y, initialSize.width, initialSize.height);
	
	[scrollView addSubview:imageView];
	
//	scrollView.contentSize = CGSizeMake(image.size.height, image.size.width);
	
	[imageView release];
	[scrollView release];
}


- (void)loadImage:(NSURL *)imageURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
	
	[self performSelectorOnMainThread:@selector(doneLoadingImage:) withObject:image waitUntilDone:NO];
	
	[pool release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[article release];
	[imageList release];
}


- (void)dealloc {
	[article release];
	[imageList release];
    [super dealloc];
}

@end
