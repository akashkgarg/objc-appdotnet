//
//  AppDotNet.h
//  obj.appdotnet
//
//  Created by Akash Garg on 8/20/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------
#pragma mark -
#pragma Defines/Constants
//------------------------------------------------------------------------------

#define ADN_API_URL             @"https://alpha-api.app.net"

#define ADN_AUTH_HEADER         @"Authorization"

#define UID_KEY                 @"id"
#define USERNAME_KEY            @"username"
#define NAME_KEY                @"name"
#define DESCRIPTION_KEY         @"description"
#define TIMEZONE_KEY            @"timezone"
#define LOCALE_KEY              @"locale"
#define AVATAR_IMAGE_KEY        @"avatar_image"
#define COVER_IMAGE_KEY         @"cover_image"
#define TYPE_KEY                @"type"
#define CREATED_AT_KEY          @"created_at"
#define TEXT_KEY                @"text"
#define HTML_KEY                @"html"
#define ENTITIES_KEY            @"entities"
#define MENTIONS_KEY            @"mentions"
#define HASHTAGS_KEY            @"hashtags"
#define LINKS_KEY               @"links"
#define FOLLOWERS_KEY           @"followers"
#define FOLLOWING_KEY           @"following"
#define POSTS_KEY               @"posts"
#define APP_DATA_KEY            @"app_data"
#define FOLLOWS_YOU_KEY         @"follows_you"
#define YOU_FOLLOW_KEY          @"you_follow"
#define YOU_MUTED_KEY           @"you_muted"
#define WIDTH_KEY               @"width"
#define HEIGHT_KEY              @"height"
#define URL_KEY                 @"url"
#define POS_KEY                 @"pos"
#define LEN_KEY                 @"len"
#define COUNTS_KEY              @"counts"
#define COUNT_KEY               @"count"
#define USER_KEY                @"user"
#define ERROR_KEY               @"error"
#define CODE_KEY                @"code"
#define MESSAGE_KEY             @"message"
#define SOURCE_KEY              @"source"
#define REPLY_TO_KEY            @"reply_to"
#define LINK_KEY                @"link"
#define THREAD_ID_KEY           @"thread_id"
#define ANNOTATIONS_KEY         @"annotations"
#define NUM_REPLIES_KEY         @"num_replies"
#define IS_DELETED_KEY          @"is_deleted"
#define SINCE_ID_KEY            @"since_id"
#define BEFORE_ID_KEY           @"before_id"
#define INCLUDE_USER_KEY        @"include_user"
#define INCLUDE_ANNOTATIONS_KEY @"include_annotations"
#define INCLUDE_REPLIES_KEY     @"include_replies"

#define MY_USERID               @"me"

#define ADN_DATE_FORMAT         @"yyyy-MM-dd'T'HH:mm:ss'Z'"

#define NSStringFromBOOL(a)     (a ? @"1" : @"0")

//------------------------------------------------------------------------------
#pragma Forward Declarations
//------------------------------------------------------------------------------

@class ADNUser;
@class ADNPost;

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

// Returns info about the current OAuth Token and current User object. Calls
// the delegate's tokenUser method.
- (NSString*) checkCurrentToken;

// Get a user with the given ID. 
- (NSString*) getUserWithID:(NSUInteger)uid;
- (NSString*) getUserWithUsername:(NSString*)username;
- (NSString*) getMe;

// Follow the user with the given uid.
- (NSString*) followUserWithID:(NSUInteger)uid;
- (NSString*) followUserWithUsername:(NSString*)username;

// Unfollow a user with the given uid.
- (NSString*) unfollowUserWithID:(NSUInteger)uid;
- (NSString*) unfollowUserWithUsername:(NSString*)username;

// Get the list of users the given user is following.
- (NSString*) followedByID:(NSUInteger)uid;
- (NSString*) followedByUsername:(NSString*)username;
- (NSString*) followedByMe;

// Get a list of users following the given user.
- (NSString*) followersOfID:(NSUInteger)uid;
- (NSString*) followersOfUsername:(NSString*)username;
- (NSString*) followersOfMe;

// Mute/Unmute methods.
- (NSString*) muteUserWithID:(NSUInteger)uid;
- (NSString*) muteUserWithUsername:(NSString*)username;
- (NSString*) unmuteUserWithID:(NSUInteger)uid;
- (NSString*) unmuteUserWithUsername:(NSString*)username;

// Get the list of muted users.
- (NSString*) mutedUsers;

// replyTo can be -1 if not a reply to an existing post.
// annotations - dictionary of additional annotations in post. Can be nil. 
// links - an array of ADNLink objects that define the behavior of links in the
// post text. Can be nil if no special formatting is required. 
- (NSString*) writePost:(NSString*)text
      replyToPostWithID:(NSInteger)postId
            annotations:(NSDictionary*)annotations
                  links:(NSArray*)links;

- (NSString*) postWithID:(NSUInteger)postId;
- (NSString*) deletePostWithID:(NSUInteger)postId;
- (NSString*) repliesToPostWithID:(NSUInteger)postId;

- (NSString*) postsByUserWithUsername:(NSString*)username;
- (NSString*) postsByUserWithID:(NSUInteger)uid;
- (NSString*) postsByMe;

- (NSString*) postsMentioningUserWithUsername:(NSString*)username;
- (NSString*) postsMentioningUserWithID:(NSUInteger)uid;
- (NSString*) postsMentioningMe;

// Get posts for user's personal stream.
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
- (NSString*) myStreamSinceID:(NSInteger)sinceId 
                     beforeID:(NSInteger)beforeId
                        count:(NSUInteger)count
                  includeUser:(BOOL)includeUser 
           includeAnnotations:(BOOL)includeAnnotations
               includeReplies:(BOOL)includeReplies;

- (NSString*) globalStreamSinceID:(NSInteger)sinceId
                         beforeID:(NSInteger)beforeId
                            count:(NSUInteger)count
                      includeUser:(BOOL)includeUser
               includeAnnotations:(BOOL)includeAnnotations
                   includeReplies:(BOOL)includeReplies;

- (NSString*) taggedPostsWithTag:(NSString*)tag
                         sinceID:(NSInteger)sinceId 
                        beforeID:(NSInteger)beforeId 
                           count:(NSUInteger)count 
                     includeUser:(BOOL)includeUser 
              includeAnnotations:(BOOL)includeAnnotations 
                  includeReplies:(BOOL)includeReplies;

@end

//------------------------------------------------------------------------------
