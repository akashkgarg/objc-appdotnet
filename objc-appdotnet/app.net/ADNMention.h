//
//  ADNMention.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

// Defines an App.Net mention.
@interface ADNMention : NSObject

// Username being mentioned.
@property (retain) NSString *username;

// ID of the mentioned user.
@property NSUInteger userId;

// 0-based index of of where username is mentioned, including the leading '@'
@property NSUInteger pos;

//The length of the substring in text that represents this mention. 
// Since @ is included, len will be the length of the username + 1.
@property NSUInteger len;

+ (id) mentionFromJSONDictionary:(NSDictionary*)dict;

- (id) initWithJSONDictionary:(NSDictionary*)dict;

- (id) initWithUserName:(NSString*)username
                 userId:(NSUInteger)uid
                    pos:(NSUInteger)p
                    len:(NSUInteger)l;

@end
