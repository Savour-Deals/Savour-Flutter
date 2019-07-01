#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  [GMSServices provideAPIKey: @"AIzaSyAhtyxgDSU4aJnUjk5zyLvt7s1qSvY8UDQ"];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
