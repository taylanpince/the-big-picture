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


static NSString *const RE_FIRST_PHOTO = @"<div class=\"bpImageTop\"><a name=\"photo1\"></a><a href=\".*?\"><img src=\"(.*?)\" class=\"bpImage\" style=\".*?\" /></a><br/><div class=\"bpCaption\">(.*?)<div";
static NSString *const RE_PHOTO = @"<div class=\"bpBoth\"><a name=\"photo[0-9]+\"></a><img src=\"(.*?)\" class=\"bpImage\" style=\".*?\" /><br/><div onclick=\"this.style.display='none'\" class=\"(.*?)\" style=\".*?\"></div><div class=\"bpCaption\"><div class=\"photoNum\"><a href=\"#photo[0-9]+\">[0-9]+</a></div>(.*?)<a href";


@implementation ArticleViewController

@synthesize article, loadingIndicator, imageList, imageViewsList, activeIndex, hideTimer, zooming;


- (void)loadView {
	self.title = article.title;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	
	scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.pagingEnabled = YES;
	scrollView.scrollsToTop = NO;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.directionalLockEnabled = YES;
	
	self.view = scrollView;
	
	[scrollView release];

	imageList = [[NSMutableArray alloc] init];
	imageViewsList = [[NSMutableArray alloc] init];
}


- (void)setupLayouts {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	
	scrollView.superview.backgroundColor = [UIColor blackColor];
	
	if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
		scrollView.superview.frame = CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height);
		scrollView.frame = CGRectMake(0.0, 0.0, screenBounds.size.width + 15.0, screenBounds.size.height);
	} else {
		scrollView.superview.frame = CGRectMake(0.0, 0.0, screenBounds.size.height, screenBounds.size.width);
		scrollView.frame = CGRectMake(0.0, 0.0, screenBounds.size.height + 15.0, screenBounds.size.width);
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	[self setupLayouts];
	[super viewDidAppear:animated];
	
	loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	loadingIndicator.center = CGPointMake(self.view.frame.size.width + (self.view.frame.size.width - 15.0) / 2, (self.view.frame.size.height / 2) - self.navigationController.navigationBar.frame.size.height);
	loadingIndicator.hidesWhenStopped = YES;
	
	[loadingIndicator startAnimating];
	[self.view addSubview:loadingIndicator];
	
	[self performSelectorInBackground:@selector(loadPage:) withObject:article.url];

	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	[scrollView setContentOffset:CGPointZero];
	[scrollView setContentInset:UIEdgeInsetsZero];
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * 2, scrollView.frame.size.height)];
	
	ArticleView *articleView = [[ArticleView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - 15.0, self.view.frame.size.height)];
	
	articleView.alpha = 0.0;
	articleView.tag = 0;
	articleView.backgroundColor = [UIColor blackColor];
	articleView.article = article.description;
	articleView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 30.0, 0.0, 0.0, 0.0);
	
	[self.view addSubview:articleView];
	
	[UIView beginAnimations:@"fadeIn" context:NULL];
	[UIView setAnimationDuration:0.5];
	[articleView setAlpha:1.0];
	[UIView commitAnimations];
	
	[articleView release];
	
	activeIndex = 0;
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (hideTimer != nil) {
		[hideTimer invalidate];
		
		hideTimer = nil;
	}
}


- (void)hideInterface {
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	
	[UIView beginAnimations:@"fadeOut" context:NULL];
	[UIView setAnimationDuration:0.5];
	[self.navigationController.navigationBar setAlpha:0.0];
	[UIView commitAnimations];
	
	hideTimer = nil;
}


- (void)showInterface {
	if ([[UIApplication sharedApplication] isStatusBarHidden] == YES) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
		
		self.navigationController.navigationBar.frame = CGRectMake(0.0, 20.0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
		
		[UIView beginAnimations:@"fadeIn" context:NULL];
		[UIView setAnimationDuration:0.5];
		[self.navigationController.navigationBar setAlpha:1.0];
		[UIView commitAnimations];
		
		if (activeIndex > 0) {
			hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
		}
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (zooming) {
		zooming = NO;
		
		UIScrollView *scrollView = (UIScrollView *)[self view];
		
		scrollView.pagingEnabled = YES;
		scrollView.directionalLockEnabled = YES;
	}
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIScrollView *scrollView = (UIScrollView *)[self view];

	[self setupLayouts];
	
	for (UIView *subView in self.view.subviews) {
		if ([subView isKindOfClass:[PhotoView class]]) {
			subView.frame = CGRectMake(subView.tag * scrollView.frame.size.width, 0.0, (scrollView.frame.size.width - 15.0), scrollView.frame.size.height);
			
			[(PhotoView *)subView resetScale];
		} else if ([subView isKindOfClass:[ArticleView class]]) {
			subView.frame = CGRectMake(0.0, 0.0, (scrollView.frame.size.width - 15.0), scrollView.frame.size.height);
			
			[(ArticleView *)subView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 30.0, 0.0, 0.0, 0.0)];
			
			[subView setNeedsLayout];
		}
	}

	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.frame.size.height)];
	[scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * activeIndex, 0.0)];
	[scrollView setContentInset:UIEdgeInsetsZero];
}


- (void)addPhoto:(NSUInteger)indexNum {
	Photo *photo = [imageList objectAtIndex:indexNum];
	PhotoView *imageView = [[PhotoView alloc] initWithFrame:CGRectMake((indexNum + 1) * self.view.frame.size.width, 0.0, (self.view.frame.size.width - 15.0), self.view.frame.size.height)];

	imageView.photo = photo;
	imageView.tag = indexNum + 1;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.userInteractionEnabled = YES;
	imageView.delegate = self;

	[self.view addSubview:imageView];
	[imageViewsList replaceObjectAtIndex:indexNum withObject:imageView];
	
	[imageView release];
}


- (void)doneLoadingPage:(NSString *)htmlData {
	NSArray *imgMatches;
//	NSArray *photoMatches;
	NSString *imgRegEx = @"<img src=\"(.*?)\" class=\"bpImage\"";
//	NSString *captionRegEx = @"<div class=\"bpCaption\"><div class=\"photoNum\"><a href=\"#photo[0-9]+\">[0-9]+</a></div>(.*?)<a href";
	
	imgMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:imgRegEx];

	for (NSArray *imgOptions in imgMatches) {
		Photo *photo = [[Photo alloc] init];
		
		photo.url = [NSURL URLWithString:[imgOptions objectAtIndex:1]];
		
		[imageList addObject:photo];
		[imageViewsList addObject:[NSNull null]];
		
		[photo release];
	}
	
//	photoMatches = [htmlData arrayOfCaptureComponentsMatchedByRegex:RE_PHOTO];
//	NSLog(@"Photos: %@", photoMatches);
	
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	[scrollView setContentSize:CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.contentSize.height)];
	
	[loadingIndicator stopAnimating];
	
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
	if (zooming || activeIndex < 1) return;
	
	if ((NSNull *)[imageViewsList objectAtIndex:activeIndex - 1] == [NSNull null]) {
		[self addPhoto:activeIndex - 1];
	}
	
	if (activeIndex > 2) {
		UIView *previousView = [imageViewsList objectAtIndex:activeIndex - 3];

		if ((NSNull *)previousView != [NSNull null]) {
			[previousView removeFromSuperview];
			
			[imageViewsList replaceObjectAtIndex:activeIndex - 3 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] - 4) {
		UIView *nextView = [imageViewsList objectAtIndex:activeIndex + 1];

		if ((NSNull *)nextView != [NSNull null]) {
			[nextView removeFromSuperview];
			
			[imageViewsList replaceObjectAtIndex:activeIndex + 1 withObject:[NSNull null]];
		}
	}
	
	if (activeIndex < [imageList count] && (NSNull *)[imageViewsList objectAtIndex:activeIndex] == [NSNull null]) {
		[self addPhoto:activeIndex];
	}
	
	if (activeIndex > 1 && (NSNull *)[imageViewsList objectAtIndex:activeIndex - 2] == [NSNull null]) {
		[self addPhoto:activeIndex - 2];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (!zooming) {
		activeIndex = (scrollView.contentOffset.x < 0.0) ? 0 : floor(scrollView.contentOffset.x / self.view.frame.size.width);
		
		if (activeIndex == 0) {
			if (hideTimer != nil) {
				[hideTimer invalidate];
				
				hideTimer = nil;
			}
			
			if (self.navigationController.navigationBar.alpha == 0.0) [self showInterface];
		} else if (self.navigationController.navigationBar.alpha > 0.0 && hideTimer == nil) {
			hideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideInterface) userInfo:nil repeats:NO];
		}
		
		[self prepNeighbours];
	}
}


- (void)didBeginZoomingOnView:(PhotoView *)view {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	
	scrollView.scrollEnabled = NO;
}


- (void)didEndZoomingOnView:(PhotoView *)view withCenterPoint:(CGPoint)centerPoint {
	UIScrollView *scrollView = (UIScrollView *)[self view];
	CGFloat viewHeight = (view.frame.size.height < scrollView.frame.size.height) ? scrollView.frame.size.height : view.frame.size.height;
	CGFloat viewWidth = (view.frame.size.width < scrollView.frame.size.width - 15.0) ? scrollView.frame.size.width - 15.0 : view.frame.size.width;
	
	scrollView.scrollEnabled = YES;

	if (view.currentZoomScale <= 1.0) {
		zooming = NO;
		
		view.frame = CGRectMake(scrollView.frame.size.width * view.tag, 0.0, viewWidth, viewHeight);
		
		scrollView.pagingEnabled = YES;
		scrollView.directionalLockEnabled = YES;
		scrollView.contentInset = UIEdgeInsetsZero;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * ([imageList count] + 1), scrollView.frame.size.height);
		scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * view.tag, 0.0);
	} else {
		zooming = YES;
		
		CGFloat centerX = (view.frame.size.width < scrollView.frame.size.width - 15.0) ? 0.0 : centerPoint.x + 8.0 - scrollView.frame.size.width / 2;
		CGFloat centerY = (view.frame.size.height < scrollView.frame.size.height) ? 0.0 : centerPoint.y - scrollView.frame.size.height / 2;
		
		view.frame = CGRectMake(0.0, 0.0, viewWidth, viewHeight);
		
		scrollView.pagingEnabled = NO;
		scrollView.directionalLockEnabled = NO;
		scrollView.contentInset = UIEdgeInsetsZero;
		scrollView.contentSize = view.frame.size;
		
		if (centerX + scrollView.frame.size.width > scrollView.contentSize.width) centerX = scrollView.contentSize.width - scrollView.frame.size.width;

		scrollView.contentOffset = CGPointMake(MAX(centerX, 0.0), MAX(centerY, 0.0));
	}
	
	for (UIView *subView in scrollView.subviews) {
		if ([subView isKindOfClass:[ArticleView class]] || ([subView isKindOfClass:[PhotoView class]] && subView.tag != view.tag)) {
			CGFloat x;
			
			if (subView.tag < view.tag) {
				x = view.frame.origin.x - (view.tag - subView.tag) * scrollView.frame.size.width;
			} else if (subView.tag > view.tag) {
				x = view.frame.origin.x + view.frame.size.width + 15.0 + (subView.tag - view.tag - 1) * scrollView.frame.size.width;
			}
			
			subView.frame = CGRectMake(x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
		}
	}
}


- (void)didSingleTapOnView:(PhotoView *)view withPoint:(CGPoint)point {
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showInterface) userInfo:nil repeats:NO];
}


- (void)didDoubleTapOnView:(PhotoView *)view withPoint:(CGPoint)point {
	if (hideTimer != nil) {
		[hideTimer invalidate];
		
		hideTimer = nil;
	}
	
	[self didEndZoomingOnView:view withCenterPoint:point];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[article release];
	[loadingIndicator release];
	[imageList release];
	[imageViewsList release];
    [super dealloc];
}

@end
