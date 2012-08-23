//
//  ADNURLConnection.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/22/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

//------------------------------------------------------------------------------

// Unique powers of two for each flag so that we can bitwise OR them to get the
// combination of response types.
enum ADNResponseType {
    LIST = 0x01,  // top level is a list
    DICT = 0x02, // top level is a dictionary
    IS_USER = 0x04, // If data IS the "user" object
    HAS_USER = 0x08, // If data has a "user" object
    HAS_SCOPES = 0x10, // Has info about token "scopes" 
};

//------------------------------------------------------------------------------

@interface ADNURLConnection : NSURLConnection
{
    // The response data.
    NSMutableData *_data;
    
    // The response type, useful for parsing the response data.
    enum ADNResponseType _responseType;

    // UUID for the connection.
    NSString *_uuid;
}

@property (readonly) NSMutableData *data;
@property (readonly) enum ADNResponseType responseType;
@property (readonly) NSString *uuid;
@property (retain) NSHTTPURLResponse *response;

//------------------------------------------------------------------------------

+ (id) connectionWithRequest:(NSURLRequest*)request
                    delegate:(id)delegate
                responseType:(enum ADNResponseType)type;

- (id) initWithRequest:(NSURLRequest *)request
              delegate:(id)delegate
          responseType:(enum ADNResponseType)type;

//------------------------------------------------------------------------------

- (void) resetDataLength;
- (void) appendData:(NSData*)data;

//------------------------------------------------------------------------------

@end
