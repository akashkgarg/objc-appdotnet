//
//  AppDotNet.m
//  obj.appdotnet
//
//  Created by Akash Garg on 8/20/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import "AppDotNet.h"
#import "JSONKit.h"
#import "ADNURLRequest.h"
#import "ADNLink.h"

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

- (NSArray*) parseUserArray:(NSArray*)jsonResp
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dict in jsonResp) {
        ADNUser *user = [ADNUser userFromJSONDictionary:dict];
        [result addObject:user];
    }
    return result;
}

//------------------------------------------------------------------------------

- (NSArray*) parsePostArray:(NSArray*)jsonResp
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dict in jsonResp) {
        ADNPost *post = [ADNPost postFromJSONDictionary:dict];
        [result addObject:post];
    }
    return result;
}

//------------------------------------------------------------------------------

- (void) processResponse:(NSDictionary*)jsonResp error:(NSError*)error 
       receivedUserBlock:(ADNReceivedUser)block
{
    if (error) {
        block(nil, error);
    } else {
        ADNUser *user = [ADNUser userFromJSONDictionary:jsonResp];
        block(user, nil);
    }
}

//------------------------------------------------------------------------------

- (void) processResponse:(NSDictionary*)jsonResp error:(NSError*)error 
       receivedPostBlock:(ADNReceivedPost)block
{
    if (error) {
        block(nil, error);
    } else {
        ADNPost *post = [ADNPost postFromJSONDictionary:jsonResp];
        block(post, nil);
    }
}

//------------------------------------------------------------------------------

- (void) processResponse:(NSArray*)jsonResp error:(NSError*)error
      receivedUsersBlock:(ADNReceivedUsers)block
{
    if (error) {
        block(nil, error);
    } else {
        NSArray *users = [self parseUserArray:jsonResp];
        block(users, nil);
    }
}

//------------------------------------------------------------------------------

- (void) processResponse:(NSArray*)jsonResp error:(NSError*)error
      receivedPostsBlock:(ADNReceivedPosts)block
{
    if (error) {
        block(nil, error);
    } else {
        NSArray *posts = [self parsePostArray:jsonResp];
        block(posts, nil);
    }
}

//------------------------------------------------------------------------------

- (void) parseADNResponse:(NSData*)data 
                    block:(void (^) (id jsonResp, NSError *err))block
{
    // First of all, check if there is an error in the response.
    NSError *error = [self parseError:data];
    if (error) {
        block(nil, error);
    } else {
        id dataObj = [[data objectFromJSONData] objectForKey:DATA_KEY];

        NSAssert(dataObj, @"No valid object!");

        block(dataObj, nil);
    }
}

//------------------------------------------------------------------------------
#pragma mark Private Helper Methods
//------------------------------------------------------------------------------

- (void) setHeader:(ADNURLRequest*)request
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

- (ADNURLRequest*) createRequest:(NSString*)uri
{
    NSString *fulluri = [NSString stringWithFormat:@"%@%@", ADN_API_URL, uri];
    NSURL *url = [NSURL URLWithString:fulluri];
    ADNURLRequest *request = [[ADNURLRequest alloc] initWithURL:url];
    [self setHeader:request];
    
    return request;
}

//------------------------------------------------------------------------------

// This will create a GET request but also sets the appropriate GET paramets
// from the dictionary of parameters given. It assumes that the keys and values
// of the given "params" dictionary are all NSString.
- (ADNURLRequest*) createRequest:(NSString*)uri params:(NSDictionary*)params
{
    NSString *paramString = @"";

    if (params)
         paramString = [self assembleParamString:params];

    NSString *fulluri = [NSString stringWithFormat:@"%@?%@", uri, paramString];

    ADNURLRequest *request = [self createRequest:fulluri];

    return request;
}

//------------------------------------------------------------------------------

// THis is like createRequest, but will set delivery type to POST and also will
// sent content of the BODY to include values in the key value pairs of the
// given dictionary. Assumes that the keys and values in the dictionary are
// strings. 
- (ADNURLRequest*) createPostRequest:(NSString*)uri params:(NSDictionary*)params
{
    ADNURLRequest *request = [self createRequest:uri];

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

- (ADNURLRequest*) createDeleteRequest:(NSString*)uri
{
    ADNURLRequest *request = [self createRequest:uri];
    
    [request setHTTPMethod:@"DELETE"];
    
    return request;
}

//------------------------------------------------------------------------------

- (void) sendRequest:(ADNURLRequest*)request 
               block:(void (^)(id jsonResp, NSError *err))block
{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, 
                                               NSData *data, 
                                               NSError *error) {
        NSHTTPURLResponse *httpresp = (NSHTTPURLResponse*)response;
        // Check if we have an error
        if (error) {
            block(nil, error);
        } else {
            NSInteger statusCode = [httpresp statusCode];
            if (statusCode >= 400) {
                // Assume failure and report to user.

                // Convert data response into string.
                NSString *body = [data length] ?                
                                 [NSString stringWithUTF8String:[data bytes]] : 
                                 @"";
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setObject:httpresp forKey:@"response"];
                [info setObject:body forKey:MESSAGE_KEY];

                NSError *error = [NSError errorWithDomain:@"HTTP"
                                                     code:statusCode
                                                 userInfo:info];
                block(nil, error);
            } else {
                // parse the response and call the completion block from
                // parsing method.
                [self parseADNResponse:data block:block];
            }
        }
    }];
}

//------------------------------------------------------------------------------

- (AppDotNet*) initWithAccessToken:(NSString*)token
{
    self = [super init];
    _accessToken = [token retain];
    return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
    [_accessToken release];
    [_clientVersion release];
    [_clientName release];
    
    [super dealloc];
}

//------------------------------------------------------------------------------
#pragma mark API Methods
//------------------------------------------------------------------------------

- (void) checkCurrentTokenWithBlock:(ADNReceivedScopeAndUser)block
{
    ADNURLRequest *request = [self createRequest:@"/stream/0/token"];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *err) {
        if (err) {
            block(nil, nil, err);
        } else {
            NSDictionary *userDict = [jsonResp objectForKey:USER_KEY];
            ADNUser *user = [ADNUser userFromJSONDictionary:userDict];

            block(nil, user, nil);
        }
    }];
}

//------------------------------------------------------------------------------

- (void) userWithUsername:(NSString*)username block:(ADNReceivedUser)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@", username];
    ADNURLRequest *request =[self createRequest:uri];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedUserBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) userWithID:(NSUInteger)uid block:(ADNReceivedUser)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self userWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) meWithBlock:(ADNReceivedUser)block
{
    [self userWithUsername:MY_USERID block:block];
}

//------------------------------------------------------------------------------

- (void) followUserWithUsername:(NSString*)username
                               block:(ADNReceivedUser)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/follow", username];

    ADNURLRequest *request = [self createPostRequest:uri params:nil];
    
    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *err) {
        [self processResponse:jsonResp error:err receivedUserBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) followUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self followUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) unfollowUserWithUsername:(NSString*)username 
                            block:(ADNReceivedUser)block
{
    NSString *uri =
        [NSString stringWithFormat:@"/stream/0/users/%@/follow", username];
    
    ADNURLRequest *request = [self createDeleteRequest:uri];
    
    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *err) {
        [self processResponse:jsonResp error:err receivedUserBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) unfollowUserWithID:(NSUInteger)uid 
                      block:(ADNReceivedUser)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self unfollowUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) followedByUsername:(NSString*)username
                      block:(ADNReceivedUsers)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/following", username];
    
    ADNURLRequest *request = [self createRequest:uri];
    
    [self sendRequest:request block:^(NSArray *jsonResp, NSError *err) {
        [self processResponse:jsonResp error:err receivedUsersBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) followedByID:(NSUInteger)uid
                block:(ADNReceivedUsers)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self followedByUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) followedByMeWithBlock:(ADNReceivedUsers)block
{
    return [self followedByUsername:MY_USERID block:block];
}

//------------------------------------------------------------------------------

- (void) followersOfUsername:(NSString*)username
                       block:(ADNReceivedUsers)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/followers", username];
    
    ADNURLRequest *request = [self createRequest:uri];
    
    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedUsersBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) followersOfID:(NSUInteger)uid
                 block:(ADNReceivedUsers)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self followersOfUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) followersOfMeWithBlock:(ADNReceivedUsers)block
{
    [self followersOfUsername:MY_USERID block:block];
}

//------------------------------------------------------------------------------

- (void) muteUserWithUsername:(NSString*)username
                        block:(ADNReceivedUser)block
{
    NSString *uri =
        [NSString stringWithFormat:@"/stream/0/users/%@/mute", username];
    
    ADNURLRequest *request = [self createPostRequest:uri params:nil];
    
    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedUserBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) muteUserWithID:(NSUInteger)uid
                  block:(ADNReceivedUser)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self muteUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) unmuteUserWithUsername:(NSString *)username
                          block:(ADNReceivedUser)block
{
    NSString *uri =
    [NSString stringWithFormat:@"/stream/0/users/%@/mute", username];
    
    ADNURLRequest *request = [self createDeleteRequest:uri];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedUserBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) unmuteUserWithID:(NSUInteger)uid block:(ADNReceivedUser)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self muteUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) writePost:(NSString*)text
 replyToPostWithID:(NSInteger)postId
       annotations:(NSDictionary*)annotations
             links:(NSArray*)links
             block:(ADNReceivedPost)block
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

    ADNURLRequest *request = [self createPostRequest:uri params:postValues];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) postWithID:(NSUInteger)postId
              block:(ADNReceivedPost)block
{
    NSString *uri = [NSString stringWithFormat:@"/stream/0/posts/%ld", postId];

    ADNURLRequest *request = [self createRequest:uri];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) deletePostWithID:(NSUInteger)postId
                    block:(ADNReceivedPost)block
{
    NSString *uri = [NSString stringWithFormat:@"/stream/0/posts/%ld", postId];

    ADNURLRequest *request = [self createDeleteRequest:uri];

    [self sendRequest:request block:^(NSDictionary *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) repliesToPostWithID:(NSUInteger)postId
                       block:(ADNReceivedPosts)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/posts/%ld/replies", postId];

    ADNURLRequest *request = [self createRequest:uri];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) postsByUserWithUsername:(NSString*)username
                           block:(ADNReceivedPosts)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/posts/", username];

    ADNURLRequest *request = [self createRequest:uri];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) postsByUserWithID:(NSUInteger)uid
                     block:(ADNReceivedPosts)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self postsByUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) postsByMeWithBlock:(ADNReceivedPosts)block
{
    [self postsByUserWithUsername:MY_USERID block:block];
}

//------------------------------------------------------------------------------

- (void) postsMentioningUserWithUsername:(NSString*)username
                                   block:(ADNReceivedPosts)block
{
    NSString *uri = 
        [NSString stringWithFormat:@"/stream/0/users/%@/mentions", username];

    ADNURLRequest *request = [self createRequest:uri];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) postsMentioningUserWithID:(NSUInteger)uid
                             block:(ADNReceivedPosts)block
{
    NSString *str = [NSString stringWithFormat:@"%ld", uid];
    [self postsMentioningUserWithUsername:str block:block];
}

//------------------------------------------------------------------------------

- (void) postsMentioningMeWithBlock:(ADNReceivedPosts)block;
{
    return [self postsMentioningUserWithUsername:MY_USERID block:block];
}

//------------------------------------------------------------------------------

- (void) mutedUsersWithBlock:(ADNReceivedUsers)block
{
    NSString *uri = @"/stream/0/users/me/muted";
    ADNURLRequest *request = [self createRequest:uri];
    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedUsersBlock:block];
    }];
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

- (void) myStreamSinceID:(NSInteger)sinceId 
                beforeID:(NSInteger)beforeId 
                   count:(NSUInteger)count 
             includeUser:(BOOL)includeUser 
      includeAnnotations:(BOOL)includeAnnotations 
          includeReplies:(BOOL)includeReplies
                   block:(ADNReceivedPosts)block
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
    ADNURLRequest *request = [self createRequest:uri params:params];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) globalStreamSinceID:(NSInteger)sinceId 
                    beforeID:(NSInteger)beforeId 
                       count:(NSUInteger)count 
                 includeUser:(BOOL)includeUser 
          includeAnnotations:(BOOL)includeAnnotations 
              includeReplies:(BOOL)includeReplies
                       block:(ADNReceivedPosts)block
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
    ADNURLRequest *request = [self createRequest:uri params:params];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

- (void) taggedPostsWithTag:(NSString*)tag 
                    sinceID:(NSInteger)sinceId 
                   beforeID:(NSInteger)beforeId 
                      count:(NSUInteger)count 
                includeUser:(BOOL)includeUser 
         includeAnnotations:(BOOL)includeAnnotations 
             includeReplies:(BOOL)includeReplies
                      block:(ADNReceivedPosts)block
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
    ADNURLRequest *request = [self createRequest:uri params:params];

    [self sendRequest:request block:^(NSArray *jsonResp, NSError *error) {
        [self processResponse:jsonResp error:error receivedPostsBlock:block];
    }];
}

//------------------------------------------------------------------------------

@end
