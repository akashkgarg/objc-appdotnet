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
#import "ADNScope.h"
#import "ADNConstants.h"

//------------------------------------------------------------------------------

// Typedefs for block support.
typedef void (^ADNReceivedScopeAndUser)(ADNScope *scope, ADNUser *user, 
                                        NSError *e);
typedef void (^ADNReceivedUser)(ADNUser *user, NSError *error);
typedef void (^ADNReceivedUsers)(NSArray *users, NSError *error);
typedef void (^ADNReceivedPost)(ADNPost *post, NSError *error);
typedef void (^ADNReceivedPosts)(NSArray *posts, NSError *error);

//------------------------------------------------------------------------------

@interface AppDotNet : NSObject
{
    NSString *_clientName;
    NSString *_clientVersion;

	// OAuth 2.0 stuff
    NSString *_accessToken;
}

@property (retain) NSString* clientName;
@property (retain) NSString* clientVersion;
@property (readonly) NSString* accessToken;

// Use this if you do not want to implement your own delegate class, but
// instead want to call all API methods with blocks instead. 
- (AppDotNet*) initWithAccessToken:(NSString*)token;

//------------------------------------------------------------------------------
#pragma mark -
#pragma mark App.Net API Methods.
//------------------------------------------------------------------------------

// All API methods require a completion block that will be called with the
// response data from app.net. If the response fails, the NSError object will
// be non-nil.

- (void) checkCurrentTokenWithBlock:(ADNReceivedScopeAndUser)block;

//------------------------------------------------------------------------------

// Retrieving a user with given userid or name.
- (void) userWithID:(NSUInteger)uid block:(ADNReceivedUser)block;
- (void) userWithUsername:(NSString*)username block:(ADNReceivedUser)block;
- (void) meWithBlock:(ADNReceivedUser)block;

//------------------------------------------------------------------------------

// Follow the user with the given uid.
- (void) followUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block;
- (void) followUserWithUsername:(NSString*)username 
                          block:(ADNReceivedUser)block;

// Unfollow a user with the given uid.
- (void) unfollowUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block;
- (void) unfollowUserWithUsername:(NSString*)username 
                            block:(ADNReceivedUser)block;

//------------------------------------------------------------------------------

// Get the list of users the given user is following.
- (void) followedByID:(NSUInteger)uid block:(ADNReceivedUsers)block;
- (void) followedByUsername:(NSString*)username block:(ADNReceivedUsers)block;
- (void) followedByMeWithBlock:(ADNReceivedUsers)block;

// Get a list of users following the given user.
- (void) followersOfID:(NSUInteger)uid block:(ADNReceivedUsers)block;
- (void) followersOfUsername:(NSString*)username block:(ADNReceivedUsers)block;
- (void) followersOfMeWithBlock:(ADNReceivedUsers)block;

//------------------------------------------------------------------------------

// Mute/Unmute methods.
- (void) muteUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block;
- (void) muteUserWithUsername:(NSString*)username block:(ADNReceivedUser)block;
- (void) unmuteUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block;
- (void) unmuteUserWithUsername:(NSString*)username block:(ADNReceivedUser)blk;

// Get the list of muted users.
- (void) mutedUsersWithBlock:(ADNReceivedUsers)block;

//------------------------------------------------------------------------------

// Write a post. 
// replyTo can be -1 if not a reply to an existing post.
// annotations - dictionary of additional annotations in post. Can be nil. 
// links - an array of ADNLink objects that define the behavior of links in the
//         post text. Can be nil if no special formatting is required. 
- (void) writePost:(NSString*)text
 replyToPostWithID:(NSInteger)postId
       annotations:(NSDictionary*)annotations
             links:(NSArray*)links
             block:(ADNReceivedPost)block;

//------------------------------------------------------------------------------

// Retrieving a post.
- (void) postWithID:(NSUInteger)postId block:(ADNReceivedPost)block;
- (void) deletePostWithID:(NSUInteger)postId block:(ADNReceivedPost)block;

// All replies to a post with given postID.
- (void) repliesToPostWithID:(NSUInteger)postId block:(ADNReceivedPosts)block;

//------------------------------------------------------------------------------

// All posts by a given user.
- (void) postsByUserWithUsername:(NSString*)username 
                           block:(ADNReceivedPosts)blk;
- (void) postsByUserWithID:(NSUInteger)uid block:(ADNReceivedPosts)block;
- (void) postsByMeWithBlock:(ADNReceivedPosts)block;

// All posts mentioning a given user.
- (void) postsMentioningUserWithUsername:(NSString*)username
                                   block:(ADNReceivedPosts)block;
- (void) postsMentioningUserWithID:(NSUInteger)uid
                             block:(ADNReceivedPosts)block;
- (void) postsMentioningMeWithBlock:(ADNReceivedPosts)block;

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
- (void) myStreamSinceID:(NSInteger)sinceId 
                     beforeID:(NSInteger)beforeId
                        count:(NSUInteger)count
                  includeUser:(BOOL)includeUser 
           includeAnnotations:(BOOL)includeAnnotations
               includeReplies:(BOOL)includeReplies
                        block:(ADNReceivedPosts)block;

// Get post's in the global stream. See "myStreamSinceID:" above for meaning 
// of parameters.
- (void) globalStreamSinceID:(NSInteger)sinceId
                         beforeID:(NSInteger)beforeId
                            count:(NSUInteger)count
                      includeUser:(BOOL)includeUser
               includeAnnotations:(BOOL)includeAnnotations
                   includeReplies:(BOOL)includeReplies
                            block:(ADNReceivedPosts)block;

// All posts with a given hashtag. See "myStreamSinceID:" above for meaning 
// of paramters.
- (void) taggedPostsWithTag:(NSString*)tag
                         sinceID:(NSInteger)sinceId 
                        beforeID:(NSInteger)beforeId 
                           count:(NSUInteger)count 
                     includeUser:(BOOL)includeUser 
              includeAnnotations:(BOOL)includeAnnotations 
                  includeReplies:(BOOL)includeReplies
                           block:(ADNReceivedPosts)block;

@end

//------------------------------------------------------------------------------
