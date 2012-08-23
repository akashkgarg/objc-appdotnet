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

- (NSError*) parseError:(NSData*)data
{
    NSDictionary *dict = [data objectFromJSONData];
    if (!dict) return nil;
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    NSDictionary *errDict = [dict objectForKey:ERROR_KEY];
    if (!errDict) return nil;
    if (![errDict isKindOfClass:[NSArray class]]) return nil;
    
    NSUInteger errCode = [[errDict objectForKey:CODE_KEY] intValue];
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObjectsAndKeys:
                             [errDict objectForKey:MESSAGE_KEY], @"message", 
                             nil];
    
    return [NSError errorWithDomain:@"ADN" code:errCode userInfo:userInfo];
}

//------------------------------------------------------------------------------

- (void) parseUser:(NSDictionary*)userdict reportWithID:(NSString*)uuid
{
    // Create the user
    ADNUser *user = [ADNUser userFromJSONDictionary:userdict];

    // report to delegate.
    [_delegate receivedUser:user forRequestUUID:uuid];
}

//------------------------------------------------------------------------------

- (void) parseArray:(NSArray*)array 
       responseType:(NSUInteger)responseType
       reportWithID:(NSString*)uuid
{
    NSMutableArray *result = [NSMutableArray array];

    for (id obj in array) {
        if (responseType & IS_USER) {
            NSDictionary *dict = (NSDictionary*)obj;
            ADNUser *user = [ADNUser userFromJSONDictionary:dict];
            [result addObject:user];
        }
    }

    // report to delegate.
    [_delegate receivedUsers:result forRequestUUID:uuid];
}

//------------------------------------------------------------------------------

- (void) parseDataForConnection:(ADNURLConnection*)connection
{
    NSData *data = connection.data;
    NSUInteger responseType = (NSUInteger)connection.responseType;
    NSString *uuid = connection.uuid;
    
    // First of all, check if there is an error in the response.
    NSError *error = [self parseError:data];
    if (error) {
        // Inform delegate and finish processing.
        [_delegate requestFailed:error forRequestUUID:uuid];
        return;
    }

    if (responseType & DICT) {
        NSDictionary *dataDict = [data objectFromJSONData];

        NSAssert(dataDict, @"No valid dictionary");

        if (responseType & HAS_USER) {
            NSDictionary *userDict = [dataDict objectForKey:USER_KEY];
            NSAssert(userDict, @"No valid dictionary for user");
            // parse the user and report to delegate.
            [self parseUser:userDict reportWithID:uuid];
        } else if (responseType & IS_USER) {
            // parse the user and report to delegate.
            [self parseUser:dataDict reportWithID:uuid];
        }
    } else if (responseType & LIST) {
        NSArray *array = [data objectFromJSONData];
        [self parseArray:array responseType:responseType reportWithID:uuid];
    }
    
    // TODO: Handle parsing HAS_SCOPES return type.
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

// THis is like createRequest, but will set delivery type to POST and also will
// sent content of the BODY to include values in the key value pairs of the
// given dictionary. Assumes that the keys and values in the dictionary are
// strings. 
- (NSMutableURLRequest*) createPostRequest:(NSString*)uri 
                                    params:(NSDictionary*)params
{
    NSMutableURLRequest *request = [self createRequest:uri];

    [request setHTTPMethod:@"POST"];
    
    // No need to assemble the POST content in the body.
    if (!params) return request;
    
    // Create the POST content string by iterative over the params dictionary. 
    NSMutableArray *postStrings = [NSMutableArray array];
    for (NSString *key in params) {
        NSString *value = [params objectForKey:key];
        NSString *postvalue = [NSString stringWithFormat:@"%@=%@", key, value];
        [postStrings addObject:postvalue];
    }
    NSString *postString = [(NSArray*)postStrings componentsJoinedByString:@"&"];
    
    // Set the POST body. 
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

//------------------------------------------------------------------------------

- (NSMutableURLRequest*) createDeleteRequest:(NSString*)uri
{
    NSMutableURLRequest *request = [self createRequest:uri];
    
    [request setHTTPMethod:@"DELETE"];
    
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
    enum ADNResponseType responseType = DICT | HAS_USER | HAS_SCOPES;
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) getUserWithUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@", username];
    NSMutableURLRequest *request = [self createRequest:uri];
    
    enum ADNResponseType responseType = DICT | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) getUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self getUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) getMe
{
    return [self getUserWithUsername:MY_USERID];
}

//------------------------------------------------------------------------------

- (NSString*) followUserWithUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/follow", username];

    NSMutableURLRequest *request = [self createPostRequest:uri params:nil];
    
    enum ADNResponseType responseType = DICT | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) followUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self followUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) unfollowUserWithUsername:(NSString*)username
{
    NSString *uri =
        [NSString stringWithFormat:@"/stream/0/users/%@/follow", username];
    
    NSMutableURLRequest *request = [self createDeleteRequest:uri];
    
    enum ADNResponseType responseType = DICT | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) unfollowUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self unfollowUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) followedByUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/following", username];
    
    NSMutableURLRequest *request = [self createRequest:uri];
    
    enum ADNResponseType responseType = LIST | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) followedByID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self followedByUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) followedByMe
{
    return [self followedByUsername:MY_USERID];
}

//------------------------------------------------------------------------------

- (NSString*) followersOfUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/followers", username];
    
    NSMutableURLRequest *request = [self createRequest:uri];
    
    enum ADNResponseType responseType = LIST | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) followersOfID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self followersOfUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) followersOfMe
{
    return [self followersOfUsername:MY_USERID];
}

//------------------------------------------------------------------------------

- (NSString*) muteUserWithUsername:(NSString *)username
{
    NSString *uri =
        [NSString stringWithFormat:@"/stream/0/users/%@/mute", username];
    
    NSMutableURLRequest *request = [self createPostRequest:uri params:nil];
    
    enum ADNResponseType responseType = DICT | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) muteUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self muteUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) unmuteUserWithUsername:(NSString *)username
{
    NSString *uri =
    [NSString stringWithFormat:@"/stream/0/users/%@/mute", username];
    
    NSMutableURLRequest *request = [self createDeleteRequest:uri];
    
    enum ADNResponseType responseType = DICT | IS_USER;
    
    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) unmuteUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self muteUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) mutedUsers
{
    NSString *uri = @"/stream/0/users/me/muted";
    NSMutableURLRequest *request = [self createRequest:uri];
    enum ADNResponseType responseType = LIST | IS_USER;
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
