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

NSString *FROM_LABEL_REGEX_STRING = @"\\w+:\\s";
NSString *HEADER_LABEL_REGEX_STRING = @"(\\n|\\r)[\\w\\-\\s]+:\\s";
NSString *QUOTED_EMAIL_REGEX_STRING = @"(\\s<([a-zA-Z][a-zA-Z0-9]*)[^>]*>,?)"; //\s<([a-zA-Z0-9_@\.\-]*)>,?
NSString *SEMICOLON_NEWLINE_REGEX_STRING = @";\\s*?\\n";

@implementation MHHeaderString

#pragma mark Class instance methods

- (void)applyHeaderTypography
{
    NSString *fontString = GET_DEFAULT_VALUE(MHHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(MHHeaderFontSize);
    NSFont *font = [NSFont fontWithName:fontString size:fontSize.floatValue];
    
    NSColor *color = [NSUnarchiver unarchiveObjectWithData:GET_DEFAULT_DATA(MHHeaderColor)];
    
    [headerString addAttribute:NSFontAttributeName
                         value:font range:NSMakeRange(0, [headerString length])];
    [headerString addAttribute:NSForegroundColorAttributeName
                         value:color range:NSMakeRange(0, [headerString length])];
}

- (void)applyBoldFontTraits:(BOOL)isHeaderTypograbhyEnabled
{
    if (!isHeaderTypograbhyEnabled)
    {
        [headerString
            addAttribute:NSFontAttributeName
            value:[NSFont fontWithName:@"Helvetica" size:13.0]
            range:NSMakeRange(0, [headerString length])];
    }
    
    // setup a regular expression to find a word followed by a colon and then space
    // should get the first item (e.g. "From:").
    NSError * __autoreleasing error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:FROM_LABEL_REGEX_STRING
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    NSRange fromLabelRange = [regex
                              rangeOfFirstMatchInString:headerString.string
                              options:0
                              range:NSMakeRange(0, [headerString length])];
    
    MHLog(@"Match Range is: %@", NSStringFromRange(fromLabelRange));
    
    [headerString applyFontTraits:NSBoldFontMask range:fromLabelRange];
    
    // new regex and for loop to process the rest of the attribute names (e.g. Subject:, To:, Cc:, etc.)
    regex = [NSRegularExpression
             regularExpressionWithPattern:HEADER_LABEL_REGEX_STRING
             options:NSRegularExpressionCaseInsensitive
             error:&error];
    NSArray *matches = [regex
                        matchesInString:headerString.string
                        options:0
                        range:NSMakeRange(0, [headerString length])];
    
    for (NSTextCheckingResult *match in matches)
    {
        [headerString applyFontTraits:NSBoldFontMask range:[match range]];
    }
}

- (WebArchive *)getWebArchive
{
    MHLog(@"Mail string before web archiving it: %@", headerString);
    
    WebArchive *arch = [headerString
                        webArchiveForRange:NSMakeRange(0, [headerString length])
                        fixUpNewlines:YES];
    return arch;
}

- (int)getHeaderItemCount
{
    MHLog(@"Mail header count is %d", headerItemCount);
    
    return headerItemCount;
}

- (BOOL)isSuppressLabelsFound
{
    MHLog(@"Suppress Labels found: %@", isSuppressLabelsFound);
    
    return isSuppressLabelsFound;
}

- (NSString *)stringValue
{
    return headerString.string;
}

- (id)initWithString:(NSAttributedString *)header
{
    if (self = [super init])
    {
        NSArray *headers = [[header string]
                            componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSLog(@"Original values %@", headers);
        NSLog(@"Original values count %lu", (unsigned long)[headers count]);
        
        NSArray *allowedHeaders = [MailHeader getConfigValue:@"AllowedHeaders"];
        messageAttribution = [[NSMutableArray alloc] init];
        
        for (NSString *str in allowedHeaders)
        {
            for (int i=0; i<[headers count]; i++)
            {
                NSString *row = [headers objectAtIndex:i];
                if ([row hasPrefix:str]) {
                    [messageAttribution addObject:[row mutableCopy]];
                    break;
                }
            }
        }
        
        // reordering and labeling
        NSError * __autoreleasing error = nil;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\s<([a-zA-Z0-9_@\\.\\-]*)>,?"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        
        int subjectIndex = 1; // default position
        NSString *fromMailId;
        for (int i=0; i<[messageAttribution count]; i++)
        {
            NSMutableString *row = [messageAttribution objectAtIndex:i];
            
            if ([row hasPrefix:MHLocalizedString(@"STRING_FROM")]) {
                NSArray *matches = [regex
                                 matchesInString:row
                                 options:0
                                 range:NSMakeRange(0, [row length])];
                
                for (NSTextCheckingResult *match in matches)
                {                    
                    fromMailId = [row substringWithRange:[match rangeAtIndex:1]];
                    NSLog(@"From Email id %@", fromMailId);
                    
                    [row replaceCharactersInRange:[match range] withString:[NSString stringWithFormat:@" %@%@%@", @"[mailto:", fromMailId, @"]"]];
                }
            }
            
            if ([row hasPrefix:MHLocalizedString(@"STRING_SUBJECT")]) {
                subjectIndex = i;
            }
            
            if ([row hasPrefix:MHLocalizedString(@"STRING_DATE")]) {
                NSRange dRange = [row rangeOfString:MHLocalizedString(@"STRING_DATE")];
                
                if (dRange.location != NSNotFound) {
                    [row replaceCharactersInRange:dRange withString:MHLocalizedString(@"STRING_SENT")];
                }
            }
            
            NSRange range = [regex rangeOfFirstMatchInString:row options:0
                                                       range:NSMakeRange(0, [row length])];
            while (range.location != NSNotFound)
            {
                [row replaceCharactersInRange:range withString:@";"];
                range = [regex rangeOfFirstMatchInString:row options:0
                                                   range:NSMakeRange(0, [row length])];
            }            
            
            // double quoutes into empty
            range = [row rangeOfString:@"\""];
            while (range.location != NSNotFound)
            {
                [row replaceCharactersInRange:range withString:@""];
                range = [row rangeOfString:@"\""];
            }
        }
        
        NSMutableString *subject = [[messageAttribution objectAtIndex:subjectIndex] mutableCopy];
        [messageAttribution removeObjectAtIndex:subjectIndex];
        [messageAttribution addObject:subject];
        
        
        NSLog(@"After process Original values %@", messageAttribution);
        
        /*for (int i=0; i<[headers count]; i++)
        {
            NSString *str = [messageAttribution objectAtIndex:i];
            if ( str == (id)[NSNull null] || [str length] == 0 )
                [messageAttribution removeObject:str];
        }*/
        
        
    }

    return self;
}

- (id)initWithMailMessage:(id)mailMessage
{
    if (self = [super init])
    {
        if (!(self = [self init])) return nil;
        
        //initialze the value with a mutable copy of the attributed string
        headerString = [[[mailMessage originalMessageHeaders]
                         attributedStringShowingHeaderDetailLevel:[NSNumber numberWithInt:1]] mutableCopy];
        
        // let's things going
        [self fixHeaderString];
        [self findOutHeaderItemCount];
        [self suppressImplicateHeaderLabels];
    }
    else
    {
        MHLog(@"MHHeaderString: Init initWithMailMessage failed");
    }
    
    return self;
}


#pragma mark Class private methods

- (void)initVars
{
    headerItemCount = 1;
    isSuppressLabelsFound = NO;
}

// Workaround to get header item count
- (void)findOutHeaderItemCount
{
    NSError * __autoreleasing error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:HEADER_LABEL_REGEX_STRING
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSArray *matches = [regex
                        matchesInString:headerString.string
                        options:0
                        range:NSMakeRange(0, [headerString length])];
    
    headerItemCount += matches.count;
}

- (void)fixHeaderString
{
    NSRange range;
    range.location = 0;
    range.length = [headerString length];
    
    [headerString removeAttribute:NSFontAttributeName range:range];
    [headerString removeAttribute:NSForegroundColorAttributeName range:range];
    [headerString removeAttribute:NSParagraphStyleAttributeName range:range];
    
    [NSMutableAttributedString trimLeadingWhitespaceAndNewLine:headerString];
    [NSMutableAttributedString trimTrailingWhitespaceAndNewLine:headerString];    
}

- (void)suppressImplicateHeaderLabels
{
    NSRange range = [headerString.string
                     rangeOfString:MHLocalizedString(@"STRING_REPLY_TO")];
    if (range.location != NSNotFound)
    {
        isSuppressLabelsFound = YES;
        
        NSAttributedString *replaceString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
        [headerString
         replaceCharactersInRange:NSMakeRange(range.location, ([headerString length] - range.location)) withAttributedString:replaceString];
    }
}

- (void)applyHeaderOrderChange
{
    // Subject: and Date: sequence change
    NSRange subjectRange = [headerString.string rangeOfString:MHLocalizedString(@"STRING_SUBJECT")];
    NSRange dateRange = [headerString.string rangeOfString:MHLocalizedString(@"STRING_DATE")];
    
    if (subjectRange.location != NSNotFound && dateRange.location != NSNotFound) {
        NSRange subCntRange;
        subCntRange.location = subjectRange.location;
        subCntRange.length = dateRange.location - subjectRange.location;
        NSAttributedString *subAttStr = [headerString attributedSubstringFromRange:subCntRange];
        
        NSAttributedString *last = [headerString
                                    attributedSubstringFromRange:NSMakeRange([headerString length] - 1, 1)];
        if (![[last string] isEqualToString:@"\n"])
        {
            NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
            [headerString appendAttributedString:newLine];
        }
        
        // Subject: relocation
        [headerString appendAttributedString:subAttStr];
        
        // removal of old Subject:
        NSAttributedString *replaceString = [[NSAttributedString alloc] initWithString:@""];
        [headerString replaceCharactersInRange:subCntRange withAttributedString:replaceString];
    }
}

- (void)applyHeaderLabelChange
{
    // Date: into Sent:
    NSRange dRange = [headerString.string rangeOfString:MHLocalizedString(@"STRING_DATE")];
    
    if (dRange.location != NSNotFound) {
        [headerString replaceCharactersInRange:dRange withString:MHLocalizedString(@"STRING_SENT")];
    }
    
    
    // <email-id>, into ;
    NSError * __autoreleasing error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:QUOTED_EMAIL_REGEX_STRING
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSRange range = [regex
                     rangeOfFirstMatchInString:headerString.string
                     options:0
                     range:NSMakeRange(0, [headerString length])];    
    
    if (range.location != NSNotFound) {
        // captureing from email id for mailto:
        NSString *emailId = [headerString.string substringWithRange:range];
        // handling of mailto: for From: tag
        NSMutableAttributedString *fromMailId = [[NSMutableAttributedString alloc]
                                                  initWithString:emailId];
        [fromMailId replaceCharactersInRange:NSMakeRange(0, 2) withString:@" [mailto:"];
        [fromMailId replaceCharactersInRange:NSMakeRange(fromMailId.length - 1, 1) withString:@"]"];
        
        NSAttributedString *emlRplStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@";"]];
        while (range.length != 0)
        {
            [headerString replaceCharactersInRange:range withAttributedString:emlRplStr];
            range = [regex
                     rangeOfFirstMatchInString:headerString.string
                     options:0
                     range:NSMakeRange(0, [headerString length])];
        }
        
        // double quoutes into empty
        range = [headerString.string rangeOfString:@"\""];
        while (range.length != 0)
        {
            [headerString replaceCharactersInRange:range withString:@""];
            range = [headerString.string rangeOfString:@"\""];
        }
        
        // Insertion of from email id
        range = [headerString.string
                 rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        [headerString
         insertAttributedString:[fromMailId
                                 attributedSubstringFromRange:NSMakeRange(0, fromMailId.length)]
         atIndex:(range.location - 1)];
        
        // Perfection of semi-colon (;) handling stage 1
        regex = [NSRegularExpression
                 regularExpressionWithPattern:SEMICOLON_NEWLINE_REGEX_STRING
                 options:NSRegularExpressionCaseInsensitive
                 error:&error];
        range = [regex
                 rangeOfFirstMatchInString:headerString.string
                 options:0
                 range:NSMakeRange(0, [headerString length])];
        while (range.length != 0)
        {
            [headerString replaceCharactersInRange:range withString:@"\n"];
            range = [regex
                     rangeOfFirstMatchInString:headerString.string
                     options:0
                     range:NSMakeRange(0, [headerString length])];
        }
        
        // Perfection of semi-colon (;) handling stage 2
        NSString *last = [headerString.string substringWithRange:NSMakeRange([headerString length] - 1, 1)];
        if ([last isEqualToString:@";"])
        {
            [headerString replaceCharactersInRange:NSMakeRange([headerString length] - 1, 1) withString:@""];
        }
    }    
}

// For now it does outlook mail label ordering
- (void)applyHeaderLabelOptions
{
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( [MailHeader isLocaleSupported] ) {
        int headerOrderMode = GET_DEFAULT_INT(MHHeaderOrderMode);
        int headerLabelMode = GET_DEFAULT_INT(MHHeaderLabelMode);
        MHLog(@"Mail Header Order mode: %d and Label mode: %d", headerOrderMode, headerLabelMode);
        
        if (headerOrderMode == 2)
            [self applyHeaderOrderChange];
        
        if (headerLabelMode == 2)
            [self applyHeaderLabelChange];
    }
}

@end
