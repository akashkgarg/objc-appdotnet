//
//  ADNUser.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDotNet.h"
#import "ADNUser.h"
#import "JSONKit.h"

#import "ADNMention.h"
#import "ADNHashTag.h"
#import "ADNLink.h"

#import "ISO8601DateFormatter.h"

@implementation ADNUser

@synthesize userId, username, descriptiveName;
@synthesize descriptionText, descriptionHTML; 
@synthesize mentions, hashtags, links;
@synthesize timezone, locale;
@synthesize avatarImage, coverImage;
@synthesize type;
@synthesize createdAt; 
@synthesize followingCount, followerCount, postCount;
@synthesize appData;
@synthesize followsYou, youFollow, muted;

//------------------------------------------------------------------------------

- (enum ADNUserType) typeFromString:(NSString*)str
{
    if ([str compare:@"human"] == NSOrderedSame)
        return HUMAN;
    else if ([str compare:@"bot"] == NSOrderedSame)
        return BOT;
    else if ([str compare:@"corporate"] == NSOrderedSame)
        return CORPORATE;
    else if ([str compare:@"feed"] == NSOrderedSame)
        return FEED;
    else
        NSAssert(false, @"Invalid type for user");
    // stop the compiler from complaining. Shoudl never get here.
    return HUMAN;
}

//------------------------------------------------------------------------------

+ (id) userFromJSONDictionary:(NSDictionary*)dict
{
    return [[[ADNUser alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    self = [super init];

    self.userId = [[dict objectForKey:UID_KEY] intValue];
    self.username = [dict objectForKey:USERNAME_KEY];
    self.descriptiveName = [dict objectForKey:NAME_KEY];

    NSDictionary *descriptionDict = [dict objectForKey:DESCRIPTION_KEY];
    self.descriptionText = [descriptionDict objectForKey:TEXT_KEY];
    self.descriptionHTML = [descriptionDict objectForKey:HTML_KEY];

    NSDictionary *entities = [descriptionDict objectForKey:ENTITIES_KEY];

    // load mentions
    self.mentions = [NSMutableArray array];
    NSArray *mentions = [entities objectForKey:MENTIONS_KEY];
    for (NSDictionary *md in mentions) {
        ADNMention *m = [ADNMention mentionFromJSONDictionary:md];
        [self.mentions addObject:m];
    }
    
    // load hashtags
    self.hashtags = [NSMutableArray array];
    NSArray *hashtags = [entities objectForKey:HASHTAGS_KEY];
    for (NSDictionary *hd in hashtags) {
        ADNHashTag *tag = [ADNHashTag hashtagFromJSONDictionary:hd];
        [self.hashtags addObject:tag];
    }
    
    // load links
    self.links = [NSMutableArray array];
    NSArray *links = [entities objectForKey:LINKS_KEY];
    for (NSDictionary *ld in links) {
        ADNLink *link = [ADNLink linkFromJSONDictionary:ld];
        [self.links addObject:link];
    }

    self.timezone = [NSTimeZone timeZoneWithName:[dict objectForKey:TIMEZONE_KEY]];
    self.locale = [[[NSLocale alloc] initWithLocaleIdentifier:[dict objectForKey:LOCALE_KEY]] autorelease];
    
    
    self.avatarImage = [ADNImage imageFromJSONDictionary:[dict objectForKey:AVATAR_IMAGE_KEY]];
    self.coverImage = [ADNImage imageFromJSONDictionary:[dict objectForKey:COVER_IMAGE_KEY]];
    
    self.type = [self typeFromString:[dict objectForKey:TYPE_KEY]];
    
    // Get the date.
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    self.createdAt = [formatter dateFromString:[dict objectForKey:CREATED_AT_KEY]];
    [formatter release];
    
    // Counts dictionary
    NSDictionary *counts = [dict objectForKey:COUNTS_KEY];
    
    self.followerCount = [[counts objectForKey:FOLLOWERS_KEY] intValue];
    self.followingCount = [[counts objectForKey:FOLLOWING_KEY] intValue];
    self.postCount = [[counts objectForKey:POSTS_KEY] intValue];
    
    self.appData = [dict objectForKey:APP_DATA_KEY];
    
    self.followsYou = [[dict objectForKey:FOLLOWS_YOU_KEY] boolValue];
    self.youFollow = [[dict objectForKey:YOU_FOLLOW_KEY] boolValue];
    self.muted = [[dict objectForKey:YOU_MUTED_KEY] boolValue];
    
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self.username release];
    [self.descriptiveName release];
    [self.descriptionText release];
    [self.descriptionHTML release];
    [self.mentions release];
    [self.hashtags release];
    [self.links release];
    [self.timezone release];
    [self.locale release];
    [self.avatarImage release];
    [self.coverImage release];
    [self.createdAt release];
    [self.appData release];
    [super dealloc];
}

//------------------------------------------------------------------------------

- (BOOL) isHuman
{
    return self.type == HUMAN;
}

//------------------------------------------------------------------------------

- (BOOL) isBot
{
    return self.type == BOT;
}

//------------------------------------------------------------------------------

- (BOOL) isFeed
{
    return self.type == FEED;
}

//------------------------------------------------------------------------------

- (BOOL) isCompany
{
    return self.type == CORPORATE;
}

//------------------------------------------------------------------------------

@end
