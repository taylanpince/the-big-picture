//
//  ArticleViewController.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

@class Article;


@interface ArticleViewController : UIViewController {
	Article *article;
	NSMutableArray *imageList;
}

@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) NSMutableArray *imageList;

@end
