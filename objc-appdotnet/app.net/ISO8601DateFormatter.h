/*
Copyright © 2006–2011 Peter Hosey
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of Peter Hosey nor the names of his contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import <Foundation/Foundation.h>

/*This class converts dates to and from ISO 8601 strings. A good introduction to ISO 8601: <http://www.cl.cam.ac.uk/~mgk25/iso-time.html>
 *
 *Parsing can be done strictly, or not. When you parse loosely, leading whitespace is ignored, as is anything after the date.
 *The loose parser will return an NSDate for this string: @" \t\r\n\f\t  2006-03-02!!!"
 *Leading non-whitespace will not be ignored; the string will be rejected, and nil returned. See the README that came with this addition.
 *
 *The strict parser will only accept a string if the date is the entire string. The above string would be rejected immediately, solely on these grounds.
 *Also, the loose parser provides some extensions that the strict parser doesn't.
 *For example, the standard says for "-DDD" (an ordinal date in the implied year) that the logical representation (meaning, hierarchically) would be "--DDD", but because that extra hyphen is "superfluous", it was omitted.
 *The loose parser will accept the extra hyphen; the strict parser will not.
 *A full list of these extensions is in the README file.
 */

/*The format to either expect or produce.
 *Calendar format is YYYY-MM-DD.
 *Ordinal format is YYYY-DDD, where DDD ranges from 1 to 366; for example, 2009-32 is 2009-02-01.
 *Week format is YYYY-Www-D, where ww ranges from 1 to 53 (the 'W' is literal) and D ranges from 1 to 7; for example, 2009-W05-07.
 */
enum {
	ISO8601DateFormatCalendar,
	ISO8601DateFormatOrdinal,
	ISO8601DateFormatWeek,
};
typedef NSUInteger ISO8601DateFormat;

//The default separator for time values. Currently, this is ':'.
extern unichar ISO8601DefaultTimeSeparatorCharacter;

@interface ISO8601DateFormatter: NSFormatter
{
	NSString *lastUsedFormatString;
	NSDateFormatter *unparsingFormatter;

	NSCalendar *parsingCalendar, *unparsingCalendar;

	NSTimeZone *defaultTimeZone;
	ISO8601DateFormat format;
	unichar timeSeparator;
	BOOL includeTime;
	BOOL parsesStrictly;
}

//Call this if you get a memory warning.
+ (void) purgeGlobalCaches;

@property(nonatomic, retain) NSTimeZone *defaultTimeZone;

#pragma mark Parsing

//As a formatter, this object converts strings to dates.

@property BOOL parsesStrictly;

- (NSDateComponents *) dateComponentsFromString:(NSString *)string;
- (NSDateComponents *) dateComponentsFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone;
- (NSDateComponents *) dateComponentsFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone range:(out NSRange *)outRange;

- (NSDate *) dateFromString:(NSString *)string;
- (NSDate *) dateFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone;
- (NSDate *) dateFromString:(NSString *)string timeZone:(out NSTimeZone **)outTimeZone range:(out NSRange *)outRange;

#pragma mark Unparsing

@property ISO8601DateFormat format;
@property BOOL includeTime;
@property unichar timeSeparator;

- (NSString *) stringFromDate:(NSDate *)date;
- (NSString *) stringFromDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone;

@end
