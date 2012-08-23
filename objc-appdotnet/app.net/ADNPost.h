//
//  ADNPost.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/22/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADNUser.h"

@interface ADNPost : NSObject

//------------------------------------------------------------------------------
#pragma Properties
//------------------------------------------------------------------------------

@property NSUInteger postId;
@property (retain) ADNUser *user; // could be nil, if user is deleted.
@property (retain) NSDate *createdAt;
@property (retain) NSString *text; // text of the post.
@property (retain) NSString *html; // html rendering of post text.

@property (retain) NSString *clientName; // client that created this post.
@property (retain) NSURL *clientURL; // url to client that created post.

// Stores the postId of hte post that this post is a reply to. If not a reply,
// then this value is negative. 
@property NSInteger replyToPostId;

// The id of the post at the root of the thread that this post is a part of. If 
// threadId == postId then this property does not guarantee that the 
// thread has > 1 posts. 
@property NSInteger threadId;

// The number of posts created in reply to this post.
@property NSUInteger replyCount;

// Opaque information for each post. Post annotations are attributes 
// (key, value pairs) that describe the entire post.
@property (retain) NSData *annotations;

// Mentions, hashtags, links included in the post.
@property (retain) NSMutableArray *mentions;
@property (retain) NSMutableArray *hashtags;
@property (retain) NSMutableArray *links;

// True if the post is deleted. If deleted will not have text, html, mentions,
// hashtags, links.
@property BOOL deleted;

//------------------------------------------------------------------------------

+ (id) postFromJSONDictionary:(NSDictionary*)dict;
- (id) initWithJSONDictionary:(NSDictionary*)dict;

//------------------------------------------------------------------------------

@end
