//
//  ADNMention.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDotNet.h"
#import "ADNMention.h"

@implementation ADNMention

@synthesize username, userId, pos, len;

//------------------------------------------------------------------------------

+ (id) mentionFromJSONDictionary:(NSDictionary *)dict
{
    return [[[ADNMention alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    [self initWithUserName:[dict objectForKey:NAME_KEY]
                    userId:[[dict objectForKey:UID_KEY] intValue]
                       pos:[[dict objectForKey:POS_KEY] intValue]
                       len:[[dict objectForKey:LEN_KEY] intValue]];
    return self;
}

//------------------------------------------------------------------------------

- (id) initWithUserName:(NSString*)uname 
                 userId:(NSUInteger)uid 
                    pos:(NSUInteger)p 
                    len:(NSUInteger)l
{
    self = [super init];
    self.username = uname;
    self.userId = uid;
    self.pos = p;
    self.len = l;
    
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self.username release];
    [super dealloc];
}

//------------------------------------------------------------------------------

@end
