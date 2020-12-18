
#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController<UIWebViewDelegate>{

    IBOutlet UIWebView *webView;
    
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrev;
    UIActivityIndicatorView *actView;
}

@end
