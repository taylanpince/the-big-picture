//
//  Photo.h
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface Photo : NSObject {
	NSURL *url;
	NSString *caption;
	
	BOOL graphic;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, assign) BOOL graphic;

@end
