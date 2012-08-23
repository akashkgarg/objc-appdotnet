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
project's source. 

The main API entry-point to access the App.Net API is the `AppDotNet` object.
An example of usage is shown in AppDelegate.m of the included project. 

`
AppDotNet *engine = [[AppDotNet alloc] initWithDelegate:self accessToken:token];

[engine checkCurrentToken];
[engine getUserWithUsername:@"@terhechte"];

[engine followUserWithUsername:@"@terhechte"];
[engine unfollowUserWithID:6581];

[engine followedByMe];
[engine followedByUsername:@"@terhechte"];

[engine followersOfMe];
[engine followersOfUsername:@"@akg"];

[engine muteUserWithUsername:@"@terhechte"];
[engine unmuteUserWithUsername:@"@terhechte"];
[engine unmuteUserWithUsername:@"@spacekatgal"];

[engine mutedUsers];

[engine writePost:@"HELLLO WORLD!" 
        replyToPostWithID:-1 annotations:nil links:nil];

[engine postsByMe];

[engine postsMentioningMe];

[engine myStreamSinceID:152000 beforeID:-1 
    count:10 includeUser:NO includeAnnotations:NO includeReplies:NO];

[engine globalStreamSinceID:-1 beforeID:-1 
    count:10 includeUser:NO includeAnnotations:NO includeReplies:NO];

[engine taggedPostsWithTag:@"gamedev" sinceID:-1 beforeID:-1 
    count:20 includeUser:NO includeAnnotations:NO includeReplies:NO]; 
`

*NOTE*: You initialize the main AppDotNet interface with an access token for
your app and a delegate. The delegate is used for callbacks, see the "Client
Delegate Callbacks" section below. The access token is received after proper
OAuth2 authentication of your app, see "Authentication" section below.

### Authentication

App.Net uses standard OAuth2 for authentication. This library does not provide
functions to do authentication via OAuth2. There are plenty of other libraries
that are better suited for this: 

    - [OAuth2Client](https://github.com/nxtbgthng/OAuth2Client)
    - [OAConsumer](http://code.google.com/p/oauthconsumer/)

You may use the any standard OAuth2 authentication method. All that is required
for objc-appdotnet is the access token you receive. 

### Client Delegate Callbacks

All API calls are notified asynchronously to the client using delegate
callbacks. Your client must implement the ADNDelegate protocol, which contains
specific callback functions when objects are received from App.Net API calls. 

Each call to the `AppDotNet` object will make underlying calls to the App.Net
REST API. Each call can make multiple callbacks for example if an API call
returns both a `User` and a `Post`, then both `receivedUser:withRequestUUID`
and `receivedPost:withRequestUUID:` delegate methods are called giving you the
`User` and `Post` objects respectively. 

Since all calls are asynchronous, each call to `AppDotNet` will return a unique
identifier as an `NSString*`. This can be used by the client application to
keep track of which delegate callbacks correspond to which API calls. Each
delegate callback contains a `withRequestUUID` parameter, which contains the
unique identifier corresponding to that API call. 

### Error Handling

If there is an error with the API request, the delegate method
`requestFailed:forRequestUUID` is called. This contains an `NSError` object.
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

Please let me know if you find any bugs/issues while using this library. I'd be
more than happy to hear from you. 

## Author

Akash Garg
@akg via app.net
akg2110@columbia.edu via email

## License

Use it however you like whereever you like. If you do end up using it in an
application, I would love to hear from you. 
