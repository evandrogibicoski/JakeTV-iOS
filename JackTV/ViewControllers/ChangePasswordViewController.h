

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ApplicationData.h"

@interface ChangePasswordViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CLLocationManagerDelegate,HTTPManagerDelegate>
{
    ApplicationData *appData;
    IBOutlet UITableView *tblForgetPwd;
    NSMutableArray *arrCaptions;
    
    UITextField *currentTextField;
    
    NSMutableArray *cellArray;
    NSMutableArray *arrData;
    NSString *openUrlID;
    
}

@property(nonatomic, strong) NSString *openUrlID;
@end
