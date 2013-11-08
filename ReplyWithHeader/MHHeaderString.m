/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
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
        
        NSRange range = [[row string] rangeOfString:@":"
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0, [row length])
                                             locale:choosenLocale];
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
                                                 languageCode:GET_DEFAULT(MHBundleHeaderLanguageCode)];
    MHLog(@"Choosen language header labels %@", choosenHeaderLabels);
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        NSRange range = [[row string] rangeOfString:@":"
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0, [row length])
                                             locale:[MailHeader currentLocale]];
        
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
    if ([[MailHeader localeIdentifier] isNotEqualTo:choosenLocaleIdentifier]) {
        [self applyChoosenLanguageLabels];
    }
    
    int headerOrderMode = GET_DEFAULT_INT(MHHeaderOrderMode);
    int headerLabelMode = GET_DEFAULT_INT(MHHeaderLabelMode);
    MHLog(@"Mail Header Order mode: %d and Label mode: %d", headerOrderMode, headerLabelMode);
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( [MailHeader isLocaleSupported] ) {
        
        if (headerOrderMode == 2)
            [self applyHeaderOrderChange];
    }
    
    if (headerLabelMode == 2)
        [self applyHeaderLabelChange];
}

- (id)initWithMailMessage:(id)mailMessage
{
    if (self = [super init])
    {
        choosenLocaleIdentifier = GET_DEFAULT(MHBundleHeaderLanguageCode);
        choosenLocale = [[NSLocale alloc] initWithLocaleIdentifier:choosenLocaleIdentifier];
        
        NSAttributedString *headerString = [[mailMessage originalMessageHeaders]
                         attributedStringShowingHeaderDetailLevel:[NSNumber numberWithInt:1]];
        
        cleanHeaders = [mailMessage valueForKey:@"_cleanHeaders"];
        
        NSArray *headers = [[headerString string]
                            componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        noOfHeaderLabels = [headers count];
        
        MHLog(@"Original headers %@", headers);
        MHLog(@"Original headers count %lu", noOfHeaderLabels);
        
        // for issue #27 - https://github.com/jeevatkm/ReplyWithHeader/issues/27
        allowedHeaders = [MailHeader getConfigValue:@"AllowedHeaders"];
        messageAttribution = [[NSMutableArray alloc] init];
        
        for (NSString *str in allowedHeaders)
        {
            for (int i=0; i<[headers count]; i++)
            {
                NSString *row = [headers objectAtIndex:i];
                NSRange range = [row rangeOfString:@":"
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(0, [row length])
                                            locale:[MailHeader currentLocale]];
                
                if (range.location != NSNotFound) {
                    NSString *label = [row substringToIndex:range.location];
                    
                    if (NSOrderedSame == [str localizedCaseInsensitiveCompare:label]) {
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:row];
                        [messageAttribution addObject:attrString];
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
    NSString *subjectPrefix = MHLocalizedString(@"STRING_SUBJECT");
    
    if ([[MailHeader localeIdentifier] isNotEqualTo:choosenLocaleIdentifier]) {
        subjectPrefix = [MailHeader localizedString:@"STRING_SUBJECT"
                                   localeIdentifier:choosenLocaleIdentifier];
    }
    
    int subjectIndex = 1; // default position
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        if ([[row string] hasPrefix:subjectPrefix]) {
            subjectIndex = i;
            break;
        }
    }
    
    NSMutableAttributedString *subject = [[messageAttribution objectAtIndex:subjectIndex] mutableCopy];
    [messageAttribution removeObjectAtIndex:subjectIndex];
    [messageAttribution addObject:subject];
}

- (void)applyHeaderLabelChange
{
    NSString *fromMailId;
    NSError * __autoreleasing regError = nil;
    NSRegularExpression *lblRegex = [NSRegularExpression
                                  regularExpressionWithPattern:MH_QUOTED_EMAIL_REGEX_STRING
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&regError];
    
    NSString *fromPrefix = MHLocalizedString(@"STRING_FROM");
    NSString *datePrefix = MHLocalizedString(@"STRING_DATE");
    NSString *dateToBePrefix = MHLocalizedString(@"STRING_SENT");
    
    if ([[MailHeader localeIdentifier] isNotEqualTo:choosenLocaleIdentifier]) {
        fromPrefix = [MailHeader localizedString:@"STRING_FROM"
                                localeIdentifier:choosenLocaleIdentifier];
        
        datePrefix = [MailHeader localizedString:@"STRING_DATE"
                                localeIdentifier:choosenLocaleIdentifier];
        
        dateToBePrefix = [MailHeader localizedString:@"STRING_SENT"
                                localeIdentifier:choosenLocaleIdentifier];
    }
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        if ([[row string] hasPrefix:fromPrefix]) {
            NSArray *matches = [lblRegex
                                matchesInString:[row string]
                                options:0
                                range:NSMakeRange(0, [row length])];
            
            for (NSTextCheckingResult *match in matches)
            {
                fromMailId = [[row string] substringWithRange:[match rangeAtIndex:1]];
                
                [row replaceCharactersInRange:[match range] withString:[NSString stringWithFormat:@" %@%@%@", @"[mailto:", fromMailId, @"]"]];
                
                NSString *fromString = [[row string] substringToIndex:[match range].location];
                
                fromString = [fromString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([fromString isEqualToString:[fromPrefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
                    [row replaceCharactersInRange:NSMakeRange([match range].location, 1) withString:[NSString stringWithFormat:@" %@ ", fromMailId]];
                }
            }
        }
        
        if ([[row string] hasPrefix:datePrefix]) {
            NSRange dRange = [[row string] rangeOfString:datePrefix];
            
            if (dRange.location != NSNotFound)
            {
                [row replaceCharactersInRange:dRange withString:dateToBePrefix];
            }
        }
        
        NSRange range = [lblRegex rangeOfFirstMatchInString:[row string] options:0
                                                   range:NSMakeRange(0, [row length])];
        while (range.location != NSNotFound)
        {
            [row replaceCharactersInRange:range withString:@";"];
            range = [lblRegex rangeOfFirstMatchInString:[row string] options:0
                                               range:NSMakeRange(0, [row length])];
        }
        
        // double quotes into empty
        range = [[row string] rangeOfString:@"\""];
        while (range.location != NSNotFound)
        {
            [row replaceCharactersInRange:range withString:@""];
            range = [[row string] rangeOfString:@"\""];
        }
        
        // single quotes into empty
        range = [[row string] rangeOfString:@"'"];
        while (range.location != NSNotFound)
        {
            [row replaceCharactersInRange:range withString:@""];
            range = [[row string] rangeOfString:@"'"];
        }
        
        // Perfection of semi-colon (;) handling stage 2
        NSString *last = [[row string] substringWithRange:NSMakeRange([row length] - 1, 1)];
        if ([last isEqualToString:@";"])
        {
            [row replaceCharactersInRange:NSMakeRange([row length] - 1, 1) withString:@""];
        }
    }   
}

@end
