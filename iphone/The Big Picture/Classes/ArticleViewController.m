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

@synthesize article, imageList, imageViewsList, activeIndex, hideTimer;


- (void)loadView {
	self.title = article.title;
	
	UIScrollView *articleView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	
	articleView.delegate = self;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.showsVerticalScrollIndicator = NO;
	articleView.showsHorizontalScrollIndicator = NO;
	articleView.pagingEnabled = YES;
	articleView.scrollsToTop = NO;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.directionalLockEnabled = YES;
	
	self.view = articleView;
	
	[articleView release];

	imageList = [[NSMutableArray alloc] init];
	imageViewsList = [[NSMutableArray alloc] init];
}


- (void)setupLayouts {
	UIScrollView *articleView = (UIScrollView *)[self view];
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
		articleView.superview.frame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
		articleView.frame = CGRectMake(0.0, 0.0, screenBounds.size.width + 15.0, screenBounds.size.height);
	} else {
		articleView.superview.frame = CGRectMake(0.0, 0.0, screenBounds.size.height, screenBounds.size.width);
		articleView.frame = CGRectMake(0.0, 0.0, screenBounds.size.height + 15.0, screenBounds.size.width);
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	[self setupLayouts];
	[super viewDidAppear:animated];
	[self performSelectorInBackground:@selector(loadPage:) withObject:article.url];
	
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if ([hideTimer isValid]) [hideTimer invalidate];
}


- (void)hideInterface {
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self.navigationController.navigationBar setAlpha:0.0];
	[UIView commitAnimations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIScrollView *articleView = (UIScrollView *)[self view];

	[self setupLayouts];
	
	for (UIView *subView in self.view.subviews) {
		if ([subView isKindOfClass:[PhotoView class]]) {
			subView.frame = CGRectMake(subView.tag * articleView.frame.size.width, 0.0, (articleView.frame.size.width - 15.0), articleView.frame.size.height);
		}
	}

	[articleView setContentSize:CGSizeMake(articleView.frame.size.width * [imageList count], articleView.frame.size.height)];
	[articleView setContentOffset:CGPointMake(articleView.frame.size.width * activeIndex, 0.0)];
	[articleView setContentInset:UIEdgeInsetsZero];
}


- (void)addPhoto:(NSUInteger)indexNum {
	Photo *photo = [imageList objectAtIndex:indexNum];
	PhotoView *imageView = [[PhotoView alloc] initWithFrame:CGRectMake(indexNum * self.view.frame.size.width, 0.0, (self.view.frame.size.width - 15.0), self.view.frame.size.height)];

	imageView.photo = photo;
	imageView.tag = indexNum;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.userInteractionEnabled = YES;
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
	
	[articleView setContentSize:CGSizeMake(articleView.frame.size.width * [imageList count], articleView.frame.size.height)];
	[articleView setContentOffset:CGPointZero];
	[articleView setContentInset:UIEdgeInsetsZero];
	
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
	
	if (activeIndex < [imageList count] - 3) {
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
	activeIndex = (scrollView.contentOffset.x < 0) ? 0 : floor(scrollView.contentOffset.x / self.view.frame.size.width);
	
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
	if ([[UIApplication sharedApplication] isStatusBarHidden] == YES) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
		
		self.navigationController.navigationBar.frame = CGRectMake(0.0, 20.0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
		
		[UIView beginAnimations:@"fadeIn" context:NULL];
		[UIView setAnimationDuration:0.5];
		[self.navigationController.navigationBar setAlpha:1.0];
		[UIView commitAnimations];
		
		hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
	}
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
