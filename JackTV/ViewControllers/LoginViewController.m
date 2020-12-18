
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "HTTPManager.h"
#import "ViewController.h"



@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    appData = [ApplicationData sharedInstance];
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 35)];
    imgTitle.backgroundColor = [UIColor clearColor];
    imgTitle.image = [UIImage imageNamed:@"logo.png"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.navigationItem setTitleView:imgTitle];

    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    aView.backgroundColor = [UIColor clearColor];
    [txtPassword setLeftView:aView];
    [txtPassword setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *aView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    aView1.backgroundColor = [UIColor clearColor];
    [txtUsername setLeftView:aView1];
    [txtUsername setLeftViewMode:UITextFieldViewModeAlways];
    
    btnLogin.layer.borderWidth = 1.0;
    btnLogin.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if (self.view.frame.size.width > 320)
    {
        CGRect logoRect = imgLogo.frame;
        logoRect.origin.y = logoRect.origin.y + 30;
        logoRect.size.width += 60;
        logoRect.size.height += 60;
        logoRect.origin.x = (self.view.frame.size.width - logoRect.size.width)/2;
        imgLogo.frame = logoRect;
        
        CGRect signInRect = viewSignIn.frame;
        signInRect.origin.y += 30;
        viewSignIn.frame = signInRect;
    }else{
        CGRect signInRect = viewSignIn.frame;
        signInRect.origin.y += 20;
        viewSignIn.frame = signInRect;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"googleid"] || [[NSUserDefaults standardUserDefaults] valueForKey:@"email"])
    {
        splashView.hidden = NO;
        
    }else{
        
        splashView.hidden = YES;
    }

    [self.navigationController setNavigationBarHidden:YES];
    
    txtUsername.text = @"";
    txtPassword.text = @"";
}

-(IBAction)btnLoginViewEmailPressed
{
    SignUpViewController *aSignUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"signupController"];
    [self.navigationController pushViewController:aSignUpViewController animated:YES];
}

#pragma mark - button events
-(IBAction)btnLoginPressed:(id)sender
{
    if ([appData connectedToNetwork])
    {
        txtPassword.text = [txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (![appData validateEmail:txtUsername.text] || [txtUsername.text length] == 0 || [txtPassword.text length] == 0)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter valid username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else
        {
            [self LoginMethod:txtUsername.text Password:txtPassword.text];
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"googleSignIn"];
        }
    }
}

-(IBAction)btnRegisterPressed:(id)sender{
    SignUpViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"signupController"];
    [self.navigationController pushViewController:lvc animated:YES];
}

-(IBAction)btnForgotPassWordPressed:(id)sender{
    
    if ([appData connectedToNetwork])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Forgot Password?" message:@"Please enter your email address to recover password." delegate:self cancelButtonTitle:@"Submit" otherButtonTitles:@"Cancel",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.delegate = self;
        alert.tag = 1001;
        [alert show];
    }
}


-(void)LoginMethod:(NSString *)Email Password:(NSString *)password
{
    m_password = password;
    NSArray *keys=[NSArray arrayWithObjects:@"method",@"email", @"password", nil];
    NSArray *values=[NSArray arrayWithObjects:@"Login",Email, password, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    [appData showLoader];
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jLoginQuery;
    manager.postString=request;
    [manager startDownload];
}

-(void)ForgotPasswordMethod:(NSString *)Email
{
    NSArray *keys=[NSArray arrayWithObjects:@"method",@"email", nil];
    NSArray *values=[NSArray arrayWithObjects:@"ForgotPassword",Email, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    [appData showLoader];
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jForgotPassword;
    manager.postString=request;
    [manager startDownload];
}

- (IBAction)onGoogleSignButton:(id)sender
{
    [appData showLoader];
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - HttpManager delegate
-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response
{
    NSLog(@"%@", response);
    [appData hideLoader];
    if (manger.requestType == jLoginQuery)
    {
        if ([[response valueForKey:@"success"] intValue] == jSuccess)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"email"] forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setValue:m_password forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"googleid"] forKey:@"googleid"];
            [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"fname"] forKey:@"fname"];
            [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"lname"] forKey:@"lname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
            lvc.bFirst = YES;
            [self.navigationController pushViewController:lvc animated:YES];
            
        }else{
        
        }
    }
    else if (manger.requestType == jForgotPassword)
    {
        if ([[response valueForKey:@"success"] intValue] == jSuccess)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[response valueForKey:@"msg"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        if (buttonIndex == 0) {
            UITextField *txtField = [alertView textFieldAtIndex:0];
            [self ForgotPasswordMethod:txtField.text];
        }
    }
}

#pragma mark - textfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3f animations:^{
        self.topConstraint.constant = -100;
        self.bottomConstraint.constant = 100;
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.3f animations:^{
        self.topConstraint.constant = 0;
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - touch events
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3f animations:^{
        self.topConstraint.constant = 0;
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}


#pragma mark - GIDSignInUIDelegate

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    [appData hideLoader];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"googleSignIn"];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end


