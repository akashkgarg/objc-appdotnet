# objc-appdotnet

A clean, object-oriented API binding for the App.Net API written in Objective-C. 

## Description

objc-appdotnet is a completely asynhronous Objective-C library that simplifies
communicating with the App.Net API in on object oriented manner. All parsing of
JSON data is done for you and encompassed in Objective-C classes that can be
readily used in your applications. 

## Usage

To use in your own projects, you will need everything inside the "app.net"
folder. That folder contains all App.Net objects as well as the main API
interface. JSON parsing is done using JSONKit, which is also included in the
project's source. I will soon replace this NSJSONSerialization, but for now
still using JSONKit. 

The main API entry-point to access the App.Net API is the `AppDotNet` object.
An example of usage is shown in AppDelegate.m of the included project. 

    AppDotNet *engine = [[AppDotNet alloc] initWithAccessToken:token];

    [engine checkCurrentTokenWithBlock:^(ADNScope *scope, ADNUser *user, NSError *e) {
        if (e) {
            [self requestFailed:e];
        } else {
            [self receivedUser:user];
        }
    }];
  
    [engine userWithID:6581 block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
        
    }];
  
    [engine userWithUsername:@"blablah" block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
        
    }];
  
    [engine followUserWithID:6581 block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
  
    [engine unfollowUserWithID:6581 block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
    
    [engine followedByMeWithBlock:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
    
    [engine followedByUsername:@"@terhechte" block:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
    
    [engine followedByUsername:@"doesntexistthisuser" block:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
  
  
    [engine followersOfMeWithBlock:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
    
    [engine followersOfUsername:@"@akg" block:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
  
  
    [engine muteUserWithUsername:@"@terhechte" block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
    
    [engine muteUserWithUsername:@"@spacekatgal" block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
  
    [engine mutedUsersWithBlock:^(NSArray *users, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUsers:users];
        }
    }];
    
    [engine unmuteUserWithUsername:@"@terhechte" block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
    
    [engine unmuteUserWithUsername:@"@spacekatgal" block:^(ADNUser *user, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedUser:user];
        }
    }];
  
    [engine writePost:@"HELLO WORLD! #testing" replyToPostWithID:-1 annotations:nil links:nil block:^(ADNPost *post, NSError *error) {
        if (error) {
            [self requestFailed:error];
        } else {
            [self receivedPost:post];
        }
    }];
  
    [engine postWithID:50 block:^(ADNPost *post, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPost:post];
    }];
    
    [engine deletePostWithID:50 block:^(ADNPost *post, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPost:post];
    }];
  
    [engine repliesToPostWithID:121511 block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
    
    [engine repliesToPostWithID:50 block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
  
    [engine postsByMeWithBlock:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
    
    [engine postsMentioningMeWithBlock:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
  
    [engine myStreamSinceID:152000 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];
  
    [engine globalStreamSinceID:-1 beforeID:-1 count:10 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];

    [engine taggedPostsWithTag:@"gamedev" sinceID:-1 beforeID:-1 count:20 includeUser:NO includeAnnotations:NO includeReplies:NO block:^(NSArray *posts, NSError *error) {
        if (error)
            [self requestFailed:error];
        else
            [self receivedPosts:posts];
    }];


*NOTE*: You initialize the main AppDotNet interface with an access token for
your app. The responses from the App.Net API are then returned to you via the
blocks that are passed into each API call. The access token is received after proper OAuth2 authentication of your app, see "Authentication" section below.

### Authentication

App.Net uses standard OAuth2 for authentication. This library does not provide
functions to do authentication via OAuth2. There are plenty of other libraries
that are better suited for this: 

- [OAuth2Client](https://github.com/nxtbgthng/OAuth2Client)
- [OAConsumer](http://code.google.com/p/oauthconsumer/)

You may use the any standard OAuth2 authentication method. All that is required
for objc-appdotnet is the access token you receive. 

### Error Handling

If there is an error with the API request, each call's block parameter "error"
will be not nil. The error object is an instance of `NSError` class. 
The error will either be an "HTTP" error or an error within the ADN API. Error
type is indicated by the domain string "HTTP" or "ADN". Status code of error is
also encoded in the `NSError` object. See the `AppDelegate.m` implementation
for an example on how to handle errors. 

Currently there is very little error checking done during the JSON parsing so
if things are not properly formatted, it's likely that the app will crash. 

## Known Limitations & Bugs

- Currently only App.Net's token, user, and posts API are supported.
- Annotations and Links are not currently working when writing posts using the
  `writePost` method.
- The `includeUser`, `includeAnnotations`, and `includeReplies` flags for
  stream methods do not work. 
- Latest App.Net changes include responses that contain a "meta" value. This
  information is ignored currently.
- Using JSONKit for JSON parsing instead of NSJSONSerialization

Please let me know if you find any bugs/issues while using this library. I'd be
more than happy to hear from you. 

## Author

Akash Garg
- @akg via app.net
- akg2110@columbia.edu via email

## License

Use it however you like whereever you like. If you do end up using it in an
application, I would love to hear from you. 
