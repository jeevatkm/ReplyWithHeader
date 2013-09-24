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
//  MailHeaderString.m
//  RwhMailBundle
//
//  Created by Jason Schroth on 8/15/12.
//
//  RwhMailHeaderString Class completely rewritten by Jeevanandam M. on Sep 22, 2013

#import "RwhMailHeaderString.h"
#import "RwhMailConstants.h"
#import "RwhMailMacros.h"
#import "NSMutableAttributedString+RwhMailBundle.h"

@interface RwhMailHeaderString (PrivateMethods)
- (void)initVars;
- (void)fixHeaderStyles;
- (void)suppressReplyToLabel;

- (id)originalMessageHeaders;
- (NSMutableAttributedString *)attributedStringShowingHeaderDetailLevel:(id)level;
@end

@interface NSMutableAttributedString ()
- (WebArchive *)webArchiveForRange:(NSRange)range fixUpNewlines:(BOOL)newLineFix;
@end

@implementation RwhMailHeaderString

#pragma mark Class public methods

- (id)init {
    if (self = [super init]) {
        // postive lines go here
        
        [self initVars];
    }
    else {
        RWH_LOG(@"MailHeaderString: Init failed");
    }
    return self;
}

- (id)initWithMailMessage:(id)mailMessage {
    RWH_LOG();
    
    //initialze the value with a mutable copy of the attributed string
    if (self = [super init]) {
        [self init];
        
        mailHeaderString = [[[mailMessage originalMessageHeaders] attributedStringShowingHeaderDetailLevel:1] mutableCopy];
        
        [self fixHeaderStyles];
        [self suppressReplyToLabel];
        
        RWH_LOG(@"MailHeaderString: created headstr: %@",headstr);
    }
    else {
        RWH_LOG(@"MailHeaderString: Init initWithMailMessage failed");
    }
    
    return self;
}

- (void)applyHeaderTypography {
    RWH_LOG();
    
    NSRange range;
    range.location = 0;
    range.length = [mailHeaderString length];
    
    NSString *fontString = GET_DEFAULT_VALUE(RwhMailHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(RwhMailHeaderFontSize);
    NSFont *font = [NSFont fontWithName:fontString size:[fontSize floatValue]];
    
    NSColor *color=[NSUnarchiver unarchiveObjectWithData:GET_DEFAULT_DATA(RwhMailHeaderFontColor)];
    
    [mailHeaderString addAttribute:@"NSFont" value:font range:range];
    [mailHeaderString addAttribute:@"NSColor" value:color range:range];
}

- (void)applyBoldFontTraits {
    RWH_LOG();
    
    // setup a regular expression to find a word followed by a colon and then space
    // should get the first item (e.g. "From:").
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange fromLabelMatchRange = [regex rangeOfFirstMatchInString:[mailHeaderString string] options:0 range:NSMakeRange(0, [mailHeaderString length])];
    
    RWH_LOG(@"Match Range is: %@", NSStringFromRange(fromLabelMatchRange));
    
    [mailHeaderString applyFontTraits:NSBoldFontMask range:fromLabelMatchRange];
    
    //new regex and for loop to process the rest of the attribute names (e.g. Subject:, To:, Cc:, etc.)
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\n|\\r)[\\w\\-\\s]+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches=[regex matchesInString:[mailHeaderString string] options:0 range:NSMakeRange(0,[mailHeaderString length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        [mailHeaderString applyFontTraits:NSBoldFontMask range:matchRange];
        
        // workaround to get header count
        headerItemCount++;
    }
}

- (WebArchive *)getWebArchive {
    RWH_LOG();
    
    [NSMutableAttributedString trimLeadingWhitespaceAndNewLine:mailHeaderString];
    [NSMutableAttributedString trimTrailingWhitespaceAndNewLine:mailHeaderString];
    
    WebArchive *arch = [mailHeaderString webArchiveForRange:NSMakeRange(0,[mailHeaderString length]) fixUpNewlines:YES];
    
    return arch;
}

- (int)getHeaderItemCount {
    RWH_LOG(@"Mail header count is %d", headerItemCount);
    
    return headerItemCount;
}

- (BOOL)isReplyToLabelFound {
    RWH_LOG(@"Reply-To Label found : %@", isReplyToLabelFound);
    
    return replyToLabelFound;
}

- (NSString *)stringValue {
    return [mailHeaderString string];
}

- (void)dealloc {
    mailHeaderString = nil;
    headerItemCount=nil;
    
    free(mailHeaderString);
    free(headerItemCount);
    
    [super dealloc];
}


#pragma mark Class private methods

- (void)initVars {
    headerItemCount = 1;
}

- (void)fixHeaderStyles {
    RWH_LOG();
    
    [mailHeaderString removeAttribute:@"NSColor" range:NSMakeRange(0,[mailHeaderString length])];
    [mailHeaderString removeAttribute:@"NSParagraphStyle" range:NSMakeRange(0,[mailHeaderString length])];
}

- (void)suppressReplyToLabel {
    RWH_LOG();
    
    NSError *error = NULL;
    NSRegularExpression *replyToRegex = [NSRegularExpression regularExpressionWithPattern:@"\\Reply-To:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange replyLabelMatch = [replyToRegex rangeOfFirstMatchInString:[mailHeaderString string] options:0 range:NSMakeRange(0, [mailHeaderString length])];
    
    if ( replyLabelMatch.location == NSNotFound ) {
        RWH_LOG(@"Reply To label doesn't found");
        
        replyToLabelFound = NO;
    }
    else {
        replyToLabelFound = YES;
        
        NSAttributedString *replaceString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@""]];
        
        [mailHeaderString replaceCharactersInRange:NSMakeRange(replyLabelMatch.location, ([mailHeaderString length] - replyLabelMatch.location))
                     withAttributedString:replaceString];
        
        [replaceString release];
    }
}

@end
