
#import "SignUpViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#define CellTextFieldTag 10000

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appData = [ApplicationData sharedInstance];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(btnJoinPressed)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelPressed)]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font =  [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = @"REGISTER";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    
    [self.navigationItem setTitleView:lblTitle];
    
    arrCaptions = [[NSMutableArray alloc] init];
    [arrCaptions addObject:@"First Name"];
    [arrCaptions addObject:@"Last Name"];
    [arrCaptions addObject:@"Email"];
    [arrCaptions addObject:@"Password"];
    [arrCaptions addObject:@"Confirm Password"];
    
    cellArray=[[NSMutableArray alloc] init];
    for(int i=0;i<[arrCaptions count];i++)
    {
        [cellArray addObject:[NSNull null]];
    }
}

-(void)btnJoinPressed
{    
    NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *txtFirstName = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    aIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *txtLastName = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    aIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *txtEmail = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    aIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *txtPassword = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    aIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *txtConfirmPassword = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    if ([txtFirstName.text length] == 0 || [txtLastName.text length] == 0 || [txtEmail.text length] == 0 || [txtPassword.text length] == 0 || [txtConfirmPassword.text length] == 0)
    {
        [appData ShowAlert:@"Registration Error" andMessage:@"All field are required to complete registration"];
        return;
    }
    
    NSString *trimmed = [txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!(trimmed.length > 0))
    {
        [appData ShowAlert:@"Password Error" andMessage:@"Please enter valid password"];
        return;
    }
    
    if (![txtPassword.text isEqualToString:txtConfirmPassword.text])
    {
        [appData ShowAlert:@"Password Error" andMessage:@"Password and Confirm Password must be same"];
        return;
    }
    
    if ([appData connectedToNetwork]) {
     
        m_password = txtPassword.text;
        NSArray *keys=[NSArray arrayWithObjects:@"method",@"userid", @"googleplusid",@"fname",@"lname",@"email",@"password",nil];
        NSArray *values=[NSArray arrayWithObjects:@"Registration",@"0",@"0",txtFirstName.text,txtLastName.text,txtEmail.text,txtPassword.text,nil];
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
}

#pragma mark - HttpManager delegate
-(void)HttpManger:(HTTPManager *)manger DownloadedWith:(id)response
{
    [appData hideLoader];
    NSMutableDictionary *dataDict = [response valueForKey:@"data"];
    if ([[response valueForKey:@"success"] intValue] == jSuccess)
    {
        if ([[response valueForKey:@"facebookid"] length] == 0)
        {
            [[NSUserDefaults standardUserDefaults] setValue:[dataDict valueForKey:@"email"] forKey:@"email"];
            [[NSUserDefaults standardUserDefaults] setValue:m_password forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"fbdetails"];
        }
        
        NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"email"]);
       
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"googleSignIn"];
        
        ViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
        [self.navigationController pushViewController:lvc animated:YES];
    }
}

-(void)btnCancelPressed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Are you sure to cancel registration process? All entered data will be lost by pressing Yes." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
        txtValue.tag = CellTextFieldTag;
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

-(BOOL)checkPassword{

    BOOL lowerCaseLetter = false,upperCaseLetter = false,digit = false,specialCharacter = 0;
    
    NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    UITableViewCell *cell = [tblSignUp cellForRowAtIndexPath:aIndexPath];
    UITextField *textfield = (UITextField *)[cell.contentView viewWithTag:CellTextFieldTag];
    
    if([textfield.text length] >= 6)
    {
        for (int i = 0; i < [textfield.text length]; i++)
        {
            unichar c = [textfield.text characterAtIndex:i];
            if(!lowerCaseLetter)
            {
                lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!upperCaseLetter)
            {
                upperCaseLetter = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!digit)
            {
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
            }
            if(!specialCharacter)
            {
                specialCharacter = [[NSCharacterSet symbolCharacterSet] characterIsMember:c];
            }
        }
        
        if(specialCharacter && digit && lowerCaseLetter && upperCaseLetter)
        {
            //do what u want
        }
        else
        {
            [appData ShowAlert:@"Error" andMessage:@"Please Ensure that you have at least one lower case letter, one upper case letter, one digit and one special character"];
            return NO;
        }
        
    }
    else
    {
        [appData ShowAlert:@"Error" andMessage:@"Please Enter at least 6 password"];        
        return NO;
    }
    
    return YES;
}

- (BOOL)passwordIsValid:(NSString *)password {
    
    // 1. Upper case.
    if (![[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[password characterAtIndex:0]])
        return NO;
    
    // 2. Length.
    if ([password length] < 6)
        return NO;
    
    // 3. Special characters.
    // Change the specialCharacters string to whatever matches your requirements.
    NSString *specialCharacters = @"@!#€%&/()[]=?$§*'";
    if ([[password componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:specialCharacters]] count] < 2)
        return NO;
    
    // 4. Numbers.
    if ([[password componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]] count] < 2)
        return NO;
    
    return YES;
}

#pragma mark - textfield delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3f animations:^{
        self.bottomConstraint.constant = 200;
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.3f animations:^{
        self.bottomConstraint.constant = 0.0f;
        [self.view layoutIfNeeded];
    }];
    
    [textField resignFirstResponder];
    return YES;
}

@end
