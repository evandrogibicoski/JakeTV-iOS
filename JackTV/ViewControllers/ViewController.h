
#import <UIKit/UIKit.h>
#import "ApplicationData.h"
#import <MessageUI/MessageUI.h>
#import "UITableView+DynamicCell.h"



@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITableViewDynamicDelegate, HTTPManagerDelegate, UISearchBarDelegate, MFMailComposeViewControllerDelegate>
{
    BOOL                isLoaingMore;
    
    NSString            *strAdVideoUrl;
    
    IBOutlet UITableView    *tblPosts;
    ApplicationData         *appData;
    
    NSMutableArray          *arrPostList;
    NSMutableArray          *arrTempPostList;
    NSMutableArray          *arrAdList;
    
    NSInteger               currentPage;
    
    UISearchBar             *searchBarPost;
    BOOL                    isSearchFirstTime;
    IBOutlet UIView         *viewAlert;
    IBOutlet UIImageView    *imageBookMark;
    IBOutlet UIImageView    *imageLike;
}

@property (nonatomic) BOOL bFirst;

@property (weak, nonatomic) IBOutlet UIView             *adView;
@property (weak, nonatomic) IBOutlet UIImageView        *adImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIView *popupContentView;
@property (weak, nonatomic) IBOutlet UIView *popupSubdescribedView;

- (IBAction)onAdView:(id)sender;

- (IBAction)onSignmeup:(id)sender;
- (IBAction)onNothanks:(id)sender;
- (IBAction)onAskmelater:(id)sender;
- (IBAction)onDismiss:(id)sender;

@end

