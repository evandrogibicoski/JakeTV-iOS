
#import "AppDelegate.h"
#import "ApplicationData.h"
#import "ViewController.h"
#import "ChangePasswordViewController.h"
#import "ViewController.h"
#import "LoginViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    [GIDSignIn sharedInstance].delegate = self;
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    appData = [ApplicationData sharedInstance];
    appData.postType = ALLPOST;
    NSLog (@"Font families: %@", [UIFont familyNames]);
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];

    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = 0.5;
    [SlideNavigationController sharedInstance].portraitSlideOffset = 100;
    
    [[UINavigationBar appearance] setTintColor:[UIColor lightGrayColor]];
    
    
    if ([appData connectedToNetwork]){
    
        NSLog(@"Status: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"googleSignIn"]);
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"googleSignIn"] isEqualToString:@"1"])
        {
            [self singInwithGooglePlus:[[NSUserDefaults standardUserDefaults] valueForKey:@"googleid"] firstname:[[NSUserDefaults standardUserDefaults] valueForKey:@"fname"] lastname:[[NSUserDefaults standardUserDefaults] valueForKey:@"lname"] email:[[NSUserDefaults standardUserDefaults] valueForKey:@"email"]];
            
        }else if ([[NSUserDefaults standardUserDefaults] valueForKey:@"email"] && [[NSUserDefaults standardUserDefaults] valueForKey:@"password"]){
            
            [self loginMethodWith:[[NSUserDefaults standardUserDefaults] valueForKey:@"email"] andPassword:[[NSUserDefaults standardUserDefaults] valueForKey:@"password"]];
        }
    }
    
    return YES;
}

- (BOOL)application: (UIApplication *)application openURL: (NSURL *)url sourceApplication: (NSString *)sourceApplication annotation: (id)annotation {
    
    NSString *StrURL = [url description];
    if([StrURL rangeOfString:@"jaketvpassword"].length !=0)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        ChangePasswordViewController *lvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
        lvc.openUrlID = StrURL;
        [(UINavigationController*)self.window.rootViewController pushViewController:lvc animated:YES];

        return YES;
    }else{
        return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSString *StrURL = [url description];
    if([StrURL rangeOfString:@"jaketvpassword"].length !=0)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        ChangePasswordViewController *lvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
        lvc.openUrlID = StrURL;
        [(UINavigationController*)self.window.rootViewController pushViewController:lvc animated:YES];
        
        return YES;
        
    }else{
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];

    }
}

#pragma mark - GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *googleId = user.userID;                  // For client-side use only!
    //NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *fName = user.profile.givenName;
    NSString *lName = user.profile.familyName;
    NSString *email = user.profile.email;
    // ...
    if (googleId == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"googleSignIn"];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:googleId forKey:@"googleid"];
    [[NSUserDefaults standardUserDefaults] setValue:fName forKey:@"fname"];
    [[NSUserDefaults standardUserDefaults] setValue:lName forKey:@"lname"];
    [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setValue:fullName forKey:@"fullname"];
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"googleSignIn"];
    [self singInwithGooglePlus:googleId firstname:fName lastname:lName email:email];
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) {
        NSLog(@"Received error %@", error);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
    }
}

#pragma mark - 

-(void)loginMethodWith:(NSString *)Username andPassword:(NSString *)password
{
    NSArray *keys=[NSArray arrayWithObjects:@"method",@"email", @"password", nil];
    NSArray *values=[NSArray arrayWithObjects:@"Login",Username, password, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jLoginQuery;
    manager.postString=request;
    [manager startDownload];

}

-(void)singInwithGooglePlus:(NSString*)googleID firstname:(NSString*)firstname lastname:(NSString*)lastname email:(NSString*)email
{
    NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid", @"googleplusid",@"fname",@"lname",@"email",@"password",nil];
    NSArray *values=[NSArray arrayWithObjects:@"Registration",@"0",googleID,firstname,lastname,email,@"",nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jLoginQuery;
    manager.postString=request;
    [manager startDownload];
    
}

-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response
{
    if ([[response valueForKey:@"success"] integerValue]== jSuccess)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        ViewController *lvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeController"];
        lvc.bFirst = YES;
        [(UINavigationController*)self.window.rootViewController pushViewController:lvc animated:YES];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"googleid"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"fname"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lname"];
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"googleSignIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *vc = [mainStoryborad instantiateViewControllerWithIdentifier:@"LoginVC"];
        [(UINavigationController*)self.window.rootViewController pushViewController:vc animated:YES];
    }
}

@end
