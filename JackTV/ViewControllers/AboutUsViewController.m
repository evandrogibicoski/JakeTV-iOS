
#import "AboutUsViewController.h"
#import "AppDelegate.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    actView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [actView setHidesWhenStopped:YES];
    UIBarButtonItem *actItem=[[UIBarButtonItem alloc] initWithCustomView:actView];
    self.navigationItem.rightBarButtonItem=actItem;
    
    NSString *urlAddress = @"http://jaketv.org/about-jake/";
    urlAddress = [urlAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *requestURL = [NSURL URLWithString:urlAddress];
    NSURLRequest *request  = [NSURLRequest requestWithURL:requestURL];
    [webView loadRequest:request];
    
    btnNext.enabled = FALSE;
    btnPrev.enabled = FALSE;
    webView.delegate = self;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font =  [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = @"ABOUT US";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    
    [self.navigationItem setTitleView:lblTitle];

}

-(void)viewDidDisappear:(BOOL)animated
{
    if (webView.isLoading) {
        [webView stopLoading];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [actView startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView1
{
    if([webView canGoBack])
        btnPrev.enabled=TRUE;
    else
        btnPrev.enabled=FALSE;
    if([webView canGoForward])
        btnNext.enabled=TRUE;
    else
        btnNext.enabled=FALSE;
    [actView stopAnimating];
}
-(IBAction)btnNext:(id)sender
{
    if ([webView canGoForward])
    {
        btnPrev.enabled = TRUE;
        [webView goForward];
    }
    else
    {
        btnNext.enabled = FALSE;
    }
}

-(IBAction)btnPrev:(id)sender
{
    if ([webView canGoBack])
    {
        btnNext.enabled = TRUE;
        [webView goBack];
    }
    else
    {
        btnPrev.enabled = FALSE;
    }
}

@end
