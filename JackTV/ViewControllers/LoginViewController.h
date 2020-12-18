

#import <UIKit/UIKit.h>
#import "ApplicationData.h"
#import <Google/SignIn.h>


@class GIDSignInButton;

@interface LoginViewController : UIViewController<UITextFieldDelegate,HTTPManagerDelegate, GIDSignInUIDelegate>
{
    ApplicationData *appData;
    NSString *m_password;
    
    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UIImageView *imgLogo;
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnRegister;
    IBOutlet UIView *viewSignIn;
    IBOutlet UIView *splashView;
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (IBAction)onGoogleSignButton:(id)sender;
@end
