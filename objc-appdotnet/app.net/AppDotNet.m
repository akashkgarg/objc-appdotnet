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
#import "ADNLink.h"
#import "ADNPost.h"
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

- (void) parsePost:(NSDictionary*)postDict reportWithID:(NSString*)uuid
{
    // create the post
    ADNPost *post = [ADNPost postFromJSONDictionary:postDict];

    // report to delegate.
    [_delegate receivedPost:post forRequestUUID:uuid];
}

//------------------------------------------------------------------------------

- (void) parseArray:(NSArray*)array 
       responseType:(NSUInteger)responseType
       reportWithID:(NSString*)uuid
{
    NSMutableArray *result = [NSMutableArray array];

    // List is all users.
    if (responseType & IS_USER) {
        for (NSDictionary *dict in array) {
            ADNUser *user = [ADNUser userFromJSONDictionary:dict];
            [result addObject:user];
        }
        // report to delegate.
        [_delegate receivedUsers:result forRequestUUID:uuid];
    }

    // List is all posts.
    if (responseType & IS_POST) {
        for (NSDictionary *dict in array) {
            ADNPost *post = [ADNPost postFromJSONDictionary:dict];
            [result addObject:post];
        }
        // report to delegate.
        [_delegate receivedPosts:result forRequestUUID:uuid];
    }
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
        } else if (responseType & IS_POST) {
            // parse post and report.
            [self parsePost:dataDict reportWithID:uuid];
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

// Assembles the key-value pairs for the given params dictionary in a format
// suitable for making GET/POST calls. Assumes that all keys adn values in
// params are NSString.
- (NSString*) assembleParamString:(NSDictionary*)params
{
    // Create the content string by iterating over the params dictionary. 
    NSMutableArray *postStrings = [NSMutableArray array];
    for (NSString *key in params) {
        NSString *value = [params objectForKey:key];
        NSString *postvalue = [NSString stringWithFormat:@"%@=%@", key, value];
        [postStrings addObject:postvalue];
    }
    NSString *postString = 
        [(NSArray*)postStrings componentsJoinedByString:@"&"];

    return postString;
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

// This will create a GET request but also sets the appropriate GET paramets
// from the dictionary of parameters given. It assumes that the keys and values
// of the given "params" dictionary are all NSString.
- (NSMutableURLRequest*) createRequest:(NSString*)uri 
                                params:(NSDictionary*)params
{
    NSString *paramString = @"";

    if (params)
         paramString = [self assembleParamString:params];

    NSString *fulluri = [NSString stringWithFormat:@"%@?%@", uri, paramString];

    NSMutableURLRequest *request = [self createRequest:fulluri];

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

    // Get the params in a suitable format.
    NSString *postString = [self assembleParamString:params];
    
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

- (NSString*) writePost:(NSString*)text
      replyToPostWithID:(NSInteger)postId
            annotations:(NSDictionary*)annotations
                  links:(NSArray*)links
{
    NSString *uri = @"/stream/0/posts";

    NSMutableDictionary *postValues = [NSMutableDictionary dictionary];
    if (postId >= 0) {
        NSString *replyToStr = [NSString stringWithFormat:@"%ld", postId];
        [postValues setObject:replyToStr forKey:REPLY_TO_KEY];
    }

    if (annotations) {
        NSString *str = [annotations JSONString];
        [postValues setObject:str forKey:ANNOTATIONS_KEY];
    }

    if (links) {
        NSMutableArray *linkDicts = [NSMutableArray array];
        for (ADNLink *link in links) {
            [linkDicts addObject:[link asDictionary]];
        }
        [postValues setObject:[linkDicts JSONString] forKey:LINKS_KEY];
    }
    
    [postValues setObject:text forKey:TEXT_KEY];

    NSMutableURLRequest *request = [self createPostRequest:uri 
                                                    params:postValues];

    enum ADNResponseType responseType = DICT | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) postWithID:(NSUInteger)postId
{
    NSString *uri = [NSString stringWithFormat:@"/stream/0/posts/%ld", postId];

    NSMutableURLRequest *request = [self createRequest:uri];

    enum ADNResponseType responseType = DICT | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) deletePostWithID:(NSUInteger)postId
{
    NSString *uri = [NSString stringWithFormat:@"/stream/0/posts/%ld", postId];

    NSMutableURLRequest *request = [self createDeleteRequest:uri];

    enum ADNResponseType responseType = DICT | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) repliesToPostWithID:(NSUInteger)postId
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/posts/%ld/replies", postId];

    NSMutableURLRequest *request = [self createRequest:uri];

    enum ADNResponseType responseType = LIST | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) postsByUserWithUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/posts/", username];

    NSMutableURLRequest *request = [self createRequest:uri];

    enum ADNResponseType responseType = LIST | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) postsByUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self postsByUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) postsByMe
{
    return [self postsByUserWithUsername:MY_USERID];
}

//------------------------------------------------------------------------------

- (NSString*) postsMentioningUserWithUsername:(NSString*)username
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/mentions", username];

    NSMutableURLRequest *request = [self createRequest:uri];

    enum ADNResponseType responseType = LIST | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) postsMentioningUserWithID:(NSUInteger)uid
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    return [self postsMentioningUserWithUsername:str];
}

//------------------------------------------------------------------------------

- (NSString*) postsMentioningMe
{
    return [self postsMentioningUserWithUsername:MY_USERID];
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

- (NSDictionary*) postParamsSinceID:(NSInteger)sinceId
                           beforeID:(NSInteger)beforeId 
                              count:(NSUInteger)count 
                        includeUser:(BOOL)includeUser 
                 includeAnnotations:(BOOL)includeAnnotations 
                     includeReplies:(BOOL)includeReplies
{
    // Create params dictionary.
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    if (sinceId >= 0) {
        NSString *str = [NSString stringWithFormat:@"%ld", sinceId];
        [params setObject:str forKey:SINCE_ID_KEY];
    }
    if (beforeId >= 0) {
        NSString *str = [NSString stringWithFormat:@"%ld", beforeId];
        [params setObject:str forKey:BEFORE_ID_KEY];
    }

    NSString *countStr = [NSString stringWithFormat:@"%ld", count];
    [params setObject:countStr forKey:COUNT_KEY];

    NSString *includeUserStr = NSStringFromBOOL(includeUser);
    NSString *includeAnnotationsStr = NSStringFromBOOL(includeAnnotations);
    NSString *includeRepliesStr = NSStringFromBOOL(includeReplies);

    [params setObject:includeUserStr forKey:INCLUDE_USER_KEY];
    [params setObject:includeAnnotationsStr forKey:INCLUDE_ANNOTATIONS_KEY];
    [params setObject:includeRepliesStr forKey:INCLUDE_REPLIES_KEY];

    return params;
}

//------------------------------------------------------------------------------

- (NSString*) myStreamSinceID:(NSInteger)sinceId 
                     beforeID:(NSInteger)beforeId
                        count:(NSUInteger)count
                  includeUser:(BOOL)includeUser 
           includeAnnotations:(BOOL)includeAnnotations
               includeReplies:(BOOL)includeReplies
{
    NSString *uri = @"/stream/0/posts/stream";

    // Create the dictionary of parameters
    NSDictionary *params = [self postParamsSinceID:sinceId
                                          beforeID:beforeId
                                             count:count
                                       includeUser:includeUser
                                includeAnnotations:includeAnnotations
                                    includeReplies:includeReplies];

    // Create the Get request with parameters.
    NSMutableURLRequest *request = [self createRequest:uri params:params];

    enum ADNResponseType responseType = LIST | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) globalStreamSinceID:(NSInteger)sinceId 
                         beforeID:(NSInteger)beforeId 
                            count:(NSUInteger)count 
                      includeUser:(BOOL)includeUser 
               includeAnnotations:(BOOL)includeAnnotations 
                   includeReplies:(BOOL)includeReplies
{
    NSString *uri = @"/stream/0/posts/stream/global";

    // Create the dictionary of parameters
    NSDictionary *params = [self postParamsSinceID:sinceId
                                          beforeID:beforeId
                                             count:count
                                       includeUser:includeUser
                                includeAnnotations:includeAnnotations
                                    includeReplies:includeReplies];

    // Create the Get request with parameters.
    NSMutableURLRequest *request = [self createRequest:uri params:params];

    enum ADNResponseType responseType = LIST | IS_POST;

    return [self sendRequest:request responseType:responseType];
}

//------------------------------------------------------------------------------

- (NSString*) taggedPostsWithTag:(NSString*)tag
                         sinceID:(NSInteger)sinceId 
                        beforeID:(NSInteger)beforeId 
                           count:(NSUInteger)count 
                     includeUser:(BOOL)includeUser 
              includeAnnotations:(BOOL)includeAnnotations 
                  includeReplies:(BOOL)includeReplies
{
    NSString *uri = [NSString stringWithFormat:@"/stream/0/posts/tag/%@", tag];

    // Create the dictionary of parameters
    NSDictionary *params = [self postParamsSinceID:sinceId
                                          beforeID:beforeId
                                             count:count
                                       includeUser:includeUser
                                includeAnnotations:includeAnnotations
                                    includeReplies:includeReplies];

    // Create the Get request with parameters.
    NSMutableURLRequest *request = [self createRequest:uri params:params];

    enum ADNResponseType responseType = LIST | IS_POST;

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
