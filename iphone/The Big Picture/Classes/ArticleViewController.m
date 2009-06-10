//
//  ArticleViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleViewController.h"
#import "PhotoView.h"
#import "Article.h"
#import "Photo.h"
#import "RegexKitLite.h"


@implementation ArticleViewController

@synthesize article, imageList, activeIndex;


- (void)loadView {
	UIScrollView *articleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
	
	articleView.delegate = self;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.showsVerticalScrollIndicator = NO;
	articleView.showsHorizontalScrollIndicator = NO;
	articleView.pagingEnabled = YES;
	
	self.view = articleView;
	
	[articleView release];

	imageList = [[NSMutableArray alloc] init];
	
	self.title = article.title;
	self.navigationController.navigationBar.translucent = YES;
	
	[self performSelectorInBackground:@selector(loadPage:) withObject:article.url];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//	[self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)doneLoadingPage:(NSString *)htmlData {
	NSString *imgRegEx = @"<img src=\"(.*?)\" class=\"bpImage\"";
	NSArray *imgMatches;
	
	imgMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:imgRegEx];
	
	for (NSArray *imgOptions in imgMatches) {
		Photo *photo = [[Photo alloc] init];
		
		photo.url = [NSURL URLWithString:[imgOptions objectAtIndex:1]];
		
		[imageList addObject:photo];
		[photo release];
	}
	
	activeIndex = 0;
	
	[self performSelectorInBackground:@selector(loadImage:) withObject:[NSNumber numberWithInt:0]];
}


- (void)loadPage:(NSURL *)pageURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	NSString *html = [NSString stringWithContentsOfURL:pageURL];
	
	[self performSelectorOnMainThread:@selector(doneLoadingPage:) withObject:html waitUntilDone:NO];
	
	[pool release];
}


- (void)prepNeighbours {
	if (activeIndex < [imageList count] - 1) {
		Photo *photo = (Photo *)[imageList objectAtIndex:activeIndex + 1];
		
		if (!photo.image) {
			[self performSelectorInBackground:@selector(loadImage:) withObject:[NSNumber numberWithInt:activeIndex + 1]];
		}
	}
	
	if (activeIndex > 0) {
		Photo *photo = (Photo *)[imageList objectAtIndex:activeIndex - 1];
		
		if (!photo.image) {
			[self performSelectorInBackground:@selector(loadImage:) withObject:[NSNumber numberWithInt:activeIndex - 1]];
		}
	}
}


- (void)doneLoadingImage:(NSNumber *)indexNum {
	Photo *photo = [imageList objectAtIndex:[indexNum intValue]];
	UIScrollView *articleView = (UIScrollView *)[self view];
	PhotoView *imageView = [[PhotoView alloc] initWithImage:photo.image];
	
//	[imageView setTransform:CGAffineTransformMakeRotation(-90 * M_PI / 180.0)];
	
	imageView.frame = CGRectMake([indexNum intValue] * 320.0, 0.0, 320.0, 460.0);
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.tag = [indexNum intValue];
	imageView.userInteractionEnabled = YES;
	imageView.delegate = self;
	
	[self.view addSubview:imageView];
	
	articleView.contentSize = CGSizeMake(articleView.contentSize.width + imageView.frame.size.width, articleView.contentSize.height);
	
	[imageView release];
	
	[self prepNeighbours];
}


- (void)loadImage:(NSNumber *)indexNum {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	
	Photo *photo = [imageList objectAtIndex:[indexNum intValue]];
	
	photo.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:photo.url]];
	
	[self performSelectorOnMainThread:@selector(doneLoadingImage:) withObject:indexNum waitUntilDone:NO];
	
	[pool release];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	activeIndex = (scrollView.contentOffset.x < 0) ? 0 : floor(scrollView.contentOffset.x / 320.0);
	
	[self prepNeighbours];
}


- (void)didBeginZoomingOnView:(PhotoView *)view {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	scrollView.scrollEnabled = NO;
}


- (void)didEndZoomingOnView:(PhotoView *)view {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	scrollView.scrollEnabled = YES;
}


- (void)didSingleTapOnView:(PhotoView *)view {
	NSLog(@"SINGLE TAP!");
}


- (void)didDoubleTapOnView:(PhotoView *)view {
	NSLog(@"DOUBLE TAP!");
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
