//
//  AppDelegate.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDelegate.h"
#import "app.net/AppDotNet.h"
#import "ADNUser.h"

@implementation AppDelegate

//------------------------------------------------------------------------------

- (void)dealloc
{
    [super dealloc];
}

//------------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //NSURL *url = [NSURL URLWithString:@"https://alpha.app.net/oauth/authenticate?client_id=adcmYXNbVKDSkcQZMhejFmqp6YSnarPp&response_type=token&redirect_uri=http://objc-appdotnet.akashkgarg.com&scope=stream%20email%20write_post%20follow%20messages%20export"];
    //[[NSWorkspace sharedWorkspace] openURL:url];
    
    NSString *token = @"AQAAAAAAAFhsSvxsSxprq-3kK4PY3c_JvSaF7nApwPHxhHaY7qGwxZIKJd6EFdRGdlZYO0s6mat3UIWQ6tY1qMOGjRecPEnnAQ";
    
    AppDotNet *engine = [[AppDotNet alloc] initWithDelegate:self accessToken:token];
    
    [engine checkCurrentToken];
}

//------------------------------------------------------------------------------

- (void) receivedUser:(ADNUser *)user forRequestUUID:(NSString *)uuid
{
    NSLog(@"Got User with username: %@", user.username);
}

//------------------------------------------------------------------------------

- (void) requestFailed:(NSError *)error forRequestUUID:(NSString *)uuid
{
    NSLog(@"Failed!");
}

//------------------------------------------------------------------------------

@end
