//
//  ADNHashTag.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADNHashTag : NSObject

// The text of the hashtag (not including #).
@property (retain) NSString *tag;

// The 0 based index where this entity begins text (include #).
@property NSUInteger pos;

// The length of the substring in text that represents this hashtag. Since # is 
// included, len will be the length of the name + 1.
@property NSUInteger len;

+ (id) hashtagFromJSONDictionary:(NSDictionary*)dict;

- (id) initWithJSONDictionary:(NSDictionary*)dict;

- (id) initWithTag:(NSString*)tag
               pos:(NSUInteger)p
               len:(NSUInteger)l;

@end
