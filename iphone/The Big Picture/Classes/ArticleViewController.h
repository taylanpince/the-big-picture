//
//  ArticleViewController.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "PhotoView.h"

@class Article;


@interface ArticleViewController : UIViewController <UIScrollViewDelegate, PhotoViewDelegate> {
	Article *article;
	NSMutableArray *imageList;
	NSMutableArray *imageViewsList;
	NSUInteger activeIndex;
	NSTimer *hideTimer;
}

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) NSMutableArray *imageList;
@property (nonatomic, retain) NSMutableArray *imageViewsList;
@property (nonatomic, assign) NSUInteger activeIndex;
@property (nonatomic, retain) NSTimer *hideTimer;

@end
