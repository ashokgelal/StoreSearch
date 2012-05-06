#import "LandscapeViewController.h"
#import "SearchResult.h"
#import "AFImageCache.h"
#import "Search.h"
#import "DetailViewController.h"

@interface LandscapeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

-(IBAction)pageChanged:(UIPageControl *)sender;

@end

@implementation LandscapeViewController {
    NSOperationQueue *imageRequestOperationQueue;
}

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize search= _search;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [imageRequestOperationQueue setMaxConcurrentOperationCount:8];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageControl.numberOfPages = 1;
    self.pageControl.currentPage = 0;
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    
    if(self.search != nil){
        if(self.search.isLoading){
            [self showSpinner];
        }else if([self.search.searchResults count] == 0){
            [self showNothingFoundLabel];
        } else {
            [self tileButtons];
        }
    }
}

-(void)showNothingFoundLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = NSLocalizedString(@"Nothing Found", @"Nothing found");
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    [label sizeToFit];
    CGRect rect = label.frame;
    rect.size.width = ceilf(rect.size.width/2.0f) * 2.0f;
    rect.size.height = ceilf(rect.size.height/2.0f) * 2.0f;
    
    label.frame = rect;
    label.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    [self.view addSubview:label];
}

-(void)searchResultsReceived
{
    [self hideSpinner];
    if([self.search.searchResults count] == 0){
        [self showNothingFoundLabel];
    }
    else {
        [self tileButtons];
    }
}

-(void)hideSpinner {
    [[self.view viewWithTag:1000] removeFromSuperview];
}

-(void)showSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CGRectGetMidX(self.scrollView.bounds) + 0.5f, CGRectGetMidY(self.scrollView.bounds) + 0.5f);
    spinner.tag = 1000;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

-(void)downloadImageForSearchResult:(SearchResult *)searchResult andPlaceOnButton:(UIButton *)button
{
    NSURL *url = [NSURL URLWithString:searchResult.artworkURL60];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [urlRequest setHTTPShouldHandleCookies:NO];
    [urlRequest setHTTPShouldUsePipelining:YES];
    
    UIImage *cachedImage = [[AFImageCache sharedImageCache] cachedImageForURL:[urlRequest URL] cacheName:nil];
    if(cachedImage !=nil){
        [button setImage:cachedImage forState:UIControlStateNormal];
    }else {
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [button setImage:responseObject forState:UIControlStateNormal];
            [[AFImageCache sharedImageCache] cacheImageData:operation.responseData forURL:[urlRequest URL] cacheName:nil];
        } failure:nil];
        
        [imageRequestOperationQueue addOperation:requestOperation];
    }
                
}

-(void)tileButtons
{
    const CGFloat itemWidth = 96.0f;
    const CGFloat itemHeight = 88.0f;
    const CGFloat buttonWidth = 82.0f;
    const CGFloat buttonHeight = 82.0f;
    const CGFloat marginHorz = (itemWidth - buttonWidth)/2.0f;
    const CGFloat marginVert = (itemHeight - buttonHeight)/2.0f;
    
    int index = 0;
    int row = 0;
    int column = 0;
    
    for (SearchResult *searchResult in self.search.searchResults) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        button.tag = 2000+index;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"LandscapeButton"] forState:UIControlStateNormal];
        [self.scrollView addSubview:button];
        [self downloadImageForSearchResult:searchResult andPlaceOnButton:button];
        index++;
        row++;
        if(row == 3){
            row = 0;
            column ++;
        }
    }
    
    int numPages = ceilf([self.search.searchResults count] / 15.0f);
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    
    NSLog(@"Number of pages:%d", numPages);
    
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}

-(void)buttonPressed:(UIButton *)sender
{
    DetailViewController *controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    SearchResult *searchResult = [self.search.searchResults objectAtIndex:sender.tag - 2000];
    controller.searchResult = searchResult;
    [controller presentInParentViewController:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
-(void)dealloc
{
    NSLog(@"dealloc %@", nil);
    [imageRequestOperationQueue cancelAllOperations];
}

-(void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (self.scrollView.contentOffset.x + width/2.0f)/ width;
    self.pageControl.currentPage = currentPage;
}

-(IBAction)pageChanged:(UIPageControl *)sender
{
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * sender.currentPage, 0);
    } completion:nil];
}

@end
