#import "ViewController.h"
#import "LeftMenuViewController.h"
#import "SlideNavigationController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "SinglePost.h"
#import "UIImageView+AFNetworking.h"
#import <Google/Analytics.h>


@interface ViewController ()

@end

@implementation ViewController
@synthesize bFirst;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    strAdVideoUrl = @"";
    
    appData = [ApplicationData sharedInstance];
    self.navigationController.navigationBarHidden = NO;
    
    [self addNavigationButtons];

    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 35)];
    imgTitle.backgroundColor = [UIColor clearColor];
    imgTitle.image = [UIImage imageNamed:@"logo.png"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationItem setTitleView:imgTitle];

    currentPage = 0;
    
    [self.adView setHidden:YES];
    self.adHeightConstraint.constant = 0.0f;
    
    self.popupContentView.layer.cornerRadius = 10;
    self.popupSubdescribedView.layer.cornerRadius = 10;
    
    if (bFirst) {
        
        NSString *strEnableEmailChimp = [[NSUserDefaults standardUserDefaults] valueForKey:@"enableEmailChimp"];
        if (!strEnableEmailChimp) {
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showPopupDialog:) userInfo:nil repeats:NO];
        } else if ([strEnableEmailChimp isEqualToString:@"later"]) {
            NSString *strRegisteredDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"registeredDate"];
            if (strRegisteredDate) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
                NSDate *registeredDate = [df dateFromString:strRegisteredDate];
                
                NSInteger days = [self daysBetweenDate:registeredDate andDate:[NSDate date]];
                if (days > 30) {
                    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showPopupDialog:) userInfo:nil repeats:NO];
                }
            } else {
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showPopupDialog:) userInfo:nil repeats:NO];
            }
        }
        
    }
    
}

-(void) showPopupDialog:(NSTimer*)timer
{
    [self.popupView setHidden:NO];
    [self.popupContentView setHidden:NO];
    [self.popupSubdescribedView setHidden:YES];
    
    SlideNavigationController *slideNavVC = (SlideNavigationController*)self.navigationController;
    [slideNavVC setEnableSwipeGesture:NO];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)addNavigationButtons
{
    UIBarButtonItem *searchButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBtnClicked)];
    
    UIImage *messageImage = [UIImage imageNamed:@"message_icons.png"];
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithImage:messageImage style:UIBarButtonItemStyleDone target:self action:@selector(messageButtonClicked)];
    
    [self.navigationItem setRightBarButtonItems:@[messageButton, searchButton]];
}

- (void)refresh {
    // Do your job, when done:
    
    [arrPostList removeAllObjects];
    currentPage = 0;
    if (isSearchFirstTime == NO) {
        
        if (appData.postType == ALLPOST) {
            [self getAllPost];
        }else if (appData.postType == BOOKMARK){
            [self getBookmarkPost];
        }else if (appData.postType == LIKE){
            [self getLikePost];
        }else if (appData.postType == CATEGORY){
            [self getPostBySelectedCat];
        }
        
    }else{
        [self getAllSearchPost];
    }
    
    [tblPosts reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    tblPosts.refreshDelegate = self;
    tblPosts.enabledLoadMore = YES;
    tblPosts.enabledRefresh = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    imageLike.hidden = YES;
    imageBookMark.hidden = YES;
    viewAlert.hidden = YES;
    arrPostList = [[NSMutableArray alloc] init];
    arrTempPostList = [[NSMutableArray alloc] init];
    arrAdList = [[NSMutableArray alloc] init];
    
    currentPage = 0;
    isLoaingMore = NO;
    
    [self getSelectedCat];
    
    if (isSearchFirstTime == NO) {
        
        if (appData.postType == ALLPOST) {
            [self getAllPost];
        }else if (appData.postType == BOOKMARK){
            [self getBookmarkPost];
        }else if (appData.postType == LIKE){
            [self getLikePost];
        }else if (appData.postType == CATEGORY){
            [self getPostBySelectedCat];
        }
        
    }else{
        [self getAllSearchPost];
    }
    
    if (appData.postType == ALLPOST){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAd];
        });
    }
}

#pragma mark - get number of days between two dates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:fromDateTime
                                                          toDate:toDateTime
                                                         options:0];
    return [components day];
}

#pragma mark - Ad View
-(void)showAd
{
    self.adHeightConstraint.constant = 0.0f;
    [self.adView setHidden:YES];
    [self.view layoutIfNeeded];
    
    if ([appData connectedToNetwork]) {
        NSError *error;
        NSString *url_string = [NSString stringWithFormat: @"http://ads.jaketv.tv/ads"];
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"json: %@", json);
        
        if ([json count] > 0) {
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            NSMutableDictionary *dic = json[[json count]-1];
            NSString *imgURL = [dic valueForKey:@"portrait"];
            strAdVideoUrl = [dic valueForKey:@"video"];
        
            NSURL *imageURL = [NSURL URLWithString:[imgURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL];
            
            [self.adImageView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [self.adView setHidden:NO];
                self.adImageView.image = image;
                
                [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionLayoutSubviews animations:^{
                    self.adHeightConstraint.constant = 50 * screenSize.width / 320.0f;
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    double delayInSeconds = [[dic valueForKey:@"duration"] doubleValue];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        NSLog(@"Do some work");
                        [self hideAd];
                    });
                }];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
        }
    }
}

-(void)hideAd
{
    [UIView animateWithDuration:0.5f animations:^{
        [self.adView setAlpha:0];
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onAdView:(id)sender
{
    if (![strAdVideoUrl isEqualToString:@""]) {
        NSURL *urlAdVideo = [NSURL URLWithString:strAdVideoUrl];
        [[UIApplication sharedApplication] openURL:urlAdVideo];
    }
}

- (IBAction)onSignmeup:(id)sender {
    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    NSString *fname = [[NSUserDefaults standardUserDefaults] valueForKey:@"fname"];
    NSString *lname = [[NSUserDefaults standardUserDefaults] valueForKey:@"lname"];
    
    NSArray *keys=[NSArray arrayWithObjects:@"email",@"fname", @"lname", nil];
    NSArray *values=[NSArray arrayWithObjects:email, fname, lname, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *param=[NSString stringWithFormat:@"%@",json];
    
    param = [NSString stringWithFormat:@"email=%@&fname=%@&lname=%@", email, fname, lname];
    NSString *url = [NSString stringWithFormat:@"http://jaketv.tv/emails.php?%@", param];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] == 200){
        NSLog(@"%@", oResponseData);
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"enableEmailChimp"];
    }

    //[self.popupView setHidden:YES];
    [self.popupContentView setHidden:YES];
    [self.popupSubdescribedView setHidden:NO];
    
    SlideNavigationController *slideNavVC = (SlideNavigationController*)self.navigationController;
    [slideNavVC setEnableSwipeGesture:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)onNothanks:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"enableEmailChimp"];
    
    [self.popupView setHidden:YES];
    SlideNavigationController *slideNavVC = (SlideNavigationController*)self.navigationController;
    [slideNavVC setEnableSwipeGesture:YES];
    [self.navigationController setNavigationBarHidden:NO];
}


- (IBAction)onAskmelater:(id)sender {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSString *strDate = [df stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setValue:strDate forKey:@"registeredDate"];
    [[NSUserDefaults standardUserDefaults] setValue:@"later" forKey:@"enableEmailChimp"];
    
    [self.popupView setHidden:YES];
    SlideNavigationController *slideNavVC = (SlideNavigationController*)self.navigationController;
    [slideNavVC setEnableSwipeGesture:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)onDismiss:(id)sender {
    
    [self.popupSubdescribedView setHidden:YES];
    [self.popupView setHidden:YES];
}

#pragma mark - navigatioin button events
-(void)messageButtonClicked
{    
    if ([MFMailComposeViewController canSendMail] == NO) return;
        
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
        
    [mailComposer setSubject:@"Feedback: JakeTV iOS"];
    NSArray *toRecipents = [NSArray arrayWithObject:@"jaketvmanager@gmail.com"];
    [mailComposer setToRecipients:toRecipents];
    
    [self presentViewController:mailComposer animated:YES completion:nil];

}

-(void)searchBtnClicked{

    UIBarButtonItem *searchButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked)];
    [self.navigationItem setRightBarButtonItem:searchButton];
    
    if (self.view.frame.size.width>320) {
    
        searchBarPost = [[UISearchBar alloc] initWithFrame:CGRectMake(10.0, 0.0, 220.0, 44.0)];
        searchBarPost.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(00.0, 0.0, 240.0, 44.0)];
        searchBarPost.autoresizingMask = 0;
        searchBarPost.searchBarStyle = UISearchBarStyleMinimal;
        searchBarPost.delegate = self;
        [searchBarView addSubview:searchBarPost];
        self.navigationItem.titleView = searchBarView;
    }else{
    
        searchBarPost = [[UISearchBar alloc] initWithFrame:CGRectMake(10.0, 0.0, 180.0, 44.0)];
        searchBarPost.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(00.0, 0.0, 200.0, 44.0)];
        searchBarPost.autoresizingMask = 0;
        searchBarPost.searchBarStyle = UISearchBarStyleMinimal;
        searchBarPost.delegate = self;
        [searchBarView addSubview:searchBarPost];
        self.navigationItem.titleView = searchBarView;
    }
}

-(void)cancelBtnClicked{

    [self addNavigationButtons];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 35)];
    imgTitle.backgroundColor = [UIColor clearColor];
    imgTitle.image = [UIImage imageNamed:@"logo.png"];
    imgTitle.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationItem setTitleView:imgTitle];
    
    if (isSearchFirstTime == YES) {
     
        [arrPostList removeAllObjects];
       
        if (appData.postType == ALLPOST) {
            [self getAllPost];
        }else if (appData.postType == BOOKMARK){
            [self getBookmarkPost];
        }else if (appData.postType == LIKE){
            [self getLikePost];
        }else if (appData.postType == CATEGORY){
            [self getPostBySelectedCat];
        }
    }
    isSearchFirstTime = NO;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(void)LoadMore
{
    
    if (currentPage < appData.totalPages - 1)
    {
        currentPage += 1;
        NSLog(@"CurrentPage = %ld",(long)currentPage);
        
        isLoaingMore = YES;
        [self getAllPost];
    }
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    isSearchFirstTime = YES;
    [arrPostList removeAllObjects];
    currentPage = 0;
    [self getAllSearchPost];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrPostList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    SinglePost *aSinglePost = [arrPostList objectAtIndex:indexPath.row];
    
     UIImageView *imgPost1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, self.view.frame.size.width - 60, 150)];
    
    __weak UIImageView *imgPost = imgPost1;
    
    imgPost.backgroundColor = [UIColor clearColor];
    
    NSURL *imageURL = [NSURL URLWithString:[aSinglePost.image stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL];
    
    [imgPost setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imgPost.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];

    UILabel *lblKickerLine = [[UILabel alloc] initWithFrame:CGRectMake(imgPost.frame.origin.x, imgPost.frame.size.height + imgPost.frame.origin.y+5, imgPost.frame.size.width, 20)];
    lblKickerLine.text = aSinglePost.description;
    lblKickerLine.backgroundColor = [UIColor clearColor];
    lblKickerLine.text = [aSinglePost.kickerline uppercaseString];
    lblKickerLine.textColor = [UIColor darkGrayColor];
    lblKickerLine.font = [UIFont fontWithName:ROBOTO_REGULAR size:14.0];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(lblKickerLine.frame.origin.x, lblKickerLine.frame.size.height + lblKickerLine.frame.origin.y, lblKickerLine.frame.size.width, 25)];
    lblTitle.text = aSinglePost.description;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = aSinglePost.title;
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    
    UILabel *lblCategory = [[UILabel alloc] initWithFrame:CGRectMake(lblTitle.frame.origin.x, lblTitle.frame.size.height + lblTitle.frame.origin.y, lblTitle.frame.size.width-50, 20)];
    lblCategory.text = aSinglePost.source;
    lblCategory.backgroundColor = [UIColor clearColor];
    lblCategory.textColor = [UIColor blackColor];
    lblCategory.font = [UIFont fontWithName:ROBOTO_THIN size:12.0];
    
    UIImageView *imgLikes = [[UIImageView alloc] initWithFrame:CGRectMake(lblCategory.frame.origin.x + lblCategory.frame.size.width, lblCategory.frame.origin.y+5, 20, 20)];
    imgLikes.backgroundColor = [UIColor clearColor];
    imgLikes.image = [UIImage imageNamed:@"likes.png"];
    
    imgLikes.image = [imgLikes.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgLikes setTintColor:[UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0]];

    UILabel *lblLikes = [[UILabel alloc] initWithFrame:CGRectMake(imgLikes.frame.origin.x + imgLikes.frame.size.width ,lblCategory.frame.origin.y+5, 30, 20)];
    lblLikes.text = aSinglePost.totalpostlikes;
    lblLikes.backgroundColor = [UIColor clearColor];
    lblLikes.textAlignment= NSTextAlignmentCenter;
    lblLikes.textColor = [UIColor colorWithRed:63.0/255.0 green:211.0/255.0 blue:182.0/255.0 alpha:1.0];
    lblLikes.font = [UIFont fontWithName:@"Roboto" size:12.0];

    
    UIImageView *imgBookMark = [[UIImageView alloc] initWithFrame:CGRectMake(imgPost.frame.size.width-10, imgPost.frame.origin.y-3, 40, 40)];
    imgBookMark.image = [UIImage imageNamed:@"bookmark"];
    imgBookMark.backgroundColor = [UIColor clearColor];
    imgBookMark.layer.shadowOffset = CGSizeMake(0, 0.5);
    imgBookMark.layer.shadowOpacity = 0.5;

    [cell.contentView addSubview:imgPost];
    [cell.contentView addSubview:lblKickerLine];
    [cell.contentView addSubview:lblTitle];
    [cell.contentView addSubview:lblCategory];
    [cell.contentView addSubview:lblLikes];
    [cell.contentView addSubview:imgLikes];
    
    if ([aSinglePost.isbookmarked isEqual:@"1"]) {
        
        [cell.contentView addSubview:imgBookMark];
    }

    return cell;
    
}

#pragma mark - UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *aDetailView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailController"];
    aDetailView.aSinglePost = [arrPostList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:aDetailView animated:YES];
}

#pragma mark - UITableViewDynamic Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [tblPosts scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [tblPosts checkToReload];
}

-(void)refreshData:(UITableView *)tableView completion:(RefreshCompletion)completion{
    
    //TODO:do some task needs many time to finish. After finish it, call the completion block
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refresh];
        completion();
    });
}
-(void)loadMoreData:(UITableView *)tableView completion:(RefreshCompletion)completion{
    
    //TODO:do some task needs many time to finish. After finish it, call the completion block
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isLoaingMore == NO) {
            [self LoadMore];
        }
        completion();
    });
    
}

#pragma mark -

-(void)getAllSearchPost
{
    if ([appData connectedToNetwork]) {
     
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"Page",@"search", nil];
        NSString *strSearchKey = searchBarPost.text;
        NSArray *values=[NSArray arrayWithObjects:@"GetSearch",appData.aUser.UserID,[NSString stringWithFormat:@"%ld",(long)currentPage],strSearchKey, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jAllPostList;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)getAllPost
{
    if ([appData connectedToNetwork]) {
     
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"Page", nil];
        NSArray *values=[NSArray arrayWithObjects:@"GetPost",appData.aUser.UserID,[NSString stringWithFormat:@"%ld",(long)currentPage], nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jAllPostList;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)getBookmarkPost
{
    if ([appData connectedToNetwork]) {
     
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"Page", nil];
        NSArray *values=[NSArray arrayWithObjects:@"GetBookmarkByUserid",appData.aUser.UserID,[NSString stringWithFormat:@"%ld",(long)currentPage], nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jAllPostList;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)getLikePost
{
    if ([appData connectedToNetwork]) {
     
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"Page", nil];
        NSArray *values=[NSArray arrayWithObjects:@"GetPostLikeByUserid",appData.aUser.UserID,[NSString stringWithFormat:@"%ld",(long)currentPage], nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType=jAllPostList;
        manager.postString=request;
        [manager startDownload];
    }
}

-(void)getSelectedCat{

    if (appData.connectedToNetwork) {

        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid", nil];
        NSArray *values=[NSArray arrayWithObjects:@"GetSelectedCategory",appData.aUser.UserID, nil];
        NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json=[jsonDict JSONRepresentation];
        NSString *request=[NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@",request);
        
        [appData showLoader];
        HTTPManager *manager = [HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType = jGeneralQuery;
        manager.postString = request;
        [manager startDownload];

    }
}

-(void)getPostBySelectedCat{

    if ([appData connectedToNetwork]) {
     
        NSArray *keys = [NSArray arrayWithObjects:@"method",@"userid",@"Page",@"catid", nil];
        NSArray *values = [NSArray arrayWithObjects:@"GetPostByCategory",appData.aUser.UserID,[NSString stringWithFormat:@"%ld",(long)currentPage],appData.selectedCat, nil];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        NSString *json = [jsonDict JSONRepresentation];
        NSString *request = [NSString stringWithFormat:@"data=%@",json];
        NSLog(@"%@", request);
        
        [appData showLoader];
        HTTPManager *manager = [HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
        manager.requestType = jAllPostList;
        manager.postString = request;
        [manager startDownload];
    }
}

#pragma mark - HTTPManager delegate

-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response{
    
    NSLog(@"response : %@", response);
    [appData hideLoader];
    if (manger.requestType == jAllPostList)
    {
        [arrTempPostList removeAllObjects];
        [arrTempPostList addObjectsFromArray:response];
        
        [arrPostList addObjectsFromArray:arrTempPostList];
        
        if (appData.totalPages == currentPage+1) {
            [tblPosts setTableFooterView:nil];
        }
        
        [tblPosts reloadData];
    
    }
    else if (manger.requestType == jGeneralQuery)
    {
        appData.arrSelectedCat = [response valueForKey:@"data"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
    }
    else if (manger.requestType == jMailChimp)
    {
        NSLog(@"Mail Chimp Test");
    }
    
    
    if (appData.postType == BOOKMARK) {
        
        NSMutableArray *arr = response;
        if (arr.count==0) {
            viewAlert.hidden = NO;
            imageBookMark.hidden = NO;
        }
    }else if (appData.postType == LIKE){

        NSMutableArray *arr = response;
        if (arr.count==0) {
            viewAlert.hidden = NO;
            imageLike.hidden = NO;
        }
    }
    
    isLoaingMore = NO;
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if ((result == MFMailComposeResultFailed) && (error != NULL))
    {
        [self showAlertView:nil message:@"Failed sending mail"];
        NSLog(@"%@", error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - show standard alert with message
-(void)showAlertView:(NSString*)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
