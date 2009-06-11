//
//  ArticleViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "ArticleViewController.h"
#import "ArticleView.h"
#import "PhotoView.h"
#import "Article.h"
#import "Photo.h"
#import "RegexKitLite.h"


@implementation ArticleViewController

@synthesize article, imageList, imageViewsList, activeIndex;


- (void)loadView {
	self.title = article.title;
	self.navigationController.navigationBar.translucent = YES;
	
	ArticleView *articleView = [[ArticleView alloc] initWithFrame:CGRectZero];
	
	articleView.delegate = self;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.showsVerticalScrollIndicator = NO;
	articleView.showsHorizontalScrollIndicator = NO;
	articleView.pagingEnabled = YES;
	articleView.scrollsToTop = NO;
	
	self.view = articleView;
	
	[articleView release];

	imageList = [[NSMutableArray alloc] init];
	imageViewsList = [[NSMutableArray alloc] init];
	
	[self performSelectorInBackground:@selector(loadPage:) withObject:article.url];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

//	self.view.frame = CGRectMake(0.0, 0.0, 335.0, 460.0);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSLog(@"Rotated!");
}


- (void)addPhoto:(NSUInteger)indexNum {
	Photo *photo = [imageList objectAtIndex:indexNum];
	PhotoView *imageView = [[PhotoView alloc] initWithFrame:CGRectMake(indexNum * self.view.frame.size.width, -1 * self.navigationController.navigationBar.frame.size.height, (self.view.frame.size.width - 15.0), self.view.frame.size.height)];
	
//	[imageView setTransform:CGAffineTransformMakeRotation(-90 * M_PI / 180.0)];
	
	imageView.photo = photo;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	imageView.userInteractionEnabled = YES;
	imageView.delegate = self;

	[self.view addSubview:imageView];
	[imageViewsList replaceObjectAtIndex:indexNum withObject:imageView];
	
	[imageView release];
}


- (void)doneLoadingPage:(NSString *)htmlData {
	NSString *imgRegEx = @"<img src=\"(.*?)\" class=\"bpImage\"";
	NSArray *imgMatches;
	
	imgMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:imgRegEx];
	
	for (NSArray *imgOptions in imgMatches) {
		Photo *photo = [[Photo alloc] init];
		
		photo.url = [NSURL URLWithString:[imgOptions objectAtIndex:1]];
		
		[imageList addObject:photo];
		[imageViewsList addObject:[NSNull null]];
		[photo release];
	}
	
	activeIndex = 0;
	
	UIScrollView *articleView = (UIScrollView *)[self view];
	
	articleView.contentSize = CGSizeMake((articleView.frame.size.width + 15) * [imageList count], articleView.frame.size.height - self.navigationController.navigationBar.frame.size.height);
	articleView.contentOffset = CGPointMake(0.0, -1 * self.navigationController.navigationBar.frame.size.height);
	articleView.frame = CGRectMake(0.0, 0.0, 335.0, 460.0);
	
	[self addPhoto:0];
	[self addPhoto:1];
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
	if ((NSNull *)[imageViewsList objectAtIndex:activeIndex] == [NSNull null]) {
		[self addPhoto:activeIndex];
	}
	
	if (activeIndex > 1) {
		UIView *previousView = [imageViewsList objectAtIndex:activeIndex - 2];

		if ((NSNull *)previousView != [NSNull null]) {
			[previousView removeFromSuperview];
			[imageViewsList replaceObjectAtIndex:activeIndex - 2 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] - 2) {
		UIView *nextView = [imageViewsList objectAtIndex:activeIndex + 2];

		if ((NSNull *)nextView != [NSNull null]) {
			[nextView removeFromSuperview];
			[imageViewsList replaceObjectAtIndex:activeIndex + 2 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] - 1 && (NSNull *)[imageViewsList objectAtIndex:activeIndex + 1] == [NSNull null]) {
		[self addPhoto:activeIndex + 1];
	}
	
	if (activeIndex > 0 && (NSNull *)[imageViewsList objectAtIndex:activeIndex - 1] == [NSNull null]) {
		[self addPhoto:activeIndex - 1];
	}
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

	for (UIView *subView in scrollView.subviews) {
		if ([subView isKindOfClass:[PhotoView class]]) {
			CGFloat x;
			
			if (subView.tag < view.tag) {
				x = view.frame.origin.x - (view.tag - subView.tag) * 320.0;
			} else if (subView.tag > view.tag) {
				x = view.frame.origin.x + view.frame.size.width + (subView.tag - view.tag - 1) * 320.0;
			}

			subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
		}
	}
	
	scrollView.scrollEnabled = YES;
	NSLog(@"Zoom Scale: %f", view.currentZoomScale);
	if (view.currentZoomScale <= 1.0) {
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(640.0, 460.0);
		scrollView.contentOffset = CGPointZero;
	} else {
		scrollView.pagingEnabled = NO;
		scrollView.contentSize = view.frame.size;
		scrollView.contentOffset = view.frame.origin;
	}
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
	[imageViewsList release];
    [super dealloc];
}

@end
