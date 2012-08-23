//
//  ADNLink.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADNLink : NSObject

// The anchor text to be linked (could be a url).
@property (retain) NSString *anchorText;

// The destination url (only http or https accepted).
@property (retain) NSURL *url;

// The 0 based index where this entity begins text.
@property NSUInteger pos;

// The length of the substring in text that represents this link.
@property NSUInteger len;

+ (id) linkFromJSONDictionary:(NSDictionary*)dict;

- (id) initWithJSONDictionary:(NSDictionary*)dict;

- (id) initWithText:(NSString*)text
                url:(NSString*)url
                pos:(NSUInteger)p
                len:(NSUInteger)l;

- (NSDictionary*) asDictionary;
- (NSString*) asJSONString;

@end
