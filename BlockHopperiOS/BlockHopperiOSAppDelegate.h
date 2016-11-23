//
//  BlockHopperiOSAppDelegate.h
//  BlockHopperiOS
//
//  Created by David Samuelsen on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlockHopperiOSViewController;

@interface BlockHopperiOSAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet BlockHopperiOSViewController *viewController;

@end
