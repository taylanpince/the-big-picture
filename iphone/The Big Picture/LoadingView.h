//
//  LoadingView.h
//  The Big Picture
//
//  Created by Taylan Pince on 18/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

@interface LoadingView : UIView {
	UILabel *label;
	UIActivityIndicatorView *loadingIndicator;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

- (void)stopAnimating;

@end
