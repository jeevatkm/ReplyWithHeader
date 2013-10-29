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
- (NSFont *)userDefaultMessageFont;
- (NSMutableAttributedString *)attributedStringShowingHeaderDetailLevel:(id)level;
@end

#pragma mark Constants and global variables

NSString *MH_LABEL_REGEX_STRING = @"\\w+:\\s";
//NSString *HEADER_LABEL_REGEX_STRING = @"(\\n|\\r)[\\w\\-\\s]+:\\s";
NSString *MH_QUOTED_EMAIL_REGEX_STRING = @"\\s<([a-zA-Z0-9_@\\.\\-]*)>,?";  //@"(\\s<([a-zA-Z][a-zA-Z0-9]*)[^>]*>,?)";
//NSString *SEMICOLON_NEWLINE_REGEX_STRING = @";\\s*?\\n";

@implementation MHHeaderString

#pragma mark Class instance methods

- (void)applyHeaderTypography
{
    NSString *fontString = GET_DEFAULT_VALUE(MHHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(MHHeaderFontSize);
    NSFont *font = [NSFont fontWithName:fontString size:fontSize.floatValue];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData:GET_DEFAULT_DATA(MHHeaderColor)];
    
    NSError * __autoreleasing error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:MH_LABEL_REGEX_STRING
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    if( !GET_DEFAULT_BOOL(MHTypographyEnabled) )
    {
        font = [NSFont fontWithName:@"Helvetica" size:13.0];
        color = [NSColor blackColor];
    }
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        [row addAttribute:NSFontAttributeName
                             value:font range:NSMakeRange(0, [row length])];
        [row addAttribute:NSForegroundColorAttributeName
                             value:color range:NSMakeRange(0, [row length])];
        
        NSRange range = [regex rangeOfFirstMatchInString:[row string]
                                                 options:0
                                                   range:NSMakeRange(0, [row length])];
        if (range.location != NSNotFound)
        {
            [row applyFontTraits:NSBoldFontMask range:range];
        }
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

- (int)getHeaderItemCount
{
    MHLog(@"Mail header count is %d", noOfHeaderLabels);
    
    return (noOfHeaderLabels - 1);
}

// For now it does outlook mail label ordering
- (void)applyHeaderLabelOptions
{
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
        NSAttributedString *headerString = [[mailMessage originalMessageHeaders]
                         attributedStringShowingHeaderDetailLevel:[NSNumber numberWithInt:1]];
        
        cleanHeaders = [mailMessage valueForKey:@"_cleanHeaders"];
        
        NSArray *headers = [[headerString string]
                            componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        noOfHeaderLabels = [headers count];
        
        MHLog(@"Original values %@", headers);
        MHLog(@"Original values count %lu", noOfHeaderLabels);
        
        // for issue #27 - https://github.com/jeevatkm/ReplyWithHeader/issues/27
        NSArray *allowedHeaders = [MailHeader getConfigValue:@"AllowedHeaders"];
        messageAttribution = [[NSMutableArray alloc] init];
        
        for (NSString *str in allowedHeaders)
        {
            for (int i=0; i<[headers count]; i++)
            {
                NSString *row = [headers objectAtIndex:i];
                if ([row hasPrefix:str]) {
                    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:row];
                    [messageAttribution addObject:attrString];
                    break;
                }
            }
        }
    }
    
    return self;
}


#pragma mark Class private methods

- (void)applyHeaderOrderChange
{
    int subjectIndex = 1; // default position
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        if ([[row string] hasPrefix:MHLocalizedString(@"STRING_SUBJECT")]) {
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
    
    for (int i=0; i<[messageAttribution count]; i++)
    {
        NSMutableAttributedString *row = [messageAttribution objectAtIndex:i];
        
        if ([[row string] hasPrefix:MHLocalizedString(@"STRING_FROM")]) {
            NSArray *matches = [lblRegex
                                matchesInString:[row string]
                                options:0
                                range:NSMakeRange(0, [row length])];
            
            for (NSTextCheckingResult *match in matches)
            {
                fromMailId = [[row string] substringWithRange:[match rangeAtIndex:1]];
                MHLog(@"From Email id %@", fromMailId);
                
                [row replaceCharactersInRange:[match range] withString:[NSString stringWithFormat:@" %@%@%@", @"[mailto:", fromMailId, @"]"]];
            }
        }
        
        if ([[row string] hasPrefix:MHLocalizedString(@"STRING_DATE")]) {
            NSRange dRange = [[row string] rangeOfString:MHLocalizedString(@"STRING_DATE")];
            
            if (dRange.location != NSNotFound)
            {
                [row replaceCharactersInRange:dRange withString:MHLocalizedString(@"STRING_SENT")];
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
        
        // double quoutes into empty
        range = [[row string] rangeOfString:@"\""];
        while (range.location != NSNotFound)
        {
            [row replaceCharactersInRange:range withString:@""];
            range = [[row string] rangeOfString:@"\""];
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
