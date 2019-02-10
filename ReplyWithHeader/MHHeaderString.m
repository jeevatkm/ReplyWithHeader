/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2019 Jeevanandam M.
 *               2012, 2013 Jason Schroth
 *               2010, 2011 Saptarshi Guha
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//
//  MHHeaderString.m
//  MailHeader
//
//  Created by Jason Schroth on 8/15/12.
//
//  MHHeaderString Class refactored & completely rewritten by Jeevanandam M. on Sep 22, 2013

#import <WebKit/WebArchive.h>

#import "MHHeaderString.h"
//#import "NSMutableAttributedString+MailHeader.h"
#import "NSAttributedString+MailAttributedStringToHTML.h"
#import "NSString+MailHeader.h"

@interface MHHeaderString (MHNoImplementation)
- (id)originalMessageHeaders;
- (id)allHeaderKeys;
- (id)headersForKey:(NSString *)key;
- (id)addressListForKey:(NSString *)key;
- (id)messageIDListForKey:(NSString *)key;
- (NSMutableAttributedString *)attributedStringShowingHeaderDetailLevel:(id)level;
@end

#pragma mark Constants and global variables

NSString *MH_QUOTED_EMAIL_REGEX_STRING = @"\\s<([a-zA-Z0-9_@\\.\\-]*)>,?";

@implementation MHHeaderString

#pragma mark Class instance methods

- (void)applyHeaderTypography
{
    if (noHeaders) {
        return;
    }
    
    NSString *fontString = GET_DEFAULT_VALUE(MHHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(MHHeaderFontSize);
    NSFont *font = [NSFont fontWithName:fontString size:fontSize.floatValue];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData:GET_DEFAULT_DATA(MHHeaderColor)];
    
    if( !GET_DEFAULT_BOOL(MHTypographyEnabled) )
    {
        font = [NSFont fontWithName:@"Helvetica" size:13.0];
        color = [NSColor blackColor];
    }
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setLineSpacing:0];
    [paraStyle setMaximumLineHeight:15.0];
    [paraStyle setParagraphSpacing:0.0];
    [paraStyle setParagraphSpacingBefore:-1.3];
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        [row addAttributes:@{ NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:paraStyle } range:NSMakeRange(0, [row length])];
  
        NSRange range = [[row string] rangeOf:@":" byLocale:choosenLocale];
        if (range.location != NSNotFound)
        {
            [row applyFontTraits:NSBoldFontMask range:NSMakeRange(0, range.location + 1)];
        }
    }
    
    // for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/85
    if (GET_DEFAULT_BOOL(MHRawHeadersEnabled))
    {
        for (int i=0; i<[allHeaders count]; i++)
        {
            NSMutableAttributedString *row = [allHeaders objectAtIndex:i];
            
            [row addAttributes:@{ NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:paraStyle } range:NSMakeRange(0, [row length])];
            
            NSRange range = [[row string] rangeOf:@":" byLocale:choosenLocale];
            if (range.location != NSNotFound)
            {
                [row applyFontTraits:NSBoldFontMask range:NSMakeRange(0, range.location + 1)];
            }
        }
    }
}

// for issue #28 - https://github.com/jeevatkm/ReplyWithHeader/issues/28
- (void)applyChoosenLanguageLabels
{
    NSArray *choosenHeaderLabels = [MailHeader getConfigValue:@"AllowedHeaders"
                                                 languageCode:choosenLocaleIdentifier];
    MHLog(@"Choosen language header labels %@", choosenHeaderLabels);
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        NSRange range = [[row string] rangeOf:@":"];
        
        [row replaceCharactersInRange:NSMakeRange(0, range.location)
                           withString:[choosenHeaderLabels objectAtIndex:i]];
    }
}

- (WebArchive *)getWebArchive
{
    // MHLog(@"final header values before web archiving %@", finalHeader);
    
    NSMutableAttributedString *finalHeader = [self getFinalHeader];    
    WebArchive *webarch = [finalHeader
                           webArchiveForRange:NSMakeRange(0, [finalHeader length])
                           fixUpNewlines:YES];
    
    return webarch;
}

// for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/90
- (NSString *)getHTML
{
    // MHLog(@"final header values before web archiving %@", finalHeader);
    
    NSString *htmlStr = [NSString ToHTML:[self getFinalHeader]];
    MHLog(@"HTML String: %@", htmlStr);
    
    return htmlStr;
}

- (NSUInteger)getHeaderItemCount
{
    MHLog(@"Mail header count is %d", noOfHeaderLabels);
    
    return (noOfHeaderLabels - 1);
}

// For now it does outlook mail label ordering
- (void)applyHeaderLabelOptions
{
    if (noHeaders) {
        return;
    }
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier]) {
        [self applyChoosenLanguageLabels];
    }
    
    [self applyFromAttibutionStyle];
    [self applyToCcAttibutionStyle];
    [self applySubjectAttibutionStyle];
    [self applyDateAttibutionStyle];
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( [MailHeader isLocaleSupported] ) {
        int headerLblSeqStyle = GET_DEFAULT_INT(MHHeaderAttributionLblSeqTagStyle);
        MHLog(@"Mail Header Label and sequence mode: %d", headerLblSeqStyle);
        
        if (headerLblSeqStyle == 1)
            [self applyHeaderOrderChange];
    }
    
    // Handling : importance / x-priority
    if ([impHeader length] > 0) {
        [messageAttribution addObject:[impHeader mutableAttributedString]];
    }
}

- (id)initWithMailMessage:(id)mailMessage
{
    if (self = [super init])
    {
        choosenLocaleIdentifier = GET_DEFAULT(MHBundleHeaderLanguageCode);
        MHLog(@"From User defaults choosenLocaleIdentifier %@", choosenLocaleIdentifier);
        
        if (!choosenLocaleIdentifier) {
            choosenLocaleIdentifier = MHLocaleIdentifier;
            
            MHLog(@"Fallback to default value of choosenLocaleIdentifier %@", choosenLocaleIdentifier);
        }
        
        choosenLocale = [[NSLocale alloc] initWithLocaleIdentifier:choosenLocaleIdentifier];
        
        //for issue #71 - https://github.com/jeevatkm/ReplyWithHeader/issues/71
        NSAttributedString *headerString = nil;
        id mcMessageHeaders = [mailMessage originalMessageHeaders];
        
        if ([mcMessageHeaders respondsToSelector:@selector(attributedStringShowingHeaderDetailLevel:)])
        {
            headerString = [mcMessageHeaders
                            attributedStringShowingHeaderDetailLevel:[NSNumber numberWithInt:1]];
        }
        else
        {
            headerString = [mcMessageHeaders valueForKey:@"attributedString"];
        }
        
        if ([allTrim([headerString string]) length] == 0)
        {
            noHeaders = true;
            MHLog(@"headerString is empty, it could be due to Multi-email forward scenario");
            return self;
        }
        
        NSArray *headers = [[headerString string]
                            componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        cleanHeaders = [mailMessage valueForKey:@"_cleanHeaders"];
        noOfHeaderLabels = [headers count];
        
        NSMutableArray *allHeaderkeys = [[[NSOrderedSet
                                           orderedSetWithArray:[mcMessageHeaders allHeaderKeys]] array] mutableCopy];
        MHLog(@"allHeaderKeys from message:: %@", allHeaderkeys);
        
        // Handling : importance / x-priority
        impHeader = [self getImportanceHdr:allHeaderkeys mcMessageHeaders:mcMessageHeaders];
        
        // for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/85
        if (GET_DEFAULT_BOOL(MHRawHeadersEnabled))
        {
            // Preparing All headers
            allHeaders = [[NSMutableArray alloc] init];
            
            // Cleanup of already parsed headers from, to, cc, subject, date
            [allHeaderkeys removeObject:@"from"];
            [allHeaderkeys removeObject:@"subject"];
            [allHeaderkeys removeObject:@"date"];
            [allHeaderkeys removeObject:@"to"];
            
            if ([allHeaderkeys containsObject:@"cc"])
            {
                [allHeaderkeys removeObject:@"cc"];
            }
            
            if ([allHeaderkeys containsObject:@"reply-to"])
            {
                NSString *key = @"reply-to";
                [allHeaderkeys removeObject:key];
                NSString *value = [[mcMessageHeaders addressListForKey:key]
                                   componentsJoinedByString:@", "];
                MHLog(@"Key: %@, Values: %@", key, value);
                
                [allHeaders addObject:[[NSString stringWithFormat:@"Reply-To: %@", value] mutableAttributedString]];
            }
            
            if ([impHeader length] > 0) {
                [allHeaderkeys removeObject:@"importance"];
                [allHeaderkeys removeObject:@"x-priority"];
            }
            
            MHLog(@"After cleanup allHeaderKeys:: %@", allHeaderkeys);
            
            NSMutableArray *nonKeys = [[NSMutableArray alloc] init];
            for (int i=0; i<[allHeaderkeys count]; i++)
            {
                NSString *key = [allHeaderkeys objectAtIndex:i];
                
                @try
                {
                    NSString *values = [[mcMessageHeaders headersForKey:key]
                                            componentsJoinedByString:@",\n"];
                    [allHeaders addObject:[[NSString stringWithFormat:@"%@: %@", [key capitalizedString], values] mutableAttributedString]];
                }
                @catch (NSException *exception)
                {
                    [nonKeys addObject:[NSString stringWithFormat:@"%d||%@", i, key]];
                    
                    MHLog(@"Error occured for header key [%@], message is [%@]",
                          key, exception.description);
                }
            }
            
            if ([nonKeys count] > 0)
            {
                // Special case
                if ([MailHeader isYosemite])
                {
                    MHLog(@"Special header [%@] handling in Yosemite for this message.", nonKeys);
                    for (int i=0; i<[nonKeys count]; i++)
                    {
                        NSString *posKey = [nonKeys objectAtIndex:i];
                        NSArray *t = [posKey componentsSeparatedByString:@"||"];
                        NSString *key = [t objectAtIndex:1];
                        
                        NSString *values = [[mcMessageHeaders messageIDListForKey:key] componentsJoinedByString:@",\n"];
                        
                        [allHeaders
                            insertObject:[[NSString
                                        stringWithFormat:@"%@: %@", [key capitalizedString], values] mutableAttributedString]
                                         atIndex:[[t objectAtIndex:1] intValue]];
                    }
                }
                else
                {
                    NSLog(@"RWH: Unable to parse following headers [%@] for this message.", nonKeys);
                }
            }
            
            MHLog(@"allHeaders:: %@", allHeaders);
        }
        
        MHLog(@"Original headers %@", headers);
        MHLog(@"Original headers count %lu", noOfHeaderLabels);
        
        // for issue #27 - https://github.com/jeevatkm/ReplyWithHeader/issues/27
        allowedHeaders = [MailHeader getConfigValue:@"AllowedHeaders" languageCode:MHLocaleIdentifier];
        messageAttribution = [[NSMutableArray alloc] init];
        
        //for (NSString *str in allowedHeaders)
        // for issue #94 - https://github.com/jeevatkm/ReplyWithHeader/issues/94
        for (int h=0; h< [allowedHeaders count]; h++)
        {
            NSString *str = [allowedHeaders objectAtIndex:h];
            bool found = false;
            
            for (int i=0; i<[headers count]; i++)
            {
                NSString *row = [headers objectAtIndex:i];
                NSRange range = [row rangeOf:@":"];
                
                if (range.location != NSNotFound)
                {
                    NSString *label = [row substringToIndex:range.location];
                    if (NSOrderedSame == [str localizedCaseInsensitiveCompare:label])
                    {
                        found = true;
                        [messageAttribution addObject:[row mutableAttributedString]];
                        break;
                    }
                }
            }
            
            if (h==1 && !found) // empty Subject header
            {
                [messageAttribution addObject:[[NSString stringWithFormat:@"%@:", str] mutableAttributedString]];
            }
        }
    }
    
    MHLog(@"messageAttribution:=> %@", messageAttribution);
    
    return self;
}


#pragma mark Class private methods

- (void)applyFromAttibutionStyle
{
    NSString *fromPrefix = MHLocalizedStringByLocale(@"STRING_FROM", MHLocaleIdentifier);
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        fromPrefix = MHLocalizedStringByLocale(@"STRING_FROM", choosenLocaleIdentifier);
    }
    
    MHLog(@"fromPrefix: %@", fromPrefix);
    
    // Attribution position
    // 0 => from
    NSMutableAttributedString *row = [messageAttribution objectAtIndex:0];
    NSRange range = [[row string] rangeOfString:@":"];
    
    NSString *fromString = [[[[row string] precomposedStringWithCanonicalMapping] substringFromIndex:range.location + 2] trim];
    
    [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:fromPrefix];
    
    NSInteger fromTagStyle = GET_DEFAULT_INT(MHHeaderAttributionFromTagStyle);
    fromString = [self fullNameFromEmailAddress:fromString attribStyle:fromTagStyle];
    
    [row replaceCharactersInRange:NSMakeRange(range.location + 2, [row length] - (range.location + 2)) withString:fromString];
}

- (void)applyToCcAttibutionStyle
{
    NSString *toPrefix = MHLocalizedStringByLocale(@"STRING_TO", MHLocaleIdentifier);
    NSString *ccPrefix = MHLocalizedStringByLocale(@"STRING_CC", MHLocaleIdentifier);
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        toPrefix = MHLocalizedStringByLocale(@"STRING_TO", choosenLocaleIdentifier);
        ccPrefix = MHLocalizedStringByLocale(@"STRING_CC", choosenLocaleIdentifier);
    }
    
    MHLog(@"toPrefix: %@, ccPrefix: %@", toPrefix, ccPrefix);
    
    // Attribution position
    // 3 => to
    // 4 => cc
    for (int i=3; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        NSRange range = [[row string] rangeOf:@":"];
        
        NSString *emailString = [[[[row string] precomposedStringWithCanonicalMapping]
                                  substringFromIndex:range.location + 2] trim];
        NSArray *emails = [emailString componentsSeparatedByString:@">, "];
        
        NSInteger toCcTagStyle = GET_DEFAULT_INT(MHHeaderAttributionToCcTagStyle);
        NSString *delimStr = (toCcTagStyle == 1) ? @"; " : @">, ";
            
        NSString *finalString = @"";
        if (emails && [emails count] > 0)
        {
            for (NSString *emailId in emails)
            {
                NSString *response = [self fullNameFromEmailAddress:emailId attribStyle:toCcTagStyle];
                finalString = [finalString stringByAppendingString:response];
                finalString = [finalString stringByAppendingString:delimStr];
            }
                
            int posIndex = [finalString length] - 2;
            NSString *last = [finalString substringWithRange:NSMakeRange(posIndex, 2)];
                
            if ([last isEqualToString:@"; "])
                finalString = [finalString substringToIndex:posIndex];
            else if ([last isEqualToString:@", "])
                finalString = [finalString substringToIndex:(posIndex - 1)];
        }
        else
        {
                finalString = [self fullNameFromEmailAddress:emailString attribStyle:toCcTagStyle];
        }
            
        [row replaceCharactersInRange:NSMakeRange(range.location + 2, [row length] - (range.location + 2)) withString:finalString];
            
        range = [[row string] rangeOf:@":"];
        [row replaceCharactersInRange:NSMakeRange(0, range.location)
                               withString:(i == 3) ? toPrefix : ccPrefix];
    }
    
}

- (void)applySubjectAttibutionStyle
{
    NSString *subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", MHLocaleIdentifier);
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", choosenLocaleIdentifier);
    }
    
    MHLog(@"subjectPrefix: %@", subjectPrefix);
    
    // Attribution position
    // 1 => subject
    NSMutableAttributedString *row = [messageAttribution objectAtIndex:1];
    NSRange range;
    
    range = [[row string] rangeOf:@":"];
    [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:subjectPrefix];
}

- (void)applyDateAttibutionStyle
{
    NSString *datePrefix = MHLocalizedStringByLocale(@"STRING_DATE", MHLocaleIdentifier);
    NSString *dateToBePrefix = MHLocalizedStringByLocale(@"STRING_SENT", MHLocaleIdentifier);
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        datePrefix = MHLocalizedStringByLocale(@"STRING_DATE", choosenLocaleIdentifier);
        dateToBePrefix = MHLocalizedStringByLocale(@"STRING_SENT", choosenLocaleIdentifier);
    }
    
    MHLog(@"datePrefix: %@, dateToBePrefix: %@", datePrefix, dateToBePrefix);
    
    // Attribution position
    // 2 => date
    NSMutableAttributedString *row = [messageAttribution objectAtIndex:2];
    NSRange range;
    
    if (GET_DEFAULT_INT(MHHeaderAttributionLblSeqTagStyle) == 1)
    {
        range = [[row string] rangeOf:@":"];
        [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:dateToBePrefix];
    }
    
    // for issue #37 - https://github.com/jeevatkm/ReplyWithHeader/issues/37
    // trying this universal solution
    //if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    //{
        range = [[[row string] precomposedStringWithCanonicalMapping] rangeOf:@":"];
        NSUInteger start = range.location + 2;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
        MHLog(@"Date format: %@", [dateFormatter dateFormat]);
        
        @try {
            NSString *dateTimeStr = [[[row string] precomposedStringWithCanonicalMapping] substringFromIndex:start];
            NSDate *date = [dateFormatter dateFromString:dateTimeStr];
            MHLog(@"dateTimeStr: %@, date: %@", dateTimeStr, date);
            
            [dateFormatter setLocale:choosenLocale];
            int dateTagStyle = GET_DEFAULT_INT(MHHeaderAttributionDateTagStyle);
//            if (dateTagStyle == 0) {
//                NSLog(@"Default Date format: %@", [dateFormatter dateFormat]);
//                [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy 'at' h:mm:ss a"];
//            } else
            if (dateTagStyle == 1) {
                //[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                [dateFormatter setTimeZone:gmt];
                //[dateFormatter setDateFormat:@"EEEE, MMM d, yyyy 'at' h:mm:ss a Z"];
                MHLog(@"Modified date format %@", [dateFormatter dateFormat]);
            }
            
            NSString *newLocalDateStr = [dateFormatter stringFromDate:date];
            MHLog(@"Localized date: %@", newLocalDateStr);
            
            NSUInteger length = [[row string] length] - start;
            MHLog(@"Before date: %@", [row string]);
            [row replaceCharactersInRange:NSMakeRange(start, length) withString:newLocalDateStr];
            MHLog(@"After date: %@", [row string]);
        }
        @catch (NSException *exception) {
            NSLog(@"RWH Unable to parse date [%@]", exception.description);
        }
    //}
}

- (void)applyHeaderOrderChange
{
    NSString *subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", MHLocaleIdentifier);
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", choosenLocaleIdentifier);
    }
    
    int subjectIndex = 1; // default position
    BOOL subjectIndexFound = FALSE;
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        // for #76 - https://github.com/jeevatkm/ReplyWithHeader/issues/76
        NSString *rowNorm = [[[row string] precomposedStringWithCanonicalMapping] trim];
        
        if ([rowNorm hasPrefix:subjectPrefix])
        {
            subjectIndex = i;
            subjectIndexFound = TRUE;
            break;
        }
    }
    
    MHLog(@"Subject Index found : %@", subjectIndexFound ? @"YES" : @"NO");
    if (subjectIndexFound)
    {
        @try {
            MHLog(@"Before: %@", messageAttribution);
            NSMutableAttributedString *subject = [[messageAttribution objectAtIndex:subjectIndex] mutableCopy];
            [messageAttribution removeObjectAtIndex:subjectIndex];
            [messageAttribution addObject:subject];
            MHLog(@"After: %@", messageAttribution);
        }
        @catch (NSException *exception) {
            MHLog(@"Exception occured: %@", exception.description);
        }
    }
    else
    {
        MHLog(@"Subject index is not found, so skiping Header order change.");
    }
}

- (NSString *)fullNameFromEmailAddress:(NSString *)emailAddress attribStyle:(NSInteger)style {
    
    emailAddress = [emailAddress trim];
    
    if ([emailAddress length] > 0)
    {
        NSRange range = [emailAddress rangeOf:@"<"];
        
        if (range.location != NSNotFound && range.location != 0)
        {
            NSString *fullName = [emailAddress copy];
            if (style == 1 || style == 2) {
                fullName = [emailAddress substringToIndex:range.location];
                
                if (style == 2) {
                    NSString *fromMailId = [emailAddress substringFromIndex:range.location];
                    fromMailId = [fromMailId
                              stringByReplacingOccurrencesOfString:@"<" withString:@"[mailto:"];
                    fromMailId = [fromMailId stringByReplacingOccurrencesOfString:@">" withString:@"]"];
                    fullName = [fullName stringByAppendingString:fromMailId];
                }
            }
            
            fullName = [fullName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            // for issue #38 - https://github.com/jeevatkm/ReplyWithHeader/issues/38
            fullName = [fullName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            return [fullName trim];
        }
        
        emailAddress = [emailAddress stringByReplacingOccurrencesOfString:@"<" withString:@""];
        emailAddress = [emailAddress stringByReplacingOccurrencesOfString:@">" withString:@""];
    }
    
    return emailAddress;
}

- (NSString *)getImportanceHdr:(NSMutableArray *)headerKeys mcMessageHeaders:(id)mcMessageHeaders
{
    NSString *hdr = nil;
    NSString *hdrKey = @"";
    
    if ([headerKeys containsObject:@"importance"]) {
        hdrKey = @"importance";
    } else if ([headerKeys  containsObject:@"x-priority"]) {
        hdrKey = @"x-priority";
    }
    
    NSString *value = [[[mcMessageHeaders headersForKey:hdrKey] componentsJoinedByString:@",\n"] trim];
    MHLog(@"Original Importance/X-Priority Header Value[%@]:: %@", hdrKey, value);
    
    if ([value isEqualToString:@"1"] || [value isEqualToString:@"5"]
        || [value isEqualToString:@"high"] || [value isEqualToString:@"low"]) {
        
        if ([value isEqualToString:@"1"]) {
            value = @"high";
        } else if ([value isEqualToString:@"5"]) {
            value = @"low";
        }
        
        hdr = [NSString stringWithFormat:@"Importance: %@", [value capitalizedString]];
    }
    
    return hdr;
}

- (NSMutableAttributedString *) getFinalHeader
{
    NSMutableAttributedString *finalHeader = [[NSMutableAttributedString alloc] init];
    if (noHeaders) {
        return finalHeader;
    }
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        [finalHeader appendAttributedString:[messageAttribution objectAtIndex:i]];
        [finalHeader appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    // for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/85
    if (GET_DEFAULT_BOOL(MHRawHeadersEnabled))
    {
        for (int i=0; i<[allHeaders count]; i++)
        {
            [finalHeader appendAttributedString:[allHeaders objectAtIndex:i]];
            [finalHeader appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }
    
    MHLog(@"final header values before web archiving %@", finalHeader);
    
    return finalHeader;
}

@end
