#import <UIKit/UIKit.h>

@class SearchViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SearchViewController *viewController;
@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
