//
//  AppDelegate.h
//  NoteApp
//
//  Created by Todd Vanderlin on 6/4/14.
//  Copyright (c) 2014 IDEO. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BASE_URL @"http://laravelios:8888"

typedef void(^RequestBlock)(NSDictionary*data);

// -------------------------------------------------------------------
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(AppDelegate*)getInstance;
-(void)makeRequest:(NSString*)urlString method:(NSString*)method params:(NSDictionary*)params onComplete:(RequestBlock)callback;
@end
