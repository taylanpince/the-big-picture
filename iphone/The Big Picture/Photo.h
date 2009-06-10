//
//  Photo.h
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface Photo : NSObject {
	NSURL *url;
	UIImage *image;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) UIImage *image;

@end
