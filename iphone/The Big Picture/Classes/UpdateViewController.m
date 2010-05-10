    //
//  UpdateViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 10-05-10.
//  Copyright 2010 Hippo Foundry. All rights reserved.
//

#import "UpdateViewController.h"


@interface UpdateViewController (PrivateMethods)
- (void)didTapDoneButton:(id)sender;
@end


@implementation UpdateViewController

- (void)loadView {
	UIWebView *mainView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	self.view = mainView;
	
	[mainView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Updates"];
	[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.26 green:0.5 blue:0.76 alpha:1.0]];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButton:)];
	
	[self.navigationItem setRightBarButtonItem:doneButton];
	[doneButton release];
	
	[(UIWebView *)self.view loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"updates" ofType:@"html"] isDirectory:NO]]];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:updateViewPrefsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didTapDoneButton:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

@end
