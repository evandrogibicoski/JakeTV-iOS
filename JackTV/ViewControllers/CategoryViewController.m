
#import "CategoryViewController.h"
#import "SubCategoryViewController.h"
#import "AppDelegate.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appData = [ApplicationData sharedInstance];
    self.navigationController.navigationBarHidden = NO;

    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDonePressed)]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = @"Category";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    
    [self.navigationItem setTitleView:lblTitle];
    
    selectedRowsArray = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self getAllCategory];
}

-(IBAction)btnClicked{

    SubCategoryViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SubCategoryViewController"];
    [self.navigationController pushViewController:lvc animated:YES];
}

-(void)btnDonePressed
{
    [self getSelectedCat];
}

-(void)btnCancelPressed{

    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
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

-(void)getAllCategory
{
    if ([appData connectedToNetwork]) {
     
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"Page", nil];
        NSArray *values=[NSArray arrayWithObjects:@"GetCategory",appData.aUser.UserID,@"0", nil];
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

-(void)selectedCategory:(NSString*)catID{
    
    if ([appData connectedToNetwork]) {
        
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
}

-(void)unselectedCategory:(NSString*)catID{
    
    if ([appData connectedToNetwork]) {
        
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
}


#pragma mark - HttpManager delegate
-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response{
    
    NSLog(@"%@", response);
    [appData hideLoader];
    if (manger.requestType == jGeneralQuery)
    {
        NSString *strMsg = [response valueForKey:@"msg"];
        if ([strMsg isEqualToString:@"Category found."]) {
            arrCatList = [response valueForKey:@"data"];
            
            for (int i=0; i<arrCatList.count; i++) {
                
                NSString *strValue = [[arrCatList objectAtIndex:i] valueForKey:@"isselected"];
                if ([strValue isEqualToString:@"1"]) {
                    [selectedRowsArray addObject:[arrCatList objectAtIndex:i]];
                }
            }
            [tblViewCat reloadData];
        }
        else if ([strMsg isEqualToString:@"Selected Category Found"])
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
        
    }else if (manger.requestType == jSelectCategory){
        
        if ([[response valueForKey:@"success"] intValue] == jSuccess)
        {
            
        }
    }
    

}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(tblViewCat.frame.size.width - 40, 7, 25, 25)];
        imageView.tag = 101;
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:101];
    if ([selectedRowsArray containsObject:[arrCatList objectAtIndex:indexPath.row]]) {
        imageView.image = [UIImage imageNamed:@"checked.png"];
    }
    else {
        imageView.image = [UIImage imageNamed:@"unchecked.png"];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
    [imageView addGestureRecognizer:tap];
    imageView.userInteractionEnabled = YES;
    
    cell.textLabel.text = [[arrCatList objectAtIndex:indexPath.row] valueForKey:@"category"];
    cell.textLabel.font = [UIFont fontWithName:@"ROBOTO_REGULAR" size:16];
    
    if ([[[arrCatList objectAtIndex:indexPath.row] valueForKey:@"subcatdata"] count]>0) {
        imageView.hidden = YES;

        UIView* accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIImageView* accessoryViewImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"]];
        accessoryViewImage.frame = CGRectMake(0, 0, 20, 20);
        accessoryViewImage.center = CGPointMake(7, 12);
        [accessoryView addSubview:accessoryViewImage];
        [cell setAccessoryView:accessoryView];
    
    }else{
        imageView.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    return cell;
}

- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint tapLocation = [tapRecognizer locationInView:tblViewCat];
    NSIndexPath *tappedIndexPath = [tblViewCat indexPathForRowAtPoint:tapLocation];
    
    if ([selectedRowsArray containsObject:[arrCatList objectAtIndex:tappedIndexPath.row]]) {
        [selectedRowsArray removeObject:[arrCatList objectAtIndex:tappedIndexPath.row]];
        [self unselectedCategory:[[arrCatList objectAtIndex:tappedIndexPath.row] valueForKey:@"catuniqueid"]];
    }
    else {
        [selectedRowsArray addObject:[arrCatList objectAtIndex:tappedIndexPath.row]];
        [self selectedCategory:[[arrCatList objectAtIndex:tappedIndexPath.row] valueForKey:@"catuniqueid"]];
    }
    [tblViewCat reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!([[[arrCatList objectAtIndex:indexPath.row] valueForKey:@"subcatdata"] count]>0)) {
        return;
    }
    SubCategoryViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"SubCategoryViewController"];
    lvc.arrSubCatList = [[arrCatList objectAtIndex:indexPath.row] valueForKey:@"subcatdata"];
    lvc.strTitle = [[arrCatList objectAtIndex:indexPath.row] valueForKey:@"category"];
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
