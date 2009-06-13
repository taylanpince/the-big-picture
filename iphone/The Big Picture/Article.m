//
//  Article.m
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "Article.h"


@implementation Article

@synthesize guid, title, description, url, timestamp, unread;

- (void)dealloc {
	[guid release];
	[title release];
	[description release];
	[url release];
	[timestamp release];
	[super dealloc];
}

@end
