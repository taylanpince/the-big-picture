//
//  ArticleViewController.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "PhotoView.h"
#import "URLCacheConnection.h"

@class Article;


@interface ArticleViewController : UIViewController <UIScrollViewDelegate, PhotoViewDelegate, URLCacheConnectionDelegate> {
	Article *article;
	UIActivityIndicatorView *loadingIndicator;
	NSMutableArray *imageList;
	NSMutableArray *imageViewsList;
	NSUInteger activeIndex;
	NSTimer *hideTimer;
	
	BOOL zooming;
}

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) NSMutableArray *imageList;
@property (nonatomic, retain) NSMutableArray *imageViewsList;
@property (nonatomic, assign) NSUInteger activeIndex;
@property (nonatomic, retain) NSTimer *hideTimer;

@property (nonatomic, assign) BOOL zooming;

@end
