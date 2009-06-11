//
//  PhotoView.h
//  The Big Picture
//
//  Created by Taylan Pince on 10/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

@protocol PhotoViewDelegate;

@class Photo;


@interface PhotoView : UIImageView {
	Photo *photo;
	UIActivityIndicatorView *loadingIndicator;
	
	CGFloat initialDistance;
	CGFloat maximumZoomScale;
	CGFloat currentZoomScale;
	
	id <PhotoViewDelegate> delegate;
}

@property (nonatomic, assign) Photo *photo;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, assign) CGFloat initialDistance;
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) CGFloat currentZoomScale;

@property (nonatomic, assign) id <PhotoViewDelegate> delegate;

@end


@protocol PhotoViewDelegate
- (void)didBeginZoomingOnView:(PhotoView *)view;
- (void)didEndZoomingOnView:(PhotoView *)view;
- (void)didSingleTapOnView:(PhotoView *)view;
- (void)didDoubleTapOnView:(PhotoView *)view;
@end
