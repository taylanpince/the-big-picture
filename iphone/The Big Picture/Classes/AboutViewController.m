//
//  AboutViewController.m
//  The Big Picture
//
//  Created by Taylan Pince on 25/06/09.
//  Copyright 2009 Taylan Pince. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
		
		UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		[logoButton setImage:[UIImage imageNamed:@"LargeIcon.png"] forState:UIControlStateNormal];
		[logoButton setFrame:CGRectMake(110.0, 15.0, 100.0, 100.0)];
		[logoButton addTarget:self action:@selector(launchCompanySite) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:logoButton];
		
		UIButton *appButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		[appButton setTitle:@"Big Picture v1.0.3\nby Hippo Foundry →" forState:UIControlStateNormal];
		[appButton.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
		[appButton.titleLabel setTextColor:[UIColor whiteColor]];
		[appButton.titleLabel setNumberOfLines:0];
		[appButton.titleLabel setTextAlignment:UITextAlignmentCenter];
		[appButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
		[appButton setFrame:CGRectMake(90.0, 118.0, 150.0, 40.0)];
		[appButton addTarget:self action:@selector(launchCompanySite) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:appButton];
		
		UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 160.0, 280.0, 200.0)];
		
		[infoLabel setOpaque:NO];
		[infoLabel setBackgroundColor:[UIColor clearColor]];
		[infoLabel setNumberOfLines:0];
		[infoLabel setText:@"The Big Picture is a photo blog for the Boston Globe/boston.com, entries are posted every Monday, Wednesday and Friday by Alan Taylor.\n\nThis application has no affiliations with Boston Globe, boston.com or Alan Taylor. All content shown is either owned, licensed or shared by boston.com through their RSS feeds and web site."];
		[infoLabel setFont:[UIFont systemFontOfSize:14.0]];
		[infoLabel setLineBreakMode:UILineBreakModeWordWrap];
		[infoLabel setTextColor:[UIColor whiteColor]];
		
		[self.view addSubview:infoLabel];
		[infoLabel release];
		
		UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		[contactButton setTitle:@"For any questions about this app, contact us via support@hippofoundry.com →" forState:UIControlStateNormal];
		[contactButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
		[contactButton.titleLabel setTextColor:[UIColor whiteColor]];
		[contactButton.titleLabel setNumberOfLines:0];
		[contactButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
		[contactButton setFrame:CGRectMake(20.0, 365.0, 280.0, 40.0)];
		[contactButton addTarget:self action:@selector(launchCompanySupport) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:contactButton];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
}


- (IBAction)dismissView {
	[delegate didDismissAboutView];
}


- (void)launchCompanySite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hippofoundry.com"]];
}


- (void)launchCompanySupport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:support@hippofoundry.com"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [super dealloc];
}


@end
