//
//  ADNUser.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADNImage.h"

//------------------------------------------------------------------------------

enum ADNUserType {
    HUMAN = 0, 
    BOT = 1, 
    CORPORATE = 2, 
    FEED = 4
};

//------------------------------------------------------------------------------

// Defines the user object for App.Net
@interface ADNUser : NSObject

//------------------------------------------------------------------------------
#pragma Properties
//------------------------------------------------------------------------------

@property NSUInteger userId;
@property (retain) NSString *username;
@property (retain) NSString *descriptiveName;

// User supplied biographical information. All Unicode characters allowed. 
@property (retain) NSString *descriptionText;

// Server-generated annotated HTML version of biographical information.
@property (retain) NSString *descriptionHTML;

// Mentions, hashtags, links included in biographical information.
@property (retain) NSMutableArray *mentions;
@property (retain) NSMutableArray *hashtags;
@property (retain) NSMutableArray *links;

@property (retain) NSTimeZone *timezone;
@property (retain) NSLocale *locale;

@property (retain) ADNImage *avatarImage;
@property (retain) ADNImage *coverImage;

@property enum ADNUserType type;

// When the user was created.
@property (retain) NSDate *createdAt;

// The number of users this user is following.
@property NSUInteger followingCount;

// The number of users following this user.
@property NSUInteger followerCount;

// The number of posts created by this user.
@property NSUInteger postCount;

// Object where each app can store opaque information for this user. This could 
// be useful for storing application state (read pointers, default filters in 
// the app, etc). This should be in JSON format.
@property (retain) NSData *appData;

// Does this user follow the user making the request? May be omitted if this is 
// not an authenticated request.
@property BOOL followsYou;

// Does this user follow the user making the request? May be omitted if this is 
// not an authenticated request.
@property BOOL youFollow;

// Has the user making the request blocked this user? May be omitted if this is 
// not an authenticated request. 
@property BOOL muted;

//------------------------------------------------------------------------------

+ (id) userFromJSONDictionary:(NSDictionary*)dict;
- (id) initWithJSONDictionary:(NSDictionary*)dict;

//------------------------------------------------------------------------------

- (BOOL) isHuman;
- (BOOL) isBot;
- (BOOL) isCompany;
- (BOOL) isFeed;

//------------------------------------------------------------------------------

@end
