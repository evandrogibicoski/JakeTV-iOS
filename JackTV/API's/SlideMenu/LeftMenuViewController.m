
#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "AppDelegate.h"
#import "CategoryViewController.h"

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    appData = [ApplicationData sharedInstance];
	self.tblMenu.separatorColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    self.tblMenu.backgroundView = nil;
    self.tblMenu.backgroundColor = [UIColor clearColor];
    CGRect frameTbl = self.tblMenu.frame;
    frameTbl.size.height = frameTbl.size.height - 50;
    self.tblMenu.frame = frameTbl;
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    aView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *tempImgArr = [[NSMutableArray alloc]init];
    NSMutableArray *tempCatArr = [[NSMutableArray alloc]init];
    
    for (int i=0; i<appData.arrSelectedCat.count; i++) {
        
        [tempImgArr addObject:@"tempcat.png"];
        [tempCatArr addObject:[[appData.arrSelectedCat objectAtIndex:i] valueForKey:@"category"]];
    }
    
    arrImages = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"home.png",@"liked.png",@"bookmarked.png", @"Settings.png", @"talktous.png",nil],tempImgArr,nil];
    
    arrTitles = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"Home",@"Likes",@"Bookmarks",@"Settings", @"Talk to us", nil], tempCatArr,nil];
    
    arrSections = [[NSMutableArray alloc] initWithObjects:@"JAKE TV",@"Search by Categories", nil];
    [self.tblMenu setTableHeaderView:aView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, self.view.frame.size.height-50, self.view.frame.size.width-120, 40);
    [btn.titleLabel setTextColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    [btn setTitle:@"Choose Your Categories" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:ROBOTO_REGULAR size:17.0]];
    [btn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    btn.layer.borderColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    btn.layer.borderWidth = 1.0;
    [self.view addSubview:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:@"refresh" object:nil];
    
    appData.lastSelectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tblMenu selectRowAtIndexPath:appData.lastSelectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(void)refreshView{

    NSMutableArray *tempImgArr = [[NSMutableArray alloc]init];
    NSMutableArray *tempCatArr = [[NSMutableArray alloc]init];

    
    for (int i=0; i<appData.arrSelectedCat.count; i++) {
        
        [tempImgArr addObject:@"tempcat.png"];
        [tempCatArr addObject:[[appData.arrSelectedCat objectAtIndex:i] valueForKey:@"category"]];
    }
    
    arrImages = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"home.png",@"liked.png",@"bookmarked.png", @"Settings.png", @"talktous.png", nil],tempImgArr,nil];
    
    arrTitles = [[NSMutableArray alloc] initWithObjects:[NSArray arrayWithObjects:@"Home",@"Likes",@"Bookmarks",@"Settings", @"Talk to us", nil], tempCatArr,nil];
    
    [self.tblMenu reloadData];
    [self.tblMenu selectRowAtIndexPath:appData.lastSelectedIndex animated:NO scrollPosition:UITableViewScrollPositionNone];

}

#pragma mark - UITableView Delegate & Datasrouce -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

	return [[arrTitles objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = [arrSections objectAtIndex:section];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:18.0];
    lblTitle.textColor = [UIColor lightGrayColor];
    
    [sectionHeaderView addSubview:lblTitle];
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    imgTitle.backgroundColor = [UIColor clearColor];
    imgTitle.image= [UIImage imageNamed:[[arrImages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50,10, 200, 25)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.text = [[arrTitles objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    lblTitle.font = [UIFont fontWithName:ROBOTO_REGULAR size:15.0];
    lblTitle.textColor =  [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
    
    [cell.contentView addSubview:imgTitle];
    [cell.contentView addSubview:lblTitle];
    
    cell.backgroundColor= [UIColor clearColor];
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appData.lastSelectedIndex = indexPath;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UIViewController *vc ;
    
    if (indexPath.section == 0) {
    
        switch (indexPath.row)
        {
            case 0:
                appData.postType = ALLPOST;
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeController"];
                break;
            case 1:
                appData.postType = LIKE;
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeController"];
                break;
            case 2:
                appData.postType = BOOKMARK;
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeController"];
                break;
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"settingController"];
                break;
            case 4:
                [[SlideNavigationController sharedInstance] sendMail:@"jaketvmanager@gmail.com"];
                return;
            default:
                break;
        }
    }
    else if (indexPath.section ==1){
    
        
        appData.postType = CATEGORY;
        appData.selectedCat = [[appData.arrSelectedCat objectAtIndex:indexPath.row] valueForKey:@"catid"];
        vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeController"];
    }
    
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

-(void)addBtnClicked{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CategoryViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [[SlideNavigationController sharedInstance] presentViewController:navigationController animated:YES completion:nil];
    
}

@end
