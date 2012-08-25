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

    /*
    NSString *client_id = @"";
    NSString *redirect_uri = @"https://github.com/akashkgarg/objc-appdotnet";
    NSString *scopes = @"stream%20email%20write_post%20follow%20messages%20export";

    NSString *uri = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri%@&scope=%@", client_id, redirect_uri, scopes];

    NSURL *url = [NSURL URLWithString:uri];
    [[NSWorkspace sharedWorkspace] openURL:url];
    */
    
    NSString *token = @"AQAAAAAAAIAnhVGQcxX_8pt0_O7DMrVrlRL1jyZ4dKcvN8JOqrS4fudYChJxC_YcmtzM7ThrbsDkd4qlm3qlEn--mZE5ma5iBw";
    
    AppDotNet *engine = [[AppDotNet alloc] initWithAccessToken:token];
    
//    [engine checkCurrentTokenWithBlock:^(ADNScope *scope, ADNUser *user, NSError *e) {
//        if (e) {
//            [self requestFailed:e];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
    
//    [engine userWithID:6581 block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//        
//    }];
    
//    [engine userWithUsername:@"blablah" block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//        
//    }];
    
//    [engine followUserWithID:6581 block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
    
//    [engine unfollowUserWithID:6581 block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
      
//    [engine followedByMeWithBlock:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
//    
//    [engine followedByUsername:@"@terhechte" block:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
//    
//    [engine followedByUsername:@"doesntexistthisuser" block:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
    
    
//    [engine followersOfMeWithBlock:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
//    
//    [engine followersOfUsername:@"@akg" block:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
    
    
//    [engine muteUserWithUsername:@"@terhechte" block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
//    
//    [engine muteUserWithUsername:@"@spacekatgal" block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
    
//    [engine mutedUsersWithBlock:^(NSArray *users, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUsers:users];
//        }
//    }];
//    
//    [engine unmuteUserWithUsername:@"@terhechte" block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
//    
//    [engine unmuteUserWithUsername:@"@spacekatgal" block:^(ADNUser *user, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedUser:user];
//        }
//    }];
    
//    [engine writePost:@"HELLO WORLD! #testing" replyToPostWithID:-1 annotations:nil links:nil block:^(ADNPost *post, NSError *error) {
//        if (error) {
//            [self requestFailed:error];
//        } else {
//            [self receivedPost:post];
//        }
//    }];
    
//    [engine postWithID:50 block:^(ADNPost *post, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPost:post];
//    }];
//    
//    [engine deletePostWithID:50 block:^(ADNPost *post, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPost:post];
//    }];
    
//    [engine repliesToPostWithID:121511 block:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];
//    
//    [engine repliesToPostWithID:50 block:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];
    
//    [engine postsByMeWithBlock:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];
//    
//    [engine postsMentioningMeWithBlock:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];
    
//    [engine myStreamSinceID:152000 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];
    
//    [engine globalStreamSinceID:-1 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
//        if (error)
//            [self requestFailed:error];
//        else
//            [self receivedPosts:posts];
//    }];

    [engine taggedPostsWithTag:@"gamedev" sinceID:-1 beforeID:-1 count:20 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
}

//------------------------------------------------------------------------------

- (void) receivedUser:(ADNUser *)user
{
    NSLog(@"Got User with username: %@", user.username);
}

//------------------------------------------------------------------------------

- (void) requestFailed:(NSError *)error
{
    NSLog(@"Failed!");
    
    NSDictionary *userInfo = [error userInfo];
    NSString *domain = [error domain];
    NSUInteger code = [error code];
    
    if ([domain compare:@"ADN"] == NSOrderedSame) {
        NSLog(@"ADN Error: %ld - %@", code, [userInfo objectForKey:@"message"]);
    } else if ([domain compare:@"HTTP"] == NSOrderedSame) {
        NSLog(@"HTTP Error: %ld - %@", code, [userInfo objectForKey:@"message"]);
    } else {
        
    }
}

//------------------------------------------------------------------------------

- (void) receivedUsers:(NSArray *)users
{
    for (ADNUser *user in users) {
        NSLog(@"got user: %@", user.username);
    }
}

//------------------------------------------------------------------------------

- (void) receivedPost:(ADNPost *)post
{
    NSLog(@"Got Post: %@", post.text);
}

//------------------------------------------------------------------------------

- (void) receivedPosts:(NSArray *)posts
{
    for (ADNPost *post in posts) {
        NSLog(@"got post: %ld - %@", post.postId, post.text);
    }
}

//------------------------------------------------------------------------------

@end
