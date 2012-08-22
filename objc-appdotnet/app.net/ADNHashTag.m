//
//  ADNHashTag.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDotNet.h"
#import "ADNHashTag.h"

@implementation ADNHashTag

//------------------------------------------------------------------------------

+ (id) hashtagFromJSONDictionary:(NSDictionary *)dict
{
    return [[[ADNHashTag alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    [self initWithTag:[dict objectForKey:NAME_KEY]
                  pos:[[dict objectForKey:POS_KEY] intValue]
                  len:[[dict objectForKey:LEN_KEY] intValue]];
    return self;
}

//------------------------------------------------------------------------------

- (id) initWithTag:(NSString*)t
               pos:(NSUInteger)p
               len:(NSUInteger)l
{
    self = [super init];
    self.tag = t;
    self.pos = p;
    self.len = l;
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self.tag release];
    [super dealloc];
}

//------------------------------------------------------------------------------

@end
