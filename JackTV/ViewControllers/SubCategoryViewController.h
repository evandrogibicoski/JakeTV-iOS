
#import <UIKit/UIKit.h>
#import "ApplicationData.h"

@interface SubCategoryViewController : UIViewController<HTTPManagerDelegate>{

    ApplicationData *appData;
    IBOutlet UITableView *tblViewSubCat;
    NSMutableArray *selectedRowsArray;
    NSMutableArray *arrSubCatList;
    NSString *strTitle;
}
@property(nonatomic,strong) NSString *strTitle;
@property(nonatomic,strong) NSMutableArray *arrSubCatList;
@end
