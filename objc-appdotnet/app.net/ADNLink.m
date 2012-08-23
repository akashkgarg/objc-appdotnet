//
//  ADNLink.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "ADNLink.h"
#import "JSONKit.h"
#import "ADNConstants.h"

@implementation ADNLink

@synthesize anchorText, url, pos, len;

//------------------------------------------------------------------------------

+ (id) linkFromJSONDictionary:(NSDictionary*)dict
{
    return [[[ADNLink alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    [self initWithText:[dict objectForKey:TEXT_KEY]
                   url:[dict objectForKey:URL_KEY]
                   pos:[[dict objectForKey:POS_KEY] intValue]
                   len:[[dict objectForKey:LEN_KEY] intValue]];
    return self;
}

//------------------------------------------------------------------------------

- (id) initWithText:(NSString*)text
                url:(NSString*)addr
                pos:(NSUInteger)p
                len:(NSUInteger)l
{
    self = [super init];

    self.anchorText = text;
    self.url = [NSURL URLWithString:addr];
    self.pos = p;
    self.len = l;

    return self;
}

//------------------------------------------------------------------------------

- (NSString*) asJSONString
{
    return [[self asDictionary] JSONString];
}

//------------------------------------------------------------------------------

- (NSDictionary*) asDictionary
{
    NSMutableDictionary *dict = [NSDictionary dictionary];
    [dict setObject:self.anchorText forKey:TEXT_KEY];
    [dict setObject:[self.url description] forKey:URL_KEY];
    [dict setObject:[NSString stringWithFormat:@"%ld", self.pos] forKey:POS_KEY];
    [dict setObject:[NSString stringWithFormat:@"%ld", self.len] forKey:LEN_KEY];
    
    return dict;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [self.anchorText release];
    [self.url release];
    [super dealloc];
}

//------------------------------------------------------------------------------

@end
