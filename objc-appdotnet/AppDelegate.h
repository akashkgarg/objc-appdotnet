//
//  AppDelegate.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "app.net/AppDotNet.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ADNDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
