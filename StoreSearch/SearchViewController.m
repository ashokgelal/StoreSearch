#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "DetailViewController.h"
#import "LandscapeViewController.h"
#import "Search.h"

static NSString *const SearchResultCellIdentifier = @"SearchResultCell";
static NSString *const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString *const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end

@implementation SearchViewController{
    LandscapeViewController *landscapeViewController;
    Search *search;
    __weak DetailViewController *detailViewController;
}

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize segmentedControl = _segmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    self.tableView.rowHeight = 80;
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(search == nil){
        return 1;
    }else if (search.isLoading) {
        return 1;
    } else if ([search.searchResults count] == 0) {
        return 1;
    }
    else {
        return [search.searchResults count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(search.isLoading){
        return [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
    } else if([search.searchResults count] == 0){
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    }
    else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        
        SearchResult *searchResult = [search.searchResults objectAtIndex:indexPath.row];
        [cell configureForSearchResult:searchResult];
        
        return cell;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
}

-(void)performSearch
{
    
    search = [[Search alloc] init];
    NSLog(@"allocated%@", search);
    
    [search performSearchForText:self.searchBar.text category:self.segmentedControl.selectedSegmentIndex completion:^(BOOL success) {
        if(!success){
            [self showNetworkError];
        }
        [landscapeViewController searchResultsReceived];
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    
}

-(void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops.." message:@"There was an error reading from iTunes Store" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    
    SearchResult *searchResult = [search.searchResults objectAtIndex:indexPath.row];
    controller.searchResult = searchResult;
    
    [controller presentInParentViewController:self];
    detailViewController = controller;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([search.searchResults count] == 0 || search.isLoading){
        return nil;
    }else {
        return indexPath;
    }
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if(search.searchResults != nil){
        [self performSearch];
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self hideLandscapeViewWithDuration:duration];
    }
    else {
        [self showLandscapeViewWithDuration:duration];
    }
}
-(void) hideLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if(landscapeViewController != nil){
        [landscapeViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:^{
            landscapeViewController.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [landscapeViewController.view removeFromSuperview];
            [landscapeViewController removeFromParentViewController];
            landscapeViewController = nil;
        }];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

-(void)showLandscapeViewWithDuration:(NSTimeInterval)duration
{
    if(landscapeViewController == nil){
        landscapeViewController = [[LandscapeViewController alloc] initWithNibName:@"LandscapeViewController" bundle:nil];
        landscapeViewController.search = search;
        
        landscapeViewController.view.frame = self.view.bounds;
        landscapeViewController.view.alpha = 0.0f;
        
        [self.view addSubview:landscapeViewController.view];
        [self addChildViewController:landscapeViewController];
        
        [UIView animateWithDuration:duration animations:^{
            landscapeViewController.view.alpha = 1.0f;  
        } completion:^(BOOL finished) {
            [landscapeViewController didMoveToParentViewController:self];
        }]; 
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        
        [self.searchBar resignFirstResponder];
        [detailViewController dismissFromParentViewControllerWithAnimationType:DetailViewControllerAnimationTypeFade];
    }
}

@end
