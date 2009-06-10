//
//  TheBigPictureAppDelegate.h
//  The Big Picture
//
//  Created by Taylan Pince on 09/06/09.
//  Copyright Taylan Pince 2009. All rights reserved.
//

@interface TheBigPictureAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
