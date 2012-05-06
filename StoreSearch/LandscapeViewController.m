#import "LandscapeViewController.h"
#import "SearchResult.h"

@interface LandscapeViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

-(IBAction)pageChanged:(UIPageControl *)sender;

@end

@implementation LandscapeViewController
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize searchResults = _searchResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LandscapeBackground"]];
    //self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
    [self tileButtons];
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
    
    for (SearchResult *searchResult in self.searchResults) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        [button setTitle:[NSString stringWithFormat:@"%d", index] forState:UIControlStateNormal];
        [self.scrollView addSubview:button];
        index++;
        row++;
        if(row == 3){
            row = 0;
            column ++;
        }
    }
    
    int numPages = ceilf([self.searchResults count] / 15.0f);
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    
    NSLog(@"Number of pages:%d", numPages);
    
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
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
