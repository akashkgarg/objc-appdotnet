//
//  ADNURLConnection.m
//  objc-appdotnet
//
//  Created by Akash Garg on 8/22/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "ADNURLConnection.h"

@implementation ADNURLConnection

@synthesize data = _data;
@synthesize responseType = _responseType;
@synthesize uuid = _uuid;
@synthesize response;

//------------------------------------------------------------------------------

+ (id) connectionWithRequest:(NSURLRequest*)request
                    delegate:(id)delegate
                responseType:(enum ADNResponseType)type
{
    return [[[ADNURLConnection alloc] initWithRequest:request 
                                             delegate:delegate 
                                         responseType:type] autorelease];
}

//------------------------------------------------------------------------------

- (id) initWithRequest:(NSURLRequest *)request
              delegate:(id)delegate
          responseType:(enum ADNResponseType)type
{
    self = [super initWithRequest:request delegate:delegate];
    _data = [[NSMutableData alloc] initWithCapacity:0];
    _responseType = type;
    
    // Create UUID for connection.
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    _uuid = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [_data release];
    [_uuid release];
    [self.response release];
    [super dealloc];
}

//------------------------------------------------------------------------------
 
- (void) resetDataLength
{
    [_data setLength:0];
}

//------------------------------------------------------------------------------

- (void) appendData:(NSData*)data
{
    [_data appendData:data];
}

//------------------------------------------------------------------------------

@end
