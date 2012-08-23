//
//  ADNPost.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/22/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "ADNConstants.h"
#import "ADNPost.h"
#import "ADNMention.h"
#import "ADNLink.h"
#import "ADNHashTag.h"
#import "ISO8601DateFormatter.h"

@implementation ADNPost

@synthesize postId, user;
@synthesize createdAt, text, html;
@synthesize clientName, clientURL;
@synthesize replyToPostId, threadId, replyCount;
@synthesize annotations;
@synthesize mentions, hashtags, links;
@synthesize deleted;

//------------------------------------------------------------------------------

+ (id) postFromJSONDictionary:(NSDictionary*)dict
{
    return [[[ADNPost alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    self = [super init];

    self.postId = [[dict objectForKey:UID_KEY] intValue];

    self.user = nil;
    NSDictionary *userDict = [dict objectForKey:USER_KEY];
    if (userDict) {
        self.user = [ADNUser userFromJSONDictionary:userDict];
    }

    // Get the date.
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    self.createdAt = [formatter dateFromString:[dict objectForKey:CREATED_AT_KEY]];
    [formatter release];

    self.text = [dict objectForKey:TEXT_KEY];
    self.html = [dict objectForKey:HTML_KEY];

    // Client information.
    NSDictionary *sourceDict = [dict objectForKey:SOURCE_KEY];
    self.clientName = [sourceDict objectForKey:NAME_KEY];
    self.clientURL = [NSURL URLWithString:[sourceDict objectForKey:LINK_KEY]];

    if ([dict objectForKey:REPLY_TO_KEY]) {
        self.replyToPostId = [[dict objectForKey:REPLY_TO_KEY] intValue];
    } else {
        self.replyToPostId = -1;
    }

    self.threadId = [[dict objectForKey:THREAD_ID_KEY] intValue];
    self.replyCount = [[dict objectForKey:NUM_REPLIES_KEY] intValue];

    self.annotations = [dict objectForKey:ANNOTATIONS_KEY];
    
    NSDictionary *entities = [dict objectForKey:ENTITIES_KEY];

    // load mentions
    self.mentions = [NSMutableArray array];
    NSArray *mentions_arr = [entities objectForKey:MENTIONS_KEY];
    for (NSDictionary *md in mentions_arr) {
        ADNMention *m = [ADNMention mentionFromJSONDictionary:md];
        [self.mentions addObject:m];
    }
    
    // load hashtags
    self.hashtags = [NSMutableArray array];
    NSArray *hashtags_arr = [entities objectForKey:HASHTAGS_KEY];
    for (NSDictionary *hd in hashtags_arr) {
        ADNHashTag *tag = [ADNHashTag hashtagFromJSONDictionary:hd];
        [self.hashtags addObject:tag];
    }
    
    // load links
    self.links = [NSMutableArray array];
    NSArray *links_arr = [entities objectForKey:LINKS_KEY];
    for (NSDictionary *ld in links_arr) {
        ADNLink *link = [ADNLink linkFromJSONDictionary:ld];
        [self.links addObject:link];
    }

    if ([dict objectForKey:IS_DELETED_KEY]) {
        self.deleted = [[dict objectForKey:IS_DELETED_KEY] boolValue];
    } else {
        self.deleted = NO;
    }

    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self.user release];
    [self.createdAt release];
    [self.text release];
    [self.html release];
    [self.clientName release];
    [self.clientURL release];
    [self.mentions release];
    [self.hashtags release];
    [self.links release];
    [super dealloc];
}

//------------------------------------------------------------------------------

@end
