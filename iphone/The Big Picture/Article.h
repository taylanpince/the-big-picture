//
//  Article.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface Article : NSObject {
	NSString *guid;
	NSString *title;
	NSString *description;
	NSURL *url;
	NSDate *timestamp;
	
	BOOL unread;
}

@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSDate *timestamp;
@property (nonatomic, assign) BOOL unread;

@end
