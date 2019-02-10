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


//  MHQuotedMailOriginal.m
//  MailHeader
//
//  Created by Jason Schroth on 8/16/12.
//
//  MHQuotedMailOriginal Class refactored & completely rewritten by Jeevanandam M. on Sep 22, 2013

#import <WebKit/DOMHTMLBRElement.h>
#import <WebKit/DOMDocumentFragment.h>
#import <WebKit/DOMHTMLDivElement.h>
#import <WebKit/DOMHTMLDocument.h>
#import <WebKit/DOMHTMLCollection.h>
#import <WebKit/DOMNodeList.h>
#import <WebKit/DOMElement.h>

#import "MHQuotedMailOriginal.h"
#import "MHHeaderString.h"
#import "NSString+MailHeader.h"

@interface MHQuotedMailOriginal (MHNoImplementation)
- (id)htmlDocument;
- (DOMDocumentFragment *)createDocumentFragmentWithMarkupString: (NSString *)str;
- (id)descendantsWithClassName:(NSString *)str;
- (DOMDocumentFragment *)createFragmentForWebArchive:(WebArchive *)webArch;
- (BOOL)hasContents;
- (BOOL)containsRichText;
@end

@interface DOMNode ()
@property(readonly) unsigned childElementCount;
@property(copy) NSString *outerHTML;
- (NSString *)stringValue;
@end

NSString *ApplePlainTextBody = @"ApplePlainTextBody";
NSString *AppleOriginalContents = @"AppleOriginalContents";
NSString *AppleMailSignature = @"AppleMailSignature";
NSString *WROTE_TEXT_REGEX_STRING = @":\\s*(\\n|\\r)";
NSString *TAG_BLOCKQUOTE = @"BLOCKQUOTE";

@implementation MHQuotedMailOriginal

#pragma mark Class instance methods

- (void)insertForHTMLMail:(DOMDocumentFragment *)headerFragment
{
    if ([self isBlockquoteTagPresent])
    {
        DOMNode *nodeRef = [self getBlockquoteTagNode];
        [nodeRef insertBefore:headerFragment refChild:[nodeRef firstChild]];
        if (GET_DEFAULT_BOOL(MHHeaderBlueLineBorderEnabled))
        {
            [nodeRef insertBefore:headerBorder refChild:[nodeRef firstChild]];
        }
    }
    else
    {
        [originalEmail insertBefore:headerFragment refChild: [originalEmail firstChild]];
        if (GET_DEFAULT_BOOL(MHHeaderBlueLineBorderEnabled))
        {
            [originalEmail insertBefore:headerBorder refChild: [originalEmail firstChild]];
        }
    }
}

- (void)insertForPlainMail:(DOMDocumentFragment *)headerFragment
{
    if (textNodeLocation >= 0)
    {
        if ([self isBlockquoteTagPresent]) // include inside blockquote
        {
            DOMNode *nodeRef = [self getBlockquoteTagNode];
            [nodeRef insertBefore:headerFragment refChild:[nodeRef firstChild]];
            [nodeRef insertBefore:headerBorder refChild:[nodeRef firstChild]];
        }
        else // Insert before br/#text element ( [[nodeRef nodeName] isEqualToString:@"BR"] || [[nodeRef nodeName] isEqualToString:@"#text"] )
        {
            [originalEmail insertBefore:headerFragment refChild:[dhc item:textNodeLocation]];
            [originalEmail insertBefore:headerBorder refChild:[dhc item:textNodeLocation]];
        }
    }
}

- (void)insertMailHeader:(MHHeaderString *)mailHeader
{
    
    //if (GET_DEFAULT_BOOL(MHHeaderOptionEnabled))
    //{
        [mailHeader applyHeaderLabelOptions];
    //}
    
    if (isHTMLMail)
    {
        [mailHeader applyHeaderTypography];
    }
    
    // specifics
    BOOL manageForwardHeader = GET_DEFAULT_BOOL(MHForwardHeaderEnabled);
    DOMDocumentFragment *headerFragment = nil;
    
    if ([MailHeader isElCapitanOrGreater]) {
        MHLog(@"It's EL capitan or greater, handle accordingly");
        headerFragment = [self paragraphTagToSpanTagByString:[mailHeader getHTML]];
    } else {
        headerFragment = [[document htmlDocument] createFragmentForWebArchive:[mailHeader getWebArchive]];
        
        // for issue #64
        //headerFragment = [self paragraphTagToSpanTag:headerFragment];
        headerFragment = [self paragraphTagToSpanTagByString:[[headerFragment firstChild] outerHTML]];
    }
    
    [(DOMElement *)[headerFragment firstChild] setAttribute:@"id" value:@"RwhHeaderAttributes"];
    
    MHLog(@"Header HTML %@", [[headerFragment firstChild] outerHTML]);
    
    if (msgComposeType == 1 || msgComposeType == 2 || (manageForwardHeader && msgComposeType == 3))
    {
        
        MHLog(@"Before header insert, Inner HTML String:: %@", [originalEmail innerHTML]);
        if ( isHTMLMail )
        {
            [self insertForHTMLMail:headerFragment];
        }
        else // Plain text mail compose block
        {
            [self insertForPlainMail:headerFragment];
        }
        
        // Line space
        // https://github.com/jeevatkm/ReplyWithHeader/issues/84
        int linesBeforeSep = GET_DEFAULT_INT(MHLineSpaceBeforeHeaderSeparator);
        for (int i=0; i<linesBeforeSep; i++) {
            DOMDocumentFragment *brFragment = [self createDocumentFragment:@"<br>"];
            [originalEmail insertBefore:brFragment refChild: [originalEmail firstChild]];
        }
        
        MHLog(@"After header insert, Inner HTML String:: %@", [originalEmail innerHTML]);
    }
}

- (id)initWithMailMessage:(id)mailMessage msgComposeType:(int)composeType
{
    if ( self = [super init] )
    {
        document = [mailMessage document];        
        msgComposeType = composeType;
        
        MHLog(@"Mail Document: %@", document);
        MHLog(@"Composing message type is %d", msgComposeType);
        MHLog(@"Complete HTML string %@", [[[document htmlDocument] body] innerHTML]);
        
        //now initialize the other vars
        [self initVars];
        
        //if there is not a child in the original email, it must be plain text
        if ([originalEmail firstChild] == nil || !isHTMLMail)
        {
            //prep the plain text
            [self prepareQuotedPlainText];
        }
        
        //now that the email is set... set the child nodes
        dhc = [originalEmail childNodes];
        
        //identifying blockquote tag
        MHLog(@"isBlockquotePresent = %@", [self isBlockquoteTagPresent] ? @"YES" : @"NO");
        
        //now get the quoted content and remove the first part (where it says "On ... X wrote"
        // "... message"
        if (dhc.length >= 1)
        {
            if (isHTMLMail)
                [self removeHTMLHeaderPrefix];
            else
                [self removePlainTextHeaderPrefix];
        }
    }
    
    return self;
}


#pragma mark Class private methods

- (void)initVars
{
    if ([MailHeader isSierraOrGreater])
    {
        // OS Sierra improvements, Apple made complicated to detect HTML vs Plain
        // So, first try HTML and fallback to Plain Text email.
        // I feed sad for Plain text mail users.
        if ([[document htmlDocument] descendantsWithClassName:AppleOriginalContents] != NULL
            || [[document htmlDocument] descendantsWithClassName:AppleOriginalContents] != nil)
        {
            isHTMLMail = YES;
            originalEmail=[[[document htmlDocument]
                            descendantsWithClassName:AppleOriginalContents] objectAtIndex:0];
        }
        else
        {
            isHTMLMail = NO;
            originalEmail=[[[document htmlDocument]
                            descendantsWithClassName:ApplePlainTextBody] objectAtIndex:0];
        }
    }
    else
    {
        // identifying is this plain or html mail compose in reply or reply all;
        // forward mail is not our compose since it falls
        // into default setting of compose type in user mail client
        // AppleOriginalContents: (isHTMLMail=YES) | ApplePlainTextBody: (isHTMLMail=NO)
        if ([[document htmlDocument] descendantsWithClassName:ApplePlainTextBody] == NULL
            || [[document htmlDocument] descendantsWithClassName:ApplePlainTextBody] == nil)
        {
            isHTMLMail = YES;
            originalEmail=[[[document htmlDocument]
                            descendantsWithClassName:AppleOriginalContents] objectAtIndex:0];
        }
        else
        {
            isHTMLMail = NO;
            originalEmail=[[[document htmlDocument]
                            descendantsWithClassName:ApplePlainTextBody] objectAtIndex:0];
        }
    }
    
    MHLog(@"Composing mail isHTMLMail %@", (isHTMLMail ? @"YES" : @"NO"));
    
    NSString *borderString = (isHTMLMail) ?
                                MHHeaderBorder : (msgComposeType == 3)
                                    ? MHDefaultForwardHeaderBorder : MHDefaulReplyHeaderBorder;
    
    MHLog(@"initVars Header border text: %@", borderString);
    
    // now initialze header border string into html form
    headerBorder = [self createDocumentFragment:borderString];
    
    textNodeLocation = 0;
}

- (void)removePlainTextHeaderPrefix
{
    DOMNodeList *nodeList;
    DOMHTMLElement *emailDocument;
    
    if (([MailHeader isYosemite] || [MailHeader isElCapitanOrGreater]) && [self isBlockquoteTagPresent])
    {
        emailDocument = (DOMHTMLElement *)[self getBlockquoteTagNode];
        nodeList = [emailDocument childNodes];
    }
    else
    {
        nodeList = dhc;
        emailDocument = (DOMHTMLElement *)originalEmail;
    }
    
    for (int i=0; i < nodeList.length; i++)
    {
        DOMNode *node = [nodeList item:i];
        MHLog(@"current location %d, nodeType %d, nodeName %@", i, [node nodeType], [node nodeName]);
        
        if ([node nodeType] == 3) // Text node, On ..., Wrote is text
        {
            MHLog(@"Text Node found at %d, name is %@", i, [node nodeName]);
            textNodeLocation = i; break;
        }
    }
    
    @try {
        // if signature at top, item==3 else item==1
        [emailDocument removeChild:[nodeList item:textNodeLocation]];
        
        while ([[[nodeList item:textNodeLocation] nodeName] isEqualToString:@"BR"]) {
            [emailDocument removeChild:[nodeList item:textNodeLocation]];
        }
    }
    @catch (NSException *exception) {
        MHLog([exception description]);
    }
    
    //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
    for (int i=0; i<[emailDocument childElementCount]; i++)
    {
        if ( [[[[emailDocument childNodes] item:i] nodeName] isEqualToString:TAG_BLOCKQUOTE] ) //this is the quoted text
        {
            textNodeLocation = i; break;
        }
    }
    
    MHLog(@"New header location for Plain Text mail is %d", textNodeLocation);
}

- (void)removeHTMLHeaderPrefix
{
    DOMNodeList *nodeList;
    DOMHTMLElement *emailDocument;
    
    if ([MailHeader isYosemite] && [self isBlockquoteTagPresent])
    {
        emailDocument = (DOMHTMLElement *)[self getBlockquoteTagNode];
        nodeList = [emailDocument childNodes];
    }
    else
    {
        nodeList = dhc;
        emailDocument = (DOMHTMLElement *)originalEmail;
    }
    
    @try {
        if ([MailHeader isSpecificLocale]) // Need specific handling
        {
            MHLog(@"Handling specific locale by Range matching");
            NSString *searchString = MHLocalizedStringByLocale(@"STRING_WROTE", MHLocaleIdentifier);
            if (msgComposeType == 3)
            {
                searchString = MHLocalizedStringByLocale(@"STRING_FORWARDED_MESSAGE", MHLocaleIdentifier);
            }
            
            NSRange textRange = [[[emailDocument firstChild] stringValue] rangeOf:searchString];
            
            while (textRange.location == NSNotFound)
            {
                [emailDocument removeChild:[emailDocument firstChild]];
                textRange = [[[emailDocument firstChild] stringValue] rangeOf:searchString];
            }
        }
        else // Rest of the locale, feasible to take care by regex
        {
            MHLog(@"Handling remaining locale by Regex");
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:WROTE_TEXT_REGEX_STRING
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            NSRange textRange = [regex
                                 rangeOfFirstMatchInString:[[emailDocument firstChild] stringValue]
                                 options:0
                                 range:NSMakeRange(0, [[[emailDocument firstChild] stringValue] length])];
            MHLog(@"Before while loop, Text range is %@", NSStringFromRange(textRange));
            
            //keep removing items until we find the "wrote:" text...
            while ( textRange.location == NSNotFound )
            {
                [emailDocument removeChild:[emailDocument firstChild]];
                textRange = [regex
                             rangeOfFirstMatchInString:[[emailDocument firstChild] stringValue]
                             options:0
                             range:NSMakeRange(0, [[[emailDocument firstChild] stringValue] length])];
                MHLog(@"Text range is %@", NSStringFromRange(textRange));
            }
        }
        
        DOMNode *node = [[emailDocument firstChild] firstChild];
        //remove the line with the "wrote:" text
        if (node)
        {
            MHLog(@"Node name: %@, Node Type: %hu, Node Value: %@", [node nodeName], [node nodeType], [node stringValue]);
            [[emailDocument firstChild] removeChild:node];
        }
        
        // remove the first new line element to shorten the distance between the new email and quoted text
        // this is required in order to get the header inside the quoted text line
        while ([[[emailDocument firstChild] nodeName] isEqualToString:@"BR"]) {
            [emailDocument removeChild:[emailDocument firstChild]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"RWH %@", [exception reason]);
    }
}

- (void)prepareQuotedPlainText
{
    originalEmail=[[[document htmlDocument]
                    descendantsWithClassName:ApplePlainTextBody] objectAtIndex:0];
    
    MHLog(@"Original plain email: %@", originalEmail);
    
    if ( [[originalEmail idName] isEqualToString:AppleMailSignature] )
    {
        int itemNum = 2;
        
        //check that the second child isn't a break element and if so, go to the child 3
        if ( [[[[originalEmail children] item:itemNum] outerHTML] isEqualToString:@"<br>"] )
        {
            itemNum = 3;
        }
        
        originalEmail = (id)[[originalEmail children] item:itemNum];
    }
}

- (BOOL)isBlockquoteTagPresent
{
    return !GET_DEFAULT_BOOL(@"SupressQuoteBarsInComposeWindows");
}

- (DOMNode *)getBlockquoteTagNode
{
    MHLog(@"No of child nodes: %d", dhc.length);
    for (int i=0; i < dhc.length; i++)
    {
        if ([[[dhc item:i] nodeName] isEqualToString:TAG_BLOCKQUOTE])
        {
            MHLog(@"getBlockquoteTagNode:: %@ Node found at %d", TAG_BLOCKQUOTE, i);
            return [dhc item:i];
        }
    }
    
    return nil;
}

- (DOMDocumentFragment *)paragraphTagToSpanTag:(DOMDocumentFragment *) headerFragment
{
    NSString *htmlString = [[headerFragment firstChild] outerHTML];
    
    return [self paragraphTagToSpanTagByString:htmlString];
}

- (DOMDocumentFragment *)paragraphTagToSpanTagByString:(NSString *) htmlString
{
    //NSString *htmlString = [[headerFragment firstChild] outerHTML];
    MHLog(@"Paragraph based HTML string %@", htmlString);
    
    if (isHTMLMail)
    {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<p"
                                                           withString:@"<span"
                                                              options:1 range:NSMakeRange(0, [htmlString length])];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>"
                                                           withString:@"</span><br>"
                                                              options:1 range:NSMakeRange(0, [htmlString length])];
    }
    else
    {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"<[^pP].*?>"
                                      options:NSRegularExpressionCaseInsensitive error:&error];
        htmlString = [regex stringByReplacingMatchesInString:htmlString
                                                             options:0
                                                               range:NSMakeRange(0, [htmlString length])
                                                        withTemplate:@"<div>"];
        
        regex = [NSRegularExpression
                 regularExpressionWithPattern:@"</[^pP]>"
                 options:NSRegularExpressionCaseInsensitive error:&error];
        htmlString = [regex stringByReplacingMatchesInString:htmlString
                                                     options:0
                                                       range:NSMakeRange(0, [htmlString length])
                                                withTemplate:@"</div><br>"];
        
        htmlString = [NSString stringWithFormat:@"%@%@", htmlString, @"<br>"];
    }

    MHLog(@"Span based HTML string %@", htmlString);
    
    // Adding Line Space
    // https://github.com/jeevatkm/ReplyWithHeader/issues/84
    int linesBefore = GET_DEFAULT_INT(MHLineSpaceBeforeHeader);
    for (int i=0; i<linesBefore; i++)
    {
        htmlString = [NSString stringWithFormat:@"%@%@", @"<br>", htmlString];
    }
    
    int linesAfter = GET_DEFAULT_INT(MHLineSpaceAfterHeader);
    for (int i=0; i<linesAfter; i++)
    {
        htmlString = [NSString stringWithFormat:@"%@%@", htmlString, @"<br>"];
    }
    
    return [self createDocumentFragment:htmlString];
}

- (DOMDocumentFragment *)createDocumentFragment:(NSString *)htmlString
{
    return [[document htmlDocument]
            createDocumentFragmentWithMarkupString:htmlString];
}

@end
