
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ApplicationData.h"

@interface SignUpViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CLLocationManagerDelegate,HTTPManagerDelegate>
{
    ApplicationData *appData;
    IBOutlet UITableView *tblSignUp;
    NSMutableArray *arrCaptions;
    
    UITextField *currentTextField;
    
    NSMutableArray *cellArray;
    NSMutableArray *arrData;
    
    NSString *m_password;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end
