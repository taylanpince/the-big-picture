//
//  Photo.m
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "Photo.h"


@implementation Photo

@synthesize url, caption, graphic;

- (void)dealloc {
	[url release];
	[caption release];
	[super dealloc];
}

@end
