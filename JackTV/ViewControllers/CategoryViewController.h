#import <UIKit/UIKit.h>
#import "ApplicationData.h"

@interface CategoryViewController : UIViewController<HTTPManagerDelegate>{

    ApplicationData *appData;
    NSMutableArray *arrCatList;
    IBOutlet UITableView *tblViewCat;
    NSMutableArray *selectedRowsArray;
}

@end
