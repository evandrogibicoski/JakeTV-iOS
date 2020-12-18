
#import "DetailViewController.h"
#import <Google/Analytics.h>

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize aSinglePost;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    appData = [ApplicationData sharedInstance];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackPressed)]];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBtnClicked)]];
 
    [aWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aSinglePost.url]]];
    
    if ([aSinglePost.isbookmarked isEqualToString:@"1"]) {
        isBookMark = YES;
        btnBookmark.image = [btnBookmark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBookmark setTintColor:[UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0]];
    }else{
        isBookMark = NO;
        btnBookmark.image = [btnBookmark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBookmark setTintColor:[UIColor lightGrayColor]];

    }
    
    if ([aSinglePost.isliked isEqualToString:@"1"]) {
        isLike = YES;
        btnLike.image = [btnLike.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnLike setTintColor:[UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0]];

    }else{
        isLike = NO;
        btnLike.image = [btnLike.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnLike setTintColor:[UIColor lightGrayColor]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    // screen and event track.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Detail Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Viewed" action:@"Post View" label:aSinglePost.postid value:nil] build]];
}

- (void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareBtnClicked{

    NSString *string = aSinglePost.title;
    NSURL *URL = [NSURL URLWithString:aSinglePost.url];
    UIImage *img = [UIImage imageNamed:@"jake_tv_default.png"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL, img]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         NSLog(@"Success");
                                     }];
}

-(IBAction)bookMarkBtnPressed{

    if (isBookMark) {
        [self unbookmarkPressed];
    }else{
        [self bookmarkPressed];
    }
}

-(IBAction)likeBtnPressed{

    if (isLike) {
        [self unlikePressed];
    }else{
        [self likePressed];
    }
}

-(void)bookmarkPressed
{
    if ([appData connectedToNetwork]) {
     
        isBookMark = YES;
        btnBookmark.image = [btnBookmark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBookmark setTintColor:[UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0]];
        
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"postid", nil];
        NSArray *values=[NSArray arrayWithObjects:@"BookmarkPost",appData.aUser.UserID,aSinglePost.postid, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jGeneralQuery;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)unbookmarkPressed
{
    if ([appData connectedToNetwork]) {
     
        isBookMark = NO;
        btnBookmark.image = [btnBookmark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnBookmark setTintColor:[UIColor lightGrayColor]];
        
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"postid", nil];
        NSArray *values=[NSArray arrayWithObjects:@"UnBookmarkPost",appData.aUser.UserID,aSinglePost.postid, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jGeneralQuery;
        manager.postString=request;
        [manager startDownload];
    }
}


-(void)likePressed{
    
    if ([appData connectedToNetwork]) {
     
        isLike = YES;
        btnLike.image = [btnLike.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnLike setTintColor:[UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0]];
        
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"postid", nil];
        NSArray *values=[NSArray arrayWithObjects:@"LikePost",appData.aUser.UserID,aSinglePost.postid, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jGeneralQuery;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)unlikePressed{
    
    if ([appData connectedToNetwork]) {
     
        isLike = NO;
        btnLike.image = [btnLike.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnLike setTintColor:[UIColor lightGrayColor]];
        
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"postid", nil];
        NSArray *values=[NSArray arrayWithObjects:@"UnLikePost",appData.aUser.UserID,aSinglePost.postid, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jGeneralQuery;
        manager.postString=request;
        [manager startDownload];
    }
}

#pragma mark - HTTPManagerDelegate
-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response{
    
    NSLog(@"%@", response);
    [appData hideLoader];
    if (manger.requestType == jGeneralQuery)
    {
        if ([[response valueForKey:@"success"] intValue] == jSuccess)
        {
//            [appData ShowAlert:nil andMessage:[response valueForKey:@"msg"]];
        }
    }
}



@end
