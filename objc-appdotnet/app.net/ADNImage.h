//
//  ADNImage.h
//  objc-appdotnet
//
//  Created by Akash Garg on 8/21/12.
//  Copyright (c) 2012 Akash Garg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADNImage : NSObject

// Height and width of the image.
@property NSUInteger height;
@property NSUInteger width;

// URL of the image.
@property (retain) NSURL *url;

+ (id) imageFromJSONDictionary:(NSDictionary*)dict;

- (id) initWithJSONDictionary:(NSDictionary*)dict;

- (id) initWithHeight:(NSUInteger)h
                width:(NSUInteger)w
                  url:(NSString*)addr;

@end
