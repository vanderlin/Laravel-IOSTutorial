//
//  AppDelegate.m
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /*
    // Test the Request
    [self makeRequest:@"notes" params:nil method:@"GET" onComplete:^(NSDictionary *data) {
        NSLog(@"Json Loaded: %@", data);
    }];
    */
    
    // Override point for customization after application launch.
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

// -------------------------------------------------------------------
#pragma mark        --- Singleton Instance ---
// -------------------------------------------------------------------
+(AppDelegate*)getInstance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

// -------------------------------------------------------------------
#pragma mark        --- Request Notes Data ---
// -------------------------------------------------------------------
-(void)makeRequest:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params onComplete:(RequestBlock)callback {

    // create the url
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BASE_URL, urlString]];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // set the method (GET/POST/PUT/UPDATE/DELETE)
    [request setHTTPMethod:method];
    
    // if we have params pull out the key/value and add to header
    if(params != nil) {
        NSMutableString * body = [[NSMutableString alloc] init];
        for (NSString * key in params.allKeys) {
            NSString * value = [params objectForKey:key];
            [body appendFormat:@"%@=%@&", key, value];
        }
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // submit the request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                               // do we have data?
                               if(data && data.length > 0) {
                                   
                                   NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                  
                                   // if we have a block lets pass it
                                   if(callback) {
                                       callback(json);
                                   }
                                   
                               }
                               
                           }];
    
}


@end



