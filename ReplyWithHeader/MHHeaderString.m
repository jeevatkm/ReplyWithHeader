/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Jeevanandam M.
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
#import "NSMutableAttributedString+MailHeader.h"
#import "NSAttributedString+MailAttributedStringToHTML.h"
#import "NSString+MailHeader.h"

@interface MHHeaderString (MHNoImplementation)
- (id)originalMessageHeaders;
- (NSMutableAttributedString *)attributedStringShowingHeaderDetailLevel:(id)level;
@end

#pragma mark Constants and global variables

NSString *MH_QUOTED_EMAIL_REGEX_STRING = @"\\s<([a-zA-Z0-9_@\\.\\-]*)>,?";

@implementation MHHeaderString

#pragma mark Class instance methods

- (void)applyHeaderTypography
{
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
    NSMutableAttributedString *finalHeader = [[NSMutableAttributedString alloc] init];
    for (int i=0; i<[messageAttribution count]; i++)
    {
        [finalHeader appendAttributedString:[messageAttribution objectAtIndex:i]];
        [finalHeader appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    MHLog(@"final header values before web archiving %@", messageAttribution);
    
    WebArchive *webarch = [finalHeader
                           webArchiveForRange:NSMakeRange(0, [finalHeader length])
                           fixUpNewlines:YES];
    
    return webarch;
}

- (NSUInteger)getHeaderItemCount
{
    MHLog(@"Mail header count is %d", noOfHeaderLabels);
    
    return (noOfHeaderLabels - 1);
}

// For now it does outlook mail label ordering
- (void)applyHeaderLabelOptions
{
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier]) {
        [self applyChoosenLanguageLabels];
    }
    
    int headerOrderMode = GET_DEFAULT_INT(MHHeaderOrderMode);
    int headerLabelMode = GET_DEFAULT_INT(MHHeaderLabelMode);
    MHLog(@"Mail Header Order mode: %d and Label mode: %d", headerOrderMode, headerLabelMode);
    
    if (headerLabelMode == 2)
        [self applyHeaderLabelChange];
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( [MailHeader isLocaleSupported] ) {
        
        if (headerOrderMode == 2)
            [self applyHeaderOrderChange];
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
        
        NSArray *headers = [[headerString string]
                            componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        cleanHeaders = [mailMessage valueForKey:@"_cleanHeaders"];
        noOfHeaderLabels = [headers count];
        
        MHLog(@"Original headers %@", headers);
        MHLog(@"Original headers count %lu", noOfHeaderLabels);
        
        // for issue #27 - https://github.com/jeevatkm/ReplyWithHeader/issues/27
        allowedHeaders = [MailHeader getConfigValue:@"AllowedHeaders" languageCode:MHLocaleIdentifier];
        messageAttribution = [[NSMutableArray alloc] init];
        
        for (NSString *str in allowedHeaders)
        {
            for (int i=0; i<[headers count]; i++)
            {
                NSString *row = [headers objectAtIndex:i];
                NSRange range = [row rangeOf:@":"];
                
                if (range.location != NSNotFound)
                {
                    NSString *label = [row substringToIndex:range.location];
                    if (NSOrderedSame == [str localizedCaseInsensitiveCompare:label])
                    {
                        [messageAttribution addObject:[row mutableAttributedString]];
                        break;
                    }
                }
            }
        }
    }
    
    return self;
}


#pragma mark Class private methods

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

- (NSString *)fullNameFromEmailAddress:(NSString *)emailAddress isMailToNeeded:(BOOL)mailTo
{
    emailAddress = [emailAddress trim];
    
    if ([emailAddress length] > 0)
    {
        NSRange range = [emailAddress rangeOf:@"<"];
        
        if (range.location != NSNotFound && range.location != 0)
        {
            NSString *fullName = [emailAddress substringToIndex:range.location];
            
            if (mailTo)
            {
                NSString *fromMailId = [emailAddress substringFromIndex:range.location];
                fromMailId = [fromMailId
                              stringByReplacingOccurrencesOfString:@"<" withString:@"[mailto:"];
                fromMailId = [fromMailId stringByReplacingOccurrencesOfString:@">" withString:@"]"];
                fullName = [fullName stringByAppendingString:fromMailId];
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

// for #76 - https://github.com/jeevatkm/ReplyWithHeader/issues/76
- (void)applyHeaderLabelChange
{
    NSString *fromPrefix = MHLocalizedStringByLocale(@"STRING_FROM", MHLocaleIdentifier);
    NSString *toPrefix = MHLocalizedStringByLocale(@"STRING_TO", MHLocaleIdentifier);
    NSString *ccPrefix = MHLocalizedStringByLocale(@"STRING_CC", MHLocaleIdentifier);
    NSString *datePrefix = MHLocalizedStringByLocale(@"STRING_DATE", MHLocaleIdentifier);
    NSString *dateToBePrefix = MHLocalizedStringByLocale(@"STRING_SENT", MHLocaleIdentifier);
    NSString *subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", MHLocaleIdentifier);
    
    if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
    {
        fromPrefix = MHLocalizedStringByLocale(@"STRING_FROM", choosenLocaleIdentifier);
        toPrefix = MHLocalizedStringByLocale(@"STRING_TO", choosenLocaleIdentifier);
        ccPrefix = MHLocalizedStringByLocale(@"STRING_CC", choosenLocaleIdentifier);
        datePrefix = MHLocalizedStringByLocale(@"STRING_DATE", choosenLocaleIdentifier);
        dateToBePrefix = MHLocalizedStringByLocale(@"STRING_SENT", choosenLocaleIdentifier);
        subjectPrefix = MHLocalizedStringByLocale(@"STRING_SUBJECT", choosenLocaleIdentifier);
    }
 
    MHLog(@"applyHeaderLabelChange: %@", messageAttribution);
    MHLog(@"fromPrefix: %@, toPrefix: %@, ccPrefix: %@, datePrefix: %@, dateToBePrefix: %@", fromPrefix, toPrefix, ccPrefix, datePrefix, dateToBePrefix);

    // Attribution position
    // 0 => from
    // 1 => subject
    // 2 => date
    // 3 => to
    // 4 => cc
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        //NSString *rowNorm = [[row string] precomposedStringWithCanonicalMapping];
        
        NSRange range;
        
        if (i == 0)
        {
            range = [[row string] rangeOfString:@":"];
            NSString *fromString = [[[[row string] precomposedStringWithCanonicalMapping] substringFromIndex:range.location + 2] trim];
            
            NSInteger fromTagStyle = GET_DEFAULT_INT(MHHeaderAttributionFromTagStyle);
            BOOL mailToNeeded = FALSE;
            
            if (fromTagStyle == 1) mailToNeeded = TRUE;
            fromString = [self fullNameFromEmailAddress:fromString isMailToNeeded:mailToNeeded];
            
            [row replaceCharactersInRange:NSMakeRange(range.location + 2, [row length] - (range.location + 2)) withString:fromString];
            
            [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:fromPrefix];
        }
        
        if (i == 1)
        {
            range = [[row string] rangeOf:@":"];
            [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:subjectPrefix];
        }
        
        if (i == 2)
        {
            range = [[row string] rangeOf:@":"];
            [row replaceCharactersInRange:NSMakeRange(0, range.location) withString:dateToBePrefix];
            
            // for issue #37 - https://github.com/jeevatkm/ReplyWithHeader/issues/37
            // trying this universal solution
            if ([MHLocaleIdentifier isNotEqualTo:choosenLocaleIdentifier])
            {
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
                    NSString *newLocalDateStr = [dateFormatter stringFromDate:date];
                    MHLog(@"Localized date: %@", newLocalDateStr);
                    
                    NSUInteger length = [[row string] length] - start;
                    MHLog(@"Before date: %@", [row string]);
                    [row replaceCharactersInRange:NSMakeRange(start, length) withString:newLocalDateStr];
                    MHLog(@"After date: %@", [row string]);
                }
                @catch (NSException *exception) {
                    MHLog(@"Exception occured: %@", exception.description);
                }
            }
        }
        
        if (i == 3 || i == 4)
        {
            range = [[row string] rangeOf:@":"];
            NSString *emailString = [[[[row string] precomposedStringWithCanonicalMapping] substringFromIndex:range.location + 2] trim];
            NSArray *emails = [emailString componentsSeparatedByString:@">, "];
            
            NSString *finalString = @"";
            if (emails && [emails count] > 0)
            {
                for (NSString *emailId in emails)
                {
                    NSString *response = [self fullNameFromEmailAddress:emailId isMailToNeeded:FALSE];
                    finalString = [finalString stringByAppendingString:response];
                    finalString = [finalString stringByAppendingString:@"; "];
                }
                
                int posIndex = [finalString length] - 2;
                NSString *last = [finalString substringWithRange:NSMakeRange(posIndex, 2)];
                
                if ([last isEqualToString:@"; "])
                    finalString = [finalString substringToIndex:posIndex];
            }
            else
            {
                finalString = [self fullNameFromEmailAddress:emailString isMailToNeeded:FALSE];
            }
            
            [row replaceCharactersInRange:NSMakeRange(range.location + 2, [row length] - (range.location + 2)) withString:finalString];
            
            range = [[row string] rangeOf:@":"];
            [row replaceCharactersInRange:NSMakeRange(0, range.location)
                               withString:(i == 3) ? toPrefix : ccPrefix];
        }
    }   
}

@end
