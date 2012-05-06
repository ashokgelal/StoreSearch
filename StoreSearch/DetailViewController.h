#import <UIKit/UIKit.h>
#import "SearchResult.h"
#import <MessageUI/MessageUI.h>

typedef enum 
{
    DetailViewControllerAnimationTypeSlide,
    DetailViewControllerAnimationTypeFade
}DetailViewControllerAnimationType;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) SearchResult *searchResult;


-(void)presentInParentViewController:(UIViewController *)parentViewController;
-(void)dismissFromParentViewControllerWithAnimationType:(DetailViewControllerAnimationType)animationType;
-(void)sendSupportEmail;

@end
