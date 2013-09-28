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
#import "NSAttributedString+MailAttributedStringToHTML.h"

@interface RwhMailHeaderString (RwhNoImplementation)
- (id)originalMessageHeaders;
- (NSFont *)userDefaultMessageFont;
- (NSMutableAttributedString *)attributedStringShowingHeaderDetailLevel:(id)level;
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
        
        headerString = [[[mailMessage originalMessageHeaders]
                            attributedStringShowingHeaderDetailLevel:1] mutableCopy];
        userDefaultFont = [mailMessage userDefaultMessageFont];
        
        RWH_LOG(@"Original mail string from backend: %@, and Defaut user font name: %@",
                mailHeaderString, [userDefaultFont fontName]);
        
        // let's things going
        [self fixHeaderString];
        [self findOutHeaderItemCount];
        [self suppressImplicateHeaderLabels];
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
    range.length = [headerString length];
    
    NSString *fontString = GET_DEFAULT_VALUE(RwhMailHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(RwhMailHeaderFontSize);
    NSFont *font = [NSFont fontWithName:fontString size:[fontSize floatValue]];
    
    NSColor *color = [NSUnarchiver unarchiveObjectWithData:GET_DEFAULT_DATA(RwhMailHeaderColor)];
    
    [headerString addAttribute:@"NSFont" value:font range:range];
    [headerString addAttribute:@"NSColor" value:color range:range];    
}

- (void)applyBoldFontTraits:(BOOL)isHeaderTypograbhyEnabled {
    RWH_LOG();
    
    if (!isHeaderTypograbhyEnabled) {
        [headerString
            addAttribute:@"NSFont"
            value:userDefaultFont
            range:NSMakeRange(0, [headerString length])];
    }
    
    // setup a regular expression to find a word followed by a colon and then space
    // should get the first item (e.g. "From:").
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange fromLabelRange = [regex rangeOfFirstMatchInString:[headerString string] options:0 range:NSMakeRange(0, [headerString length])];
    
    RWH_LOG(@"Match Range is: %@", NSStringFromRange(fromLabelRange));
    
    [headerString applyFontTraits:NSBoldFontMask range:fromLabelRange];
    
    //new regex and for loop to process the rest of the attribute names (e.g. Subject:, To:, Cc:, etc.)
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\n|\\r)[\\w\\-\\s]+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:[headerString string]
                                      options:0 range:NSMakeRange(0,[headerString length])];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        [headerString applyFontTraits:NSBoldFontMask range:matchRange];
    }
}

- (WebArchive *)getWebArchive {
    RWH_LOG(@"Mail string before web archiving it: %@", mailHeaderString);
    
    WebArchive *arch = [headerString
                        webArchiveForRange:NSMakeRange(0,[headerString length]) fixUpNewlines:YES];
      return arch;
}

- (int)getHeaderItemCount {
    RWH_LOG(@"Mail header count is %d", headerItemCount);
    
    return headerItemCount;
}

- (BOOL)isSuppressLabelsFound {
    RWH_LOG(@"Suppress Labels found: %@", isSuppressLabelsFound);
    
    return isSuppressLabelsFound;
}

- (NSString *)stringValue {
    return [headerString string];
}

- (void)dealloc {
    headerString = nil;
    headerItemCount=nil;
    
    free(headerString);
    free(headerItemCount);
    
    [super dealloc];
}


#pragma mark Class private methods

- (void)initVars {
    headerItemCount = 1;
}

// Workaround to get header item count
- (void)findOutHeaderItemCount {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\n|\\r)[\\w\\-\\s]+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:[headerString string]
                                      options:0 range:NSMakeRange(0,[headerString length])];
    
    headerItemCount = headerItemCount + [matches count];
}

- (void)fixHeaderString {
    RWH_LOG();
    
    NSRange range;
    range.location = 0;
    range.length = [headerString length];
    
    [headerString removeAttribute:@"NSFont" range:range];
    [headerString removeAttribute:@"NSColor" range:range];
    [headerString removeAttribute:@"NSParagraphStyle" range:range];
    
    [NSMutableAttributedString trimLeadingWhitespaceAndNewLine:headerString];
    [NSMutableAttributedString trimTrailingWhitespaceAndNewLine:headerString];    
}

- (void)suppressImplicateHeaderLabels {
    RWH_LOG();
    
    NSError *error = nil;
    NSRegularExpression *replyToRegex = [NSRegularExpression regularExpressionWithPattern:@"\\Reply-To:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange replyToMatch = [replyToRegex rangeOfFirstMatchInString:[headerString string] options:0 range:NSMakeRange(0, [headerString length])];
    
    if ( replyToMatch.location == NSNotFound ) {
        RWH_LOG(@"Reply To label doesn't found");
        
        isSuppressLabelsFound = NO;
    }
    else {
        isSuppressLabelsFound = YES;
        
        NSAttributedString *replaceString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@""]] autorelease];
        [headerString
            replaceCharactersInRange:NSMakeRange(replyToMatch.location, ([headerString length] - replyToMatch.location)) withAttributedString:replaceString];
    }
}

- (void)applyHeaderOrderChange {
    NSRange subjectRange = [[headerString string] rangeOfString:@"Subject: "];
    NSRange dateRange = [[headerString string] rangeOfString:@"Date: "];
    
    NSRange subCntRange;
    subCntRange.location = subjectRange.location;
    subCntRange.length = dateRange.location - subjectRange.location;
    NSAttributedString *subAttStr = [headerString attributedSubstringFromRange:subCntRange];
    
    NSAttributedString *last = [headerString
                                attributedSubstringFromRange:NSMakeRange(headerString.length - 1, 1)];
    if (![[last string] isEqualToString:@"\n"]) {
        NSAttributedString *newLine = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];
        [headerString appendAttributedString:newLine];
    }
    
    // Subject: relocation
    [headerString appendAttributedString:subAttStr];
    
    // removal of old Subject:
    NSAttributedString *replaceString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@""]] autorelease];
    [headerString replaceCharactersInRange:subCntRange withAttributedString:replaceString];    
}

- (void)applyHeaderLabelChange {
    // Date: into Sent:
    NSRange dRange = [[headerString string] rangeOfString:@"Date: "];
    [headerString replaceCharactersInRange:dRange withString:@"Sent: "];
    
    // <email-id>, into ;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\s<([A-Z][A-Z0-9]*)[^>]*>,?)" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSAttributedString *emlRplStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@";"]] autorelease];    
    NSRange range = [regex rangeOfFirstMatchInString:[headerString string]
                                             options:0 range:NSMakeRange(0, [headerString length])];
    
    while (range.length != 0) {        
        [headerString replaceCharactersInRange:range withAttributedString:emlRplStr];
        
        range = [regex rangeOfFirstMatchInString:[headerString string]
                                         options:0 range:NSMakeRange(0, [headerString length])];
    }
    
    // double quoutes into empty
    NSRange qtRange = [[headerString string] rangeOfString:@"\""];
    while (qtRange.length != 0) {
        [headerString replaceCharactersInRange:qtRange withString:@""];
        qtRange = [[headerString string] rangeOfString:@"\""];
    }    
}

// For now it does outlook mail label ordering
- (void)applyHeaderLabelOptions {
    
    int headerOrderMode = GET_DEFAULT_INT(RwhMailHeaderOrderMode);
    int headerLabelMode = GET_DEFAULT_INT(RwhMailHeaderLabelMode);
    RWH_LOG(@"Mail Header Order mode: %d and Label mode: %d", headerOrderMode, headerLabelMode);
    
    if (headerOrderMode == 2) {    
        [self applyHeaderOrderChange];
    }
    
    if (headerLabelMode == 2) {
        [self applyHeaderLabelChange];
    }
}

@end
