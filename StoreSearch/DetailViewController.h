#import <UIKit/UIKit.h>
#import "SearchResult.h"

typedef enum 
{
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
}DetailViewControllerAnimationType;

@interface DetailViewController : UIViewController
@property (strong, nonatomic) SearchResult *searchResult;


-(void)presentInParentViewController:(UIViewController *)parentViewController;
-(void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;

@end
