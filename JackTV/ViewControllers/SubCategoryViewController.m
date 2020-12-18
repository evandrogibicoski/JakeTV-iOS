
#import "SubCategoryViewController.h"
#import "AppDelegate.h"

@interface SubCategoryViewController ()

@end

@implementation SubCategoryViewController
@synthesize arrSubCatList;
@synthesize strTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    appData = [ApplicationData sharedInstance];
    selectedRowsArray = [[NSMutableArray alloc]init];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDonePressed)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackPressed)]];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = strTitle;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    [self.navigationItem setTitleView:lblTitle];
    
    for (int i=0; i<arrSubCatList.count; i++) {
        
        NSString *strValue = [[arrSubCatList objectAtIndex:i] valueForKey:@"isselected"];
        if ([strValue isEqualToString:@"1"]) {
            [selectedRowsArray addObject:[arrSubCatList objectAtIndex:i]];
        }
    }
}

-(void)btnBackPressed{
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)btnDonePressed{
    [self getSelectedCat];
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

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrSubCatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(tblViewSubCat.frame.size.width - 40, 7, 25, 25)];
        imageView.tag = 101;
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:101];
    if ([selectedRowsArray containsObject:[arrSubCatList objectAtIndex:indexPath.row]]) {
        imageView.image = [UIImage imageNamed:@"checked.png"];
    }
    else {
        imageView.image = [UIImage imageNamed:@"unchecked.png"];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
    [imageView addGestureRecognizer:tap];
    imageView.userInteractionEnabled = YES;
    
    cell.textLabel.text = [[arrSubCatList objectAtIndex:indexPath.row] valueForKey:@"subcategory"];
    cell.textLabel.font = [UIFont fontWithName:@"ROBOTO_REGULAR" size:16];
    
    return cell;
}

- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint tapLocation = [tapRecognizer locationInView:tblViewSubCat];
    NSIndexPath *tappedIndexPath = [tblViewSubCat indexPathForRowAtPoint:tapLocation];
    
    if ([selectedRowsArray containsObject:[arrSubCatList objectAtIndex:tappedIndexPath.row]]) {
        [selectedRowsArray removeObject:[arrSubCatList objectAtIndex:tappedIndexPath.row]];
        [self unselectedCategory:[[arrSubCatList objectAtIndex:tappedIndexPath.row] valueForKey:@"subcatuniqueid"]];
    }
    else {
        [selectedRowsArray addObject:[arrSubCatList objectAtIndex:tappedIndexPath.row]];
        [self selectedCategory:[[arrSubCatList objectAtIndex:tappedIndexPath.row] valueForKey:@"subcatuniqueid"]];
    }
    [tblViewSubCat reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)selectedCategory:(NSString*)catID{

    NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"catid", nil];
    NSArray *values=[NSArray arrayWithObjects:@"SelectCategoryByUser",appData.aUser.UserID,catID, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    [appData showLoader];
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jSelectCategory;
    manager.postString=request;
    [manager startDownload];

}

-(void)unselectedCategory:(NSString*)catID{
    
    NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"catid", nil];
    NSArray *values=[NSArray arrayWithObjects:@"UnSelectCategoryByUser",appData.aUser.UserID,catID, nil];
    NSDictionary *jsonDict=[NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *json=[jsonDict JSONRepresentation];
    NSString *request=[NSString stringWithFormat:@"data=%@",json];
    NSLog(@"%@",request);
    
    [appData showLoader];
    HTTPManager *manager=[HTTPManager managerWithURL:SERVER_ADDRESS delegate:self];
    manager.requestType=jSelectCategory;
    manager.postString=request;
    [manager startDownload];

}

#pragma mark - HttpManager delegate
-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response{
    
    NSLog(@"%@", response);
    [appData hideLoader];
    
    if (manger.requestType == jSelectCategory){
        
        if ([[response valueForKey:@"success"] intValue] == jSuccess)
        {
            NSLog(@"%@", response);
        }
    }
    else if (manger.requestType == jGeneralQuery)
    {
        NSString *strMsg = [response valueForKey:@"msg"];
        if ([strMsg isEqualToString:@"Selected Category Found"])
        {
            appData.arrSelectedCat = [response valueForKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:self];
            
            [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([strMsg isEqualToString:@"No Selected Category Found"])
        {
            [appData.arrSelectedCat removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:self];
            
            [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


@end
