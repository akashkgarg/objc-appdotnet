//
//  ADNImage.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "ADNImage.h"
#import "ADNConstants.h"

@implementation ADNImage

@synthesize width, height, url;

//------------------------------------------------------------------------------

+ (id) imageFromJSONDictionary:(NSDictionary *)dict
{
    return [[[ADNImage alloc] initWithJSONDictionary:dict] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithJSONDictionary:(NSDictionary*)dict
{
    return [self initWithHeight:[[dict objectForKey:HEIGHT_KEY] intValue]
                   width:[[dict objectForKey:WIDTH_KEY] intValue]
                     url:[dict objectForKey:URL_KEY]];
}

//------------------------------------------------------------------------------

- (id) initWithHeight:(NSUInteger)h
                width:(NSUInteger)w
                  url:(NSString*)addr
{
    self = [super init];
    self.height = h;
    self.width = w;
    self.url = [NSURL URLWithString:addr];
    
    return self;
}

//------------------------------------------------------------------------------


- (void) dealloc
{
    [self.url release];
    [super dealloc];
}

//------------------------------------------------------------------------------

@end
