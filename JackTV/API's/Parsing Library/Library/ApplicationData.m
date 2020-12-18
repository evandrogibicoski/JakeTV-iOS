
#import "ApplicationData.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>
#import "Reachability.h"

NSString *databaseName = @"Inspections_db.sqlite3";

static ApplicationData *applicationData = nil;

@implementation ApplicationData

@synthesize aViewController;
@synthesize isiPad,isForPostTag;
@synthesize isLoggedFromFacebook;
@synthesize strDeviceToken;
@synthesize longitude,latitude;
@synthesize isPrivacy,totalPages;
@synthesize aUser;
@synthesize postType;
@synthesize arrSelectedCat;
@synthesize selectedCat;
@synthesize lastSelectedIndex;
@synthesize isOpenUrl;

-(void)initialize // Initilize Default Values Here
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        isiPad=TRUE;
    }
    else
    {
        isiPad=FALSE;
    }
   
    dtFormatter=[[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"YYYY-MM-dd"];
    
    dtTimeFormatter=[[NSDateFormatter alloc] init];
    [dtTimeFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    timeFormatter=[[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:GENERAL_TIME_FORMAT];
    
    arrSelectedCat = [[NSMutableArray alloc]init];
}
+ (ApplicationData*)sharedInstance {
    if (applicationData == nil) {
        applicationData = [[super allocWithZone:NULL] init];
		[applicationData initialize];
    }
    return applicationData;
}

#pragma mark -
#pragma MBProgressHUD Methods
#pragma mark -

-(void)showLoader
{
    if(![UIApplication sharedApplication].isNetworkActivityIndicatorVisible)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
        if(!hud)
        {
            hud = [[MBProgressHUD alloc] init];
            
            hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
           
        }
        else{
       
            [[UIApplication sharedApplication].keyWindow addSubview:hud];
        }
    }
}

-(void)hideLoader
{
    if([UIApplication sharedApplication].isNetworkActivityIndicatorVisible)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [hud removeFromSuperview];
    }
}

-(BOOL)checkInternetRechability
{
    BOOL isConnectedToInternet;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    };
    
    if (reach.isReachable)
    {
        NSLog(@"Connected");
        isConnectedToInternet = TRUE;
    }
    else
    {
        NSLog(@"Not Connected");
        isConnectedToInternet = FALSE;
    }
    
        [reach startNotifier];
    
    return isConnectedToInternet;
    
}


- (void)reachabilityChanged:(NSNotification *)notice {
    // called after network status changes
    
}


-(void)ShowAlert:(NSString*)title andMessage:(NSString*)messsage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messsage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Internet Connection
- (BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    BOOL isconnected = (isReachable && !needsConnection) ? YES : NO;
    
    if (!isconnected) {
        [[ApplicationData sharedInstance] ShowAlert:@"Alert" andMessage:@"Please check your internet connectivity."];        
    }
    
    return isconnected;
}

-(NSDate*)getDateFromString:(NSString*)strDate
{
    return [dtFormatter dateFromString:strDate];
}
-(NSString*)getStringFromTime:(NSDate*)time
{
    return [timeFormatter stringFromDate:time];
}

-(NSString*)getStringFromDate:(NSDate*)aDate
{
    return [dtFormatter stringFromDate:aDate];
}

-(NSDate*)getDateTimeFromString:(NSString*)strDate
{
    return [dtTimeFormatter dateFromString:strDate];
}
-(NSString*)getStringFromDateTime:(NSDate*)aDate
{
    return [dtTimeFormatter stringFromDate:aDate];
}

- (NSData*)createFormData:(NSDictionary*)myDictionary withBoundary:(NSString*)myBounds
{
    NSString *jsonString = [myDictionary JSONRepresentation];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];

    jsonString=[ApplicationData encodeStringForURL:jsonString];
    NSMutableDictionary *jsonRequest=[jsonString JSONValue];
    
    NSArray *tempArr = [jsonRequest valueForKey:@"invite_friends"];
    NSString *jsonString1 = [tempArr JSONRepresentation];
    jsonString1 = [jsonString1 stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    [jsonRequest setValue:jsonString1 forKey:@"invite_friends"];
    NSLog(@"%@",[jsonRequest description]);
    
    NSMutableData *myReturn = [[NSMutableData alloc] init];
    
    NSArray *formKeys = [jsonRequest allKeys];
    for (int i = 0; i < [formKeys count]; i++)
    {
        
        [myReturn appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBounds] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *value=[jsonRequest valueForKey:[formKeys objectAtIndex:i]];
        
        [myReturn appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",[formKeys objectAtIndex:i],value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return myReturn;
}

+ (NSString *)encodeStringForURL:(NSString *)originalURL
{
    NSString *escaped = [[NSString alloc] initWithString:originalURL];
    
    escaped=[escaped stringByReplacingOccurrencesOfString:@"&" withString:@"amp;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    return escaped;
}
- (BOOL) validateEmail: (NSString *) candidate {
    
    if([[candidate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] length] == 0)
        return YES;
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	
    return [emailTest evaluateWithObject:candidate];
}

-(NSString *)getTimeFromDateString:(NSString *)strDate
{
    NSDateFormatter *timeFormatter1 = [[NSDateFormatter alloc] init];
    [timeFormatter1 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *aDate = [timeFormatter1 dateFromString:strDate];
    
    [timeFormatter1 setDateFormat:@"HH:mm"];
    
    return [timeFormatter1 stringFromDate:aDate];
}


@end
