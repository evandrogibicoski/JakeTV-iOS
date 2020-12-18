#import <Foundation/Foundation.h>
#import "ConstantsList.h"
#import "MBProgressHUD.h"
#import "HTTPManager.h"
#import "SBJson.h"
#import "User.h"


#define BACKGROUND_COLOR [UIColor colorFromHexCode:@"#FFFFFF"] //f5f7fa
#define DETAIL_COLOR [UIColor colorFromHexCode:@"389ce8"]
#define AuthanticationKey @"1upH3R3"

typedef enum
{
    ALLPOST,
    BOOKMARK,
    LIKE,
    CATEGORY
} PostsType;

@interface ApplicationData : NSObject <UIAlertViewDelegate,HTTPManagerDelegate>
{
    User *aUser;
    MBProgressHUD *hud;
    
    BOOL isiPad;
    NSDateFormatter *dtTimeFormatter;
    NSDateFormatter *dtFormatter;
    
    NSDateFormatter *timeFormatter;
    BOOL isForPostTag;
    PostsType postType;
    NSMutableArray *arrSelectedCat;
    NSString *selectedCat;
    NSIndexPath *lastSelectedIndex;
    BOOL isOpenUrl;
}

@property (nonatomic, readwrite) BOOL isOpenUrl;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndex;
@property (nonatomic, strong) NSString *selectedCat;
@property (nonatomic, strong) NSMutableArray *arrSelectedCat;
@property (nonatomic, readwrite) PostsType postType;
@property (nonatomic, retain) User *aUser;
@property (nonatomic, retain) UIView *aViewController;
@property (nonatomic, readwrite)BOOL isForPostTag;
@property (nonatomic, readwrite) BOOL isLoggedFromFacebook;
@property(nonatomic)BOOL isiPad;
@property (nonatomic, strong) NSString *strDeviceToken;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, readwrite) BOOL isPrivacy;
@property (nonatomic, readwrite) NSInteger totalPages;
+ (ApplicationData*)sharedInstance;

-(void)showLoader;
-(void)hideLoader;
-(BOOL)connectedToNetwork;
-(void)ShowAlert:(NSString*)title andMessage:(NSString*)messsage;
- (NSData*)createFormData:(NSDictionary*)myDictionary withBoundary:(NSString*)myBounds;
- (BOOL) validateEmail: (NSString *) candidate;
-(NSString *)getTimeFromDateString:(NSString *)strDate;
-(NSDate*)getDateTimeFromString:(NSString*)strDate;
-(NSString*)getStringFromTime:(NSDate*)time;
-(NSString*)getStringFromDate:(NSDate*)aDate;
-(BOOL)checkInternetRechability;


@end
