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
#import "ADNPost.h"

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
    
    //[engine checkCurrentToken];
    //[engine getUser:6581];
    
    //[engine followUser:6581];
    //[engine unfollowUser:6581];
    
    //[engine followedByMe];
    //[engine followedByUsername:@"@terhechte"];
    
    //[engine followersOfMe];
    //[engine followersOfUsername:@"@akg"];
    
    //[engine muteUserWithUsername:@"@terhechte"];
    //[engine unmuteUserWithUsername:@"@terhechte"];
    //[engine unmuteUserWithUsername:@"@spacekatgal"];
    
    //[engine mutedUsers];
    
    //[engine writePost:@"HELLLO WORLD!" replyToPostWithID:-1 annotations:nil links:nil];
    
    //[engine postWithID:50];
    //[engine deletePostWithID:50];
    
    //[engine repliesToPostWithID:121511];
    //[engine repliesToPostWithID:50];
    //[engine postsByMe];
    
    //[engine postsMentioningMe];
    
    //[engine myStreamSinceID:152000 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO];
    
    //[engine globalStreamSinceID:-1 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO];
    
    [engine taggedPostsWithTag:@"gamedev" sinceID:-1 beforeID:-1 count:20 includeUser:NO includeAnnotations:NO includeReplies:NO];
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
    
    NSDictionary *userInfo = [error userInfo];
    
    NSString *domain = [error domain];
    
    if ([domain compare:@"ADN"] == NSOrderedSame) {
        NSLog(@"Error: %@", [userInfo objectForKey:@"message"]);
    }
}

//------------------------------------------------------------------------------

- (void) receivedUsers:(NSArray *)users forRequestUUID:(NSString *)uuid
{
    for (ADNUser *user in users) {
        NSLog(@"got user: %@", user.username);
    }
}

//------------------------------------------------------------------------------

- (void) receivedPost:(ADNPost *)post forRequestUUID:(NSString *)uuid
{
    NSLog(@"Got Post: %@", post.text);
}

//------------------------------------------------------------------------------

- (void) receivedPosts:(NSArray *)posts forRequestUUID:(NSString *)uuid
{
    for (ADNPost *post in posts) {
        NSLog(@"got post: %ld - %@", post.postId, post.text);
    }
}

//------------------------------------------------------------------------------

@end
