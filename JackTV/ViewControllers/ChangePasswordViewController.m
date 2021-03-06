
#import "ChangePasswordViewController.h"
#import "AppDelegate.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController
@synthesize openUrlID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appData = [ApplicationData sharedInstance];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(btnSumitPressed)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPressed)]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font =  [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = @"Forget Password";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    
    [self.navigationItem setTitleView:lblTitle];
    
    arrCaptions = [[NSMutableArray alloc] init];
    
    if (openUrlID) {
     
        openUrlID = [openUrlID stringByReplacingOccurrencesOfString:@"jaketvpassword://" withString:@""];
        [arrCaptions addObject:@"New Password"];
        [arrCaptions addObject:@"Confirm Password"];
    }
    else{
    
        [arrCaptions addObject:@"Old Password"];
        [arrCaptions addObject:@"New Password"];
        [arrCaptions addObject:@"Confirm Password"];
    }
    
    cellArray=[[NSMutableArray alloc] init];
    for(int i=0;i<[arrCaptions count];i++)
    {
        [cellArray addObject:[NSNull null]];
    }
    
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tblForgetPwd.frame.size.width, 20)];
    aView.backgroundColor = [UIColor clearColor];
    tblForgetPwd.tableHeaderView = aView;
}

-(void)btnSumitPressed
{
    if (openUrlID.length>0) {
        
        NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [tblForgetPwd cellForRowAtIndexPath:aIndexPath];
        UITextField *txtOldPassword = (UITextField *)[cell.contentView viewWithTag:10000];
        
        aIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        cell = [tblForgetPwd cellForRowAtIndexPath:aIndexPath];
        UITextField *txtNewPassword = (UITextField *)[cell.contentView viewWithTag:10000];
        
        
        if ([txtOldPassword.text length] == 0 || [txtNewPassword.text length] == 0)
        {
            [appData ShowAlert:@"Forgot Password Error" andMessage:@"All field are required to change password"];
            return;
        }
        
        if (![txtOldPassword.text isEqualToString:txtNewPassword.text])
        {
            [appData ShowAlert:@"Password Error" andMessage:@"Password and Confirm Password must be same"];
            return;
        }
        
        if ([appData connectedToNetwork]) {
            
            NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"password",nil];
            NSArray *values=[NSArray arrayWithObjects:@"ChangePassword",openUrlID,txtNewPassword.text,nil];
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

    }else{
    
        NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [tblForgetPwd cellForRowAtIndexPath:aIndexPath];
        UITextField *txtOldPassword = (UITextField *)[cell.contentView viewWithTag:10000];
        
        aIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        cell = [tblForgetPwd cellForRowAtIndexPath:aIndexPath];
        UITextField *txtNewPassword = (UITextField *)[cell.contentView viewWithTag:10000];
        
        aIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        cell = [tblForgetPwd cellForRowAtIndexPath:aIndexPath];
        UITextField *txtConfirmPassword = (UITextField *)[cell.contentView viewWithTag:10000];
        
        
        if ([txtOldPassword.text length] == 0 || [txtNewPassword.text length] == 0 || [txtConfirmPassword.text length] == 0)
        {
            [appData ShowAlert:@"Forget Password Error" andMessage:@"All field are required to change password"];
            return;
        }
        
        NSString *strPwd = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
        if (![strPwd isEqualToString:txtOldPassword.text]) {
            [appData ShowAlert:@"Password Error" andMessage:@"Old Password is incorrect"];
            return;
        }
        
        if (![txtNewPassword.text isEqualToString:txtConfirmPassword.text])
        {
            [appData ShowAlert:@"Password Error" andMessage:@"Password and Confirm Password must be same"];
            return;
        }
        
        if ([appData connectedToNetwork]) {
            
            NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid",@"password",nil];
            NSArray *values=[NSArray arrayWithObjects:@"ChangePassword",appData.aUser.UserID,txtNewPassword.text,nil];
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
    
}

-(void)btnCancelPressed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Forgot Password" message:@"Are you sure to cancel forget password process? All entered data will be lost by pressing Yes." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        openUrlID = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - HttpManager delegate

-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response
{
    [appData hideLoader];
    
    if ([[response valueForKey:@"success"] intValue] == jSuccess)
    {
        openUrlID = nil;
        [appData ShowAlert:@"Sucess" andMessage:[response valueForKey:@"msg"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableView Datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCaptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[cellArray objectAtIndex:indexPath.row];
    
    if(![[cellArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
    {
        cell=[cellArray objectAtIndex:indexPath.row];
    }
    
    if([[cellArray objectAtIndex:indexPath.row] isEqual:[NSNull null]])
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"anyCell"];
        
        UITextField *txtValue = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
        txtValue.borderStyle = UITextBorderStyleNone;
        txtValue.layer.cornerRadius = 0.0;
        txtValue.layer.borderColor = [UIColor lightGrayColor].CGColor;
        txtValue.layer.borderWidth = 1.0;
        txtValue.textColor = [UIColor grayColor];
        txtValue.tag = 10000;
        txtValue.secureTextEntry = YES;
        txtValue.delegate  = self;
        txtValue.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        txtValue.backgroundColor = [UIColor whiteColor];
        txtValue.font = [UIFont fontWithName:@"Avenir Book" size:16];
        
        if (indexPath.row == 3 || indexPath.row == 4)
        {
            txtValue.secureTextEntry = YES;
        }
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        aView.backgroundColor = [UIColor clearColor];
        
        [txtValue setLeftView:aView];
        [txtValue setLeftViewMode:UITextFieldViewModeAlways];
        
        if ([txtValue respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor lightGrayColor];
            txtValue.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[arrCaptions objectAtIndex:indexPath.row] attributes:@{NSForegroundColorAttributeName: color}];
        }
        [cell.contentView addSubview:txtValue];
        [cellArray  replaceObjectAtIndex:indexPath.row withObject:cell];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - textfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
