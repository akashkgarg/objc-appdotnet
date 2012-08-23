//
//  AppDotNet.h
//  obj.appdotnet
//
//  Created by Akash Garg on 8/20/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADNUser.h"
#import "ADNPost.h"
#import "ADNLink.h"
#import "ADNHashTag.h"
#import "ADNImage.h"
#import "ADNMention.h"
#import "ADNConstants.h"

//------------------------------------------------------------------------------

// Note that all delegate methods have a "forRequestUUID" field, that contains
// the unique UUID for each API call you request from the your client
// application. This is because multiple callbacks can be triggered for a
// particular API request and to keep track of which calls go with which
// request, you can use the RequestUUID.
//
// Each API request call also returns the RequestUUID that you can keep track
// of in your client application.

@protocol ADNDelegate <NSObject>

// Callback when something fails while making a API request.
- (void) requestFailed:(NSError*)error forRequestUUID:(NSString*)uuid;

- (void) receivedUser:(ADNUser*)user forRequestUUID:(NSString*)uuid;

- (void) receivedUsers:(NSArray*)users forRequestUUID:(NSString*)uuid;

- (void) receivedPost:(ADNPost*)post forRequestUUID:(NSString*)uuid;

- (void) receivedPosts:(NSArray*)posts forRequestUUID:(NSString*)uuid;

@end

//------------------------------------------------------------------------------

@interface AppDotNet : NSObject
{
    NSString *_clientName;
    NSString *_clientVersion;

	// OAuth 2.0 stuff
    NSString *_accessToken;
    
    // Delegate callbacks.
    id<ADNDelegate> _delegate;

    // Active connections. 
    NSMutableDictionary *_connections;
}

@property (retain) NSString* clientName;
@property (retain) NSString* clientVersion;
@property (readonly) NSString* accessToken;

- (AppDotNet*) initWithDelegate:(id<ADNDelegate>)delegate
                    accessToken:(NSString*)token;

//------------------------------------------------------------------------------
#pragma mark -
#pragma mark App.Net API Methods.
//------------------------------------------------------------------------------

// All API methods return a NSString* which indicates a unique key for the
// request made. Each API method request can trigger multiple callbacks. The
// callbacks will contain the key from which the request was made. This is so
// that the user end application can keep track of which callbacks are
// associated with which requests in the case that multiple requests are sent
// asynchronously from the client. 

//------------------------------------------------------------------------------

// Checks the current client's token permission. 
// Delegate Methods Called: 
//          receivedUser:forRequestUUID:
- (NSString*) checkCurrentToken;

//------------------------------------------------------------------------------

// Get a user with the given ID. 
// Delegate Methods Called: 
//          receivedUser:forRequestUUID:
- (NSString*) getUserWithID:(NSUInteger)uid;
- (NSString*) getUserWithUsername:(NSString*)username;
- (NSString*) getMe;

// Follow the user with the given uid.
// Delegate Methods Called: 
//          receivedUser:forRequestUUID:
- (NSString*) followUserWithID:(NSUInteger)uid;
- (NSString*) followUserWithUsername:(NSString*)username;

// Unfollow a user with the given uid.
// Delegate Methods Called: 
//          receivedUser:forRequestUUID:
- (NSString*) unfollowUserWithID:(NSUInteger)uid;
- (NSString*) unfollowUserWithUsername:(NSString*)username;

//------------------------------------------------------------------------------

// Get the list of users the given user is following.
// Delegate Methods Called: 
//          receivedUsers:forRequestUUID:
- (NSString*) followedByID:(NSUInteger)uid;
- (NSString*) followedByUsername:(NSString*)username;
- (NSString*) followedByMe;

// Get a list of users following the given user.
// Delegate Methods Called: 
//          receivedUsers:forRequestUUID:
- (NSString*) followersOfID:(NSUInteger)uid;
- (NSString*) followersOfUsername:(NSString*)username;
- (NSString*) followersOfMe;

//------------------------------------------------------------------------------

// Mute/Unmute methods.
// Delegate Methods Called: 
//          receivedUser:forRequestUUID:
- (NSString*) muteUserWithID:(NSUInteger)uid;
- (NSString*) muteUserWithUsername:(NSString*)username;
- (NSString*) unmuteUserWithID:(NSUInteger)uid;
- (NSString*) unmuteUserWithUsername:(NSString*)username;

// Get the list of muted users.
// Delegate Methods Called: 
//          receivedUsers:forRequestUUID:
- (NSString*) mutedUsers;

//------------------------------------------------------------------------------

// Write a post. 
// replyTo can be -1 if not a reply to an existing post.
// annotations - dictionary of additional annotations in post. Can be nil. 
// links - an array of ADNLink objects that define the behavior of links in the
//         post text. Can be nil if no special formatting is required. 
// Delegate Methods Called: 
//          receivedPost:forRequestUUID:
- (NSString*) writePost:(NSString*)text
      replyToPostWithID:(NSInteger)postId
            annotations:(NSDictionary*)annotations
                  links:(NSArray*)links;

//------------------------------------------------------------------------------


// Retrieving a post.
// Delegate Methods Called: 
//          receivedPost:forRequestUUID:
- (NSString*) postWithID:(NSUInteger)postId;
- (NSString*) deletePostWithID:(NSUInteger)postId;

// All replies to a post with given postID.
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) repliesToPostWithID:(NSUInteger)postId;

//------------------------------------------------------------------------------

// All posts by a given user.
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) postsByUserWithUsername:(NSString*)username;
- (NSString*) postsByUserWithID:(NSUInteger)uid;
- (NSString*) postsByMe;

// All posts mentioning a given user.
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) postsMentioningUserWithUsername:(NSString*)username;
- (NSString*) postsMentioningUserWithID:(NSUInteger)uid;
- (NSString*) postsMentioningMe;

//------------------------------------------------------------------------------

// Get posts for current user's personal stream.
// sinceId - Include posts with post ids greater than this id. The response 
//           will not include this post id. Set to -1 if you don't want to
//           specify this. 
// beforeId - Include posts with post ids smaller than this id. The response 
//            will not include this post id. Set to -1 if you don't want to
//            specify this. 
// count - The number of Posts to return, up to a maximum of 200.
// includeUser - Should the nested User object be included in the Post? 
// includeAnnotations - Should the post annotations be included in the Post?
// includeReplies - Should reply Posts be included in the results?
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) myStreamSinceID:(NSInteger)sinceId 
                     beforeID:(NSInteger)beforeId
                        count:(NSUInteger)count
                  includeUser:(BOOL)includeUser 
           includeAnnotations:(BOOL)includeAnnotations
               includeReplies:(BOOL)includeReplies;

// Get post's in the global stream. See "myStreamSinceID:" above for meaning 
// of parameters.
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) globalStreamSinceID:(NSInteger)sinceId
                         beforeID:(NSInteger)beforeId
                            count:(NSUInteger)count
                      includeUser:(BOOL)includeUser
               includeAnnotations:(BOOL)includeAnnotations
                   includeReplies:(BOOL)includeReplies;

// All posts with a given hashtag. See "myStreamSinceID:" above for meaning 
// of paramters.
// Delegate Methods Called: 
//          receivedPosts:forRequestUUID:
- (NSString*) taggedPostsWithTag:(NSString*)tag
                         sinceID:(NSInteger)sinceId 
                        beforeID:(NSInteger)beforeId 
                           count:(NSUInteger)count 
                     includeUser:(BOOL)includeUser 
              includeAnnotations:(BOOL)includeAnnotations 
                  includeReplies:(BOOL)includeReplies;

@end

//------------------------------------------------------------------------------
