#import <UIKit/UIKit.h>
@class DetailViewController;

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, weak) DetailViewController *detailViewController;

@end
