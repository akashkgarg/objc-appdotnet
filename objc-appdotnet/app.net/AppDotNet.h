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
#define USER_KEY                @"user"

#define ADN_DATE_FORMAT         @"yyyy-MM-dd'T'HH:mm:ss'Z'"

//------------------------------------------------------------------------------
#pragma Forward Declarations
//------------------------------------------------------------------------------

@class ADNUser;

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

@end

//------------------------------------------------------------------------------
