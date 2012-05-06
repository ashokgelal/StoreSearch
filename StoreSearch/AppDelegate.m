#import "AppDelegate.h"

#import "SearchViewController.h"
#import "DetailViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize splitViewController = _splitViewController;

-(void)customizeAppearance
{
    UIImage *barImage = [UIImage imageNamed:@"BarTexture"];
    [[UISearchBar appearance] setBackgroundImage:barImage];
    [[UINavigationBar appearance] setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    
    UIColor *tintColor = [UIColor colorWithRed:40/255.0f green:50/255.0f blue:50/255.0f alpha:1.0f];
    [[UISegmentedControl appearance] setTintColor:tintColor];
    
    [[UIBarButtonItem appearance] setTintColor:tintColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,
                                                          [UIColor colorWithWhite:0.0f alpha:0.5f], UITextAttributeTextShadowColor, nil]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeAppearance];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        self.splitViewController = [[UISplitViewController alloc] init];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        
        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.viewController, detailNavigationController, nil];
        self.window.rootViewController = self.splitViewController;
        self.viewController.detailViewController = detailViewController;
    }
    else{
        self.window.rootViewController = self.viewController;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
