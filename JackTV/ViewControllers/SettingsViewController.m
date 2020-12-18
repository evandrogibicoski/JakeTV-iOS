
#import "SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "AboutUsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appData = [ApplicationData sharedInstance];
    [tblSettings setSeparatorColor:[UIColor darkGrayColor]];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 185)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgTitleBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    imgTitleBG.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.text = @"Settings";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor darkGrayColor];
    [self.navigationItem setTitleView:lblTitle];
    
    UIImageView *imgSeperator = [[UIImageView alloc] initWithFrame:CGRectMake(0, lblTitle.frame.origin.y+lblTitle.frame.size.height, self.view.frame.size.width, 1)];
    imgSeperator.backgroundColor = [UIColor darkGrayColor];

    
    float xOffset = 0.0f;
    float yOffset = 0.0f;
    float buttonSize = 0.0f;
    
    if (self.view.frame.size.width == 320)
    {
        xOffset = 8;
        yOffset = imgSeperator.frame.origin.y + 10;
        buttonSize = 70;
    }
    else if (self.view.frame.size.width == 375)
    {
        xOffset = 15;
        yOffset = imgSeperator.frame.origin.y + 15;
        buttonSize = 75;
    }

    UIButton *btnFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFacebook.frame = CGRectMake(xOffset, yOffset, buttonSize, buttonSize);
    [btnFacebook setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    btnFacebook.layer.cornerRadius = 10.0;
    btnFacebook.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    btnFacebook.layer.borderWidth = 4.0;
    btnFacebook.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;

    UIButton *btnTwitter = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTwitter.frame = CGRectMake(btnFacebook.frame.size.width + btnFacebook.frame.origin.x + xOffset, yOffset, buttonSize, buttonSize);
    [btnTwitter setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    btnTwitter.layer.cornerRadius = 10.0;
    btnTwitter.backgroundColor =[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    btnTwitter.layer.borderWidth = 4.0;
    btnTwitter.layer.borderColor = [UIColor colorWithRed:120.0/255.0 green:243.0/255.0 blue:36.0/255.0 alpha:1.0].CGColor;
    
    
    UIButton *btnGooglePlus = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGooglePlus.frame = CGRectMake(btnTwitter.frame.size.width + btnTwitter.frame.origin.x + xOffset, yOffset, buttonSize, buttonSize);
    [btnGooglePlus setImage:[UIImage imageNamed:@"google_plus.png"] forState:UIControlStateNormal];
    btnGooglePlus.layer.cornerRadius = 10.0;
    btnGooglePlus.backgroundColor =[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    btnGooglePlus.layer.borderWidth = 4.0;
    btnGooglePlus.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;

    UIButton *btnEmail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnEmail.frame = CGRectMake(btnGooglePlus.frame.size.width + btnGooglePlus.frame.origin.x + xOffset, yOffset, buttonSize, buttonSize);
    [btnEmail setImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
    btnEmail.layer.cornerRadius = 10.0;
    btnEmail.backgroundColor =[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    btnEmail.layer.borderWidth = 4.0;
    btnEmail.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;

    [headerView addSubview:imgTitleBG];
    [headerView addSubview:lblTitle];
    [headerView addSubview:imgSeperator];
    [headerView addSubview:btnFacebook];
    [headerView addSubview:btnTwitter];
    [headerView addSubview:btnGooglePlus];
    [headerView addSubview:btnEmail];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"googleSignIn"];
    
    if ([str isEqualToString:@"0"]) {
    
        arrTitles = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"Profile Settings",@"Change Password", nil], [NSArray arrayWithObjects:@"About",@"Share App", @"Review App", nil] , nil];
    }else{
   
        arrTitles = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"Profile Settings", @"Change Password", nil], [NSArray arrayWithObjects:@"About",@"Share App", @"Review App", nil] , nil];
    }
    
    arrSections = [[NSMutableArray alloc] initWithObjects:@"ACCOUNT",@"APP SETTINGS", nil];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOutClicked:)]];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

-(IBAction)signOutClicked:(id)sender{

    appData.lastSelectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"googleid"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"fname"];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lname"];
    [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"googleSignIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = [arrSections objectAtIndex:section];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:15.0];
    lblTitle.textColor = [UIColor darkGrayColor];
    
    [sectionHeaderView addSubview:lblTitle];
    return sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrSections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[arrTitles objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,10, 200, 25)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = [[arrTitles objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:15.0];
    lblTitle.textColor =  [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];

    [cell.contentView addSubview:lblTitle];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1 && indexPath.section == 0) {
        
        ChangePasswordViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
        [self.navigationController pushViewController:lvc animated:YES];
    }
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            AboutUsViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            [self.navigationController pushViewController:lvc animated:YES];
        }
        
        if (indexPath.row == 1) {
            // Share App
            NSString *textToShare = @"Jake TV \nHey I'm using Jake TV Download App: ";
            NSURL *myWebsite = [NSURL URLWithString:@"https://itunes.apple.com/ai/app/jake-tv/id1063239686?mt=8"];
            
            NSArray *objectsToShare = @[textToShare, myWebsite];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypePostToVimeo];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
        
        if (indexPath.row == 2) {
            // Review App
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1063239686&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
        }
    }
    
}
@end
