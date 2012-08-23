//
//  AppDelegate.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDotNet.h"
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
    // Do some OAuth2 authentication to get a access token for testing. I do
    // this, by first hard-coding my client_id and calling the URL below. This
    // will open the link in a browser and once I sign-in and authorize, will
    // redirect me to the specified redirect_url. That url will contain in it's
    // GET parameter the access_token, which I copy and paste here. 

    //NSString *client_id = @"";
    //NSString *redirect_uri = @"";
    //NSString *scopes = @"stream%20email%20write_post%20follow%20messages%20export";

    //NSString *uri = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri%@&scope=%@", client_id, redirect_uri, scopes];

    //NSURL *url = [NSURL URLWithString:uri];
    //[[NSWorkspace sharedWorkspace] openURL:url];
    
    NSString *token = @"AQAAAAAAAFhsSvxsSxprq-3kK4PY3c_JvSaF7nApwPHxhHaY7qGwxZIKJd6EFdRGdlZYO0s6mat3UIWQ6tY1qMOGjRecPEnnAQ";
    
    AppDotNet *engine = [[AppDotNet alloc] initWithDelegate:self accessToken:token];
    
    //[engine checkCurrentToken];
    //[engine getUserWithID:6581];
    
    //[engine followUserWithID:6581];
    //[engine unfollowUserWithID:6581];
    
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
    NSUInteger code = [error code];
    
    if ([domain compare:@"ADN"] == NSOrderedSame) {
        NSLog(@"ADN Error: %ld - %@", code, [userInfo objectForKey:@"message"]);
    } else if ([domain compare:@"HTTP"] == NSOrderedSame) {
        NSLog(@"HTTP Error: %ld - %@", code, [userInfo objectForKey:@"message"]);
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
