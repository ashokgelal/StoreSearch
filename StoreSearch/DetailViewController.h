#import <UIKit/UIKit.h>
#import "SearchResult.h"

@interface DetailViewController : UIViewController
@property (strong, nonatomic) SearchResult *searchResult;


-(void)presentInParentViewController:(UIViewController *)parentViewController;
-(void)dismissFromParentViewController;

@end
