//
//  AppDotNet.m
//  obj.appdotnet
//
//  Created by Akash Garg on 8/20/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDotNet.h"
#import "ADNUser.h"
#import "JSONKit.h"
#import "ADNUser.h"
#import "ADNURLConnection.h"

@implementation AppDotNet

@synthesize clientName, clientVersion, accessToken;

//------------------------------------------------------------------------------
#pragma mark Parsing Methods
//------------------------------------------------------------------------------

- (void) parseUser:(NSDictionary*)userdict reportWithID:(NSString*)uuid
{
    // Create the user
    ADNUser *user = [ADNUser userFromJSONDictionary:userdict];

    // report to delegate.
    [_delegate receivedUser:user forRequestUUID:uuid];
}

//------------------------------------------------------------------------------

- (void) parseDataForConnection:(ADNURLConnection*)connection
{
    NSData *data = connection.data;
    NSUInteger responseType = (NSUInteger)connection.responseType;
    NSString *uuid = connection.uuid;
    
    if (responseType & HAS_USER) {
        // Get the user dict.
        NSDictionary *dataDict = [data objectFromJSONData];
        NSDictionary *userDict = [dataDict objectForKey:USER_KEY];
        
        // parse the user and report to delegate.
        [self parseUser:userDict reportWithID:uuid];
    }
    
    if (responseType & IS_USER) {
        // Get user dict.
        NSDictionary *userdict = [data objectFromJSONData];
        
        // parse the user and report to delegate.
        [self parseUser:userdict reportWithID:uuid];
    }
}

//------------------------------------------------------------------------------
#pragma mark Private Helper Methods
//------------------------------------------------------------------------------

- (void) setHeader:(NSMutableURLRequest*)request
{
    NSString *val = [NSString stringWithFormat:@"Bearer %@", _accessToken];
    [request setValue:val forHTTPHeaderField:ADN_AUTH_HEADER];
}

//------------------------------------------------------------------------------

- (NSMutableURLRequest*) createRequest:(NSString*)uri
{
    NSString *fulluri = [NSString stringWithFormat:@"%@%@", ADN_API_URL, uri];
    NSURL *url = [NSURL URLWithString:fulluri];
    NSMutableURLRequest *request = 
        [[NSMutableURLRequest alloc] initWithURL:url];
    [self setHeader:request];
    
    return request;
}

//------------------------------------------------------------------------------

- (NSString*) sendRequest:(NSMutableURLRequest*)request 
             responseType:(enum ADNResponseType)responseType
{
    ADNURLConnection *connection = 
        [ADNURLConnection connectionWithRequest:request delegate:self
                                   responseType:responseType];

    // Preserve the connection.
    [_connections setObject:connection forKey:connection.uuid];

    return connection.uuid;
}

//------------------------------------------------------------------------------

- (void) destroyConnection:(ADNURLConnection*)connection
{
    [_connections removeObjectForKey:[connection uuid]];
}

//------------------------------------------------------------------------------

- (AppDotNet*) initWithDelegate:(id<ADNDelegate>)delegate 
                    accessToken:(NSString*)token
{
    self = [super init];
    _delegate = delegate;
    _accessToken = [token retain];
    _connections = [[NSMutableDictionary dictionary] retain];
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [_accessToken release];
    [_connections release];
    [_clientVersion release];
    [_clientName release];
    
    [super dealloc];
}

//------------------------------------------------------------------------------
#pragma mark API Methods
//------------------------------------------------------------------------------


- (NSString*) checkCurrentToken
{
    NSMutableURLRequest *request = [self createRequest:@"/stream/0/token"];
    enum ADNResponseType responseType = HAS_USER | HAS_SCOPES;
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------
#pragma mark NSURLConnection Methods
//------------------------------------------------------------------------------

- (void) connection:(ADNURLConnection*)connection
 didReceiveResponse:(NSURLResponse*)response
{
    // We got a response, so we start by emptying out the data. 
    [connection resetDataLength];
    
    connection.response = (NSHTTPURLResponse*)response;
}

//------------------------------------------------------------------------------

- (void) connection:(ADNURLConnection*)connection didReceiveData:(NSData*)data
{
    // Got some new data, so just append it.
    [connection appendData:data];
}

//------------------------------------------------------------------------------

- (void) connection:(ADNURLConnection*)connection 
   didFailWithError:(NSError*)error
{
    // Inform the delegate and release connection.
    [_delegate requestFailed:error forRequestUUID:connection.uuid];
    [self destroyConnection:connection];
}

//------------------------------------------------------------------------------

- (void) connectionDidFinishLoading:(ADNURLConnection*)connection
{
    // Once this method is invoked, "data" contains the complete result
    NSMutableData *data = connection.data;

    // Check status code.
    NSInteger statusCode = [[connection response] statusCode];
    if (statusCode >= 400){
        // Assume failure and report to delegate.
        
        // Convert response data to string.
        NSString *body = 
            [data length] ? [NSString stringWithUTF8String:[data bytes]] : @"";
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
            [connection response], @"response", 
            body, @"body", 
            nil];
        NSError *error = [NSError errorWithDomain:@"HTTP" 
                                             code:statusCode
                                         userInfo:info];

        // Report to delegate.
        [_delegate requestFailed:error forRequestUUID:connection.uuid];
    } else {
        [self parseDataForConnection:connection];
    }

    [self destroyConnection:connection];
}

//------------------------------------------------------------------------------

@end
