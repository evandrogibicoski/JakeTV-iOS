
#import <UIKit/UIKit.h>
#import "SinglePost.h"
#import "ApplicationData.h"

@interface DetailViewController : UIViewController<HTTPManagerDelegate>
{
    IBOutlet UIWebView *aWebView;
    ApplicationData *appData;
    BOOL isLike;
    BOOL isBookMark;
    IBOutlet UIBarButtonItem *btnLike;
    IBOutlet UIBarButtonItem *btnBookmark;
}

@property (nonatomic, retain) SinglePost *aSinglePost;
@end
