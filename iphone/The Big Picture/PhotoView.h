//
//  PhotoView.h
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

@protocol PhotoViewDelegate;


@interface PhotoView : UIImageView {
	CGFloat initialDistance;
	
	id <PhotoViewDelegate> delegate;
}

@property (nonatomic, assign) CGFloat initialDistance;

@property (nonatomic, assign) id <PhotoViewDelegate> delegate;

@end


@protocol PhotoViewDelegate
- (void)didBeginZoomingOnView:(PhotoView *)view;
- (void)didEndZoomingOnView:(PhotoView *)view;
- (void)didSingleTapOnView:(PhotoView *)view;
- (void)didDoubleTapOnView:(PhotoView *)view;
@end
