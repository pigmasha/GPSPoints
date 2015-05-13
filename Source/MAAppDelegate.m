//
//  AppDelegate.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAAppDelegate.h"
#import "MAController.h"

@interface MAAppDelegate ()
{
    UIWindow* _window;
}
@end

//=================================================================================

@implementation MAAppDelegate

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_window release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    
    [MAController initSharedInstance];
    [MA_CONTROLLER loadInWindow: _window];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
