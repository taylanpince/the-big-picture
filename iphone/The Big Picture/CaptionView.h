//
//  CaptionView.h
//  The Big Picture
//
//  Created by Taylan Pince on 13/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//


@interface CaptionView : UIView {
	UILabel *label;
	NSString *caption;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *caption;

@end
