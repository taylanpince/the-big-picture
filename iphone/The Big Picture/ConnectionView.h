//
//  ConnectionView.h
//  The Big Picture
//
//  Created by Taylan Pince on 15/07/09.
//  Copyright 2009 Hippo Foundry. All rights reserved.
//

@interface ConnectionView : UIView {
	UILabel *label;
	UIActivityIndicatorView *loadingIndicator;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

- (void)stopAnimating;

@end
