

#define ROBOTO_REGULAR @"Roboto-Regular"
#define ROBOTO_THIN @"Roboto-Thin"
#define ROBOTO_MEDIUM @"Roboto-Medium"

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "ApplicationData.h"
#import <Google/SignIn.h>
#import <Google/Analytics.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, HTTPManagerDelegate, GIDSignInDelegate>{

    ApplicationData *appData;
}

@property (strong, nonatomic) UIWindow *window;

@end

