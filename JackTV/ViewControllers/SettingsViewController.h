
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "ApplicationData.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    ApplicationData *appData;
    IBOutlet UITableView *tblSettings;
    NSMutableArray *arrImages;
    NSMutableArray *arrSections;
    NSMutableArray *arrTitles;
}
@end
