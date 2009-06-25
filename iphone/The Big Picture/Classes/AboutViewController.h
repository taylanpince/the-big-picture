//
//  AboutViewController.h
//  The Big Picture
//
//  Created by Taylan Pince on 25/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

@protocol AboutViewControllerDelegate;


@interface AboutViewController : UIViewController {
	id <AboutViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <AboutViewControllerDelegate> delegate;

- (IBAction)dismissView;

@end


@protocol AboutViewControllerDelegate

- (void)didDismissAboutView;

@end
