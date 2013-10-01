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


//  MailQuotedOriginal.m
//  RwhMailBundle
//
//  Created by Jason Schroth on 8/16/12.
//
//  RwhMailQuotedOriginal Class completely rewritten by Jeevanandam M. on Sep 22, 2013

#import "RwhMailQuotedOriginal.h"
#import "WebKit/DOMHTMLBRElement.h"

@interface RwhMailQuotedOriginal (RwhNoImplementation)
- (id)htmlDocument;
- (DOMDocumentFragment *)createDocumentFragmentWithMarkupString: (NSString *)str;
- (id)descendantsWithClassName:(NSString *)str;
- (DOMDocumentFragment *)createFragmentForWebArchive:(WebArchive *)webArch;
@end

@interface DOMNode ()
@property(readonly) unsigned childElementCount;
@property(copy) NSString *outerHTML;
- (NSString *)stringValue;
@end

NSString *ApplePlainTextBody = @"ApplePlainTextBody";
NSString *AppleOriginalContents = @"AppleOriginalContents";
NSString *AppleMailSignature = @"AppleMailSignature";

@implementation RwhMailQuotedOriginal

#pragma mark Class public methods

- (id)init {
    if (self = [super init]) {
        //good stuff...
    }
    else {
        RWH_LOG(@"RwhMailQuotedOriginal: Init failed");
    }
    return self;
}

- (id)initWithMailMessage:(id)mailMessage {
    //initialze the value with a mutable copy of the attributed string
    if ( self = [super init] ) {
		//set the class document variable
        document = [mailMessage document];
        
        RWH_LOG(@"Mail Document: %@", document);
        
        //now initialize the other vars
        [self initVars];
        
        //if there is not a child in the original email, it must be plain text
        if ([originalEmail firstChild]==NULL || !isHTMLMail) {            
            //prep the plain text
            [self prepareQuotedPlainText];
        }
        
        //now that the email is set... set the child nodes
        dhc = [originalEmail childNodes];
        
        //now get the quoted content and remove the first part (where it says "On ... X wrote"
        if ( dhc.length > 1) {
            RWH_LOG(@"EXP initWithMailMessage before %@", [originalEmail innerHTML]);
            
            if (isHTMLMail) {
                [self removeOriginalHeaderPrefix];
            }
            else {
                [self removeOriginalPlainTextHeaderPrefix];
            }
            
            RWH_LOG(@"EXP initWithMailMessage after %@", [originalEmail innerHTML]);
        }
    }
    else {
        RWH_LOG(@"RwhMailQuotedOriginal: initWithMailMessage failed");
    }
    
    return self;
}

- (void)processHTMLMail:(DOMDocumentFragment *)headerFragment newLineFragment:(DOMDocumentFragment *)newLineFragment {
    //depending on the options selected to increase quote level or whatever, a reply might not have a grandchild from the first child
    //so we need to account for that... man this gets complicated... so if it is a textnode, there are no children... :(
    //so account for that too
    int numGrandChildCount = 0;
    if ( ![ [[originalEmail firstChild] nodeName] isEqualToString:@"#text"] ) {
        numGrandChildCount = [[originalEmail firstChild] childElementCount];
    }
    
    RWH_LOG(@"Num of grand children %d=(Type %d) %@\n%@\n", numgrandchild, [[originalEmail firstChild] nodeType], [originalEmail firstChild], [[originalEmail firstChild] nodeName]);
    
    if ( numGrandChildCount == 0 ) {
        [originalEmail insertBefore:newLineFragment refChild: [originalEmail firstChild]];
        [originalEmail insertBefore:headerFragment refChild: [originalEmail firstChild]];
        [originalEmail insertBefore:headerBorder refChild: [originalEmail firstChild]];
    }
    else {
        [[originalEmail firstChild] insertBefore:newLineFragment refChild: [[originalEmail firstChild] firstChild]];
        
        [[originalEmail firstChild] insertBefore:headerFragment refChild: [[originalEmail firstChild] firstChild]];
        
        [[originalEmail firstChild] insertBefore:headerBorder refChild: [[originalEmail firstChild] firstChild]];
    }
}

- (void)processPlainMail:(DOMDocumentFragment *)headerFragment newLineFragment:(DOMDocumentFragment *)newLineFragment {
    if ( textNodeLocation > 0 ) {
        //check if this is plain text by seeing if textNodeLocation points to a br element...
        //  if not, include in blockquote
        if ( [[[[originalEmail childNodes] item:textNodeLocation] nodeName] isEqualToString:@"BR"] ) {
            [originalEmail insertBefore:newLineFragment refChild:[dhc item:textNodeLocation]];
            [originalEmail insertBefore:headerFragment refChild:[dhc item:textNodeLocation]];
            [originalEmail insertBefore:headerBorder refChild:[dhc item:textNodeLocation]];
        }
        else {
            //[[[originalEmail childNodes] item:textNodeLocation] insertBefore:newLineFragment refChild:[[[originalEmail childNodes] item:textNodeLocation] firstChild]];
            
            [[[originalEmail childNodes] item:textNodeLocation] insertBefore:headerFragment refChild:[[[originalEmail childNodes] item:textNodeLocation] firstChild]];
            
            [[[originalEmail childNodes] item:textNodeLocation] insertBefore:headerBorder refChild:[[[originalEmail childNodes] item:textNodeLocation] firstChild]];
        }
    }
}

- (void)insertMailHeader:(RwhMailHeaderString *)mailHeader msgComposeType:(int)composeType {    
    RWH_LOG(@"Composing message type is %d", composeType);
    
    // global
    if (GET_DEFAULT_BOOL(RwhMailHeaderOptionModeEnabled)) {
        [mailHeader applyHeaderLabelOptions];
    }
    
    BOOL isHeaderTypograbhyEnabled = GET_DEFAULT_BOOL(RwhMailHeaderTypographyEnabled);
    if (isHeaderTypograbhyEnabled && isHTMLMail) {
        [mailHeader applyHeaderTypography];
    }
    
    if (isHTMLMail) {
        [mailHeader applyBoldFontTraits:isHeaderTypograbhyEnabled];
    }
    
    // specifics
    BOOL manageForwardHeader = GET_DEFAULT_BOOL(RwhMailForwardHeaderEnabled);
    DOMDocumentFragment *headerFragment = [[document htmlDocument] createFragmentForWebArchive:[mailHeader getWebArchive]];
    DOMDocumentFragment *newLineFragment = [self createDocumentFragment:@"<br />"];
    
    RWH_LOG(@"Newly processed RWH header: %@", [mailHeader stringValue]);
    
    // Entourage 2004 text size transformations
    if (GET_DEFAULT_BOOL(RwhMailEntourage2004SupportEnabled)) {
        [self applyEntourage2004Support:headerFragment];
    }
    
    if (composeType == 1 || composeType == 2) {
        if ( isHTMLMail ) {
            [self processHTMLMail:headerFragment newLineFragment:newLineFragment];
        }
        else { // Plain text mail compose block
            [self processPlainMail:headerFragment newLineFragment:newLineFragment];
        }
    }
    else if (manageForwardHeader && composeType == 3) {
        int hCount = [mailHeader getHeaderItemCount];
        for (int i=0; i<=hCount; i++) {
            [originalEmail removeChild:[originalEmail firstChild]];
        }
        
        if ( isHTMLMail ) {
            [self processHTMLMail:headerFragment newLineFragment:newLineFragment];
        }
        else { // Plain text mail compose block
            [self processPlainMail:headerFragment newLineFragment:newLineFragment];
        }
    }
}


#pragma mark Class private methods

- (void)initVars {
    // identifying is this plain or html mail compose in reply or reply all;
    // forward mail is not our compose since it falls
    // into default setting of compose type in user mail client
    // AppleOriginalContents: (isHTMLMail=YES) | ApplePlainTextBody: (isHTMLMail=NO)
    if ([[document htmlDocument] descendantsWithClassName:ApplePlainTextBody] == NULL) {
        isHTMLMail = YES;
        
        originalEmail=[[[document htmlDocument]
                        descendantsWithClassName:AppleOriginalContents] objectAtIndex:0];
    }
    else {
        isHTMLMail = NO;
        
        originalEmail=[[[document htmlDocument]
                        descendantsWithClassName:ApplePlainTextBody] objectAtIndex:0];
    }
    
    RWH_LOG(@"Composing mail isHTMLMail %d", isHTMLMail);
    
    NSString *borderString = (isHTMLMail) ? RwhMailHeaderBorderText : RwhMailDefaultReplyHeaderText;
    
    RWH_LOG(@"initVars Header border text: %@", borderString);
    
    // now initialze header border string into html form
    headerBorder = [self createDocumentFragment:borderString];
    
    textNodeLocation = 0;
}

- (void)removeOriginalPlainTextHeaderPrefix {    
    BOOL isLocationFound = NO;
    
    for (int i=0; i<dhc.length; i++) {
        DOMNode *node = [dhc item:i];        
        NSRange range = [[[node firstChild] stringValue] rangeOfString:@"wrote:"];
        
        if (range.length != 0) {
            [[node firstChild] setTextContent:@""];
            textNodeLocation = i;
            isLocationFound = YES;
            break;
        }
    }
    
    if (!isLocationFound) { // kept for backward workaround, however need a revisit
        for (int i=0; i < dhc.length; i++) {
            if( [[dhc item:i] nodeType]==3 ) {
                // Text node, On ..., Wrote is text
                textNodeLocation=i; break;
            }
        }
        
        // if signature at top, item==3 else item==1
        [originalEmail removeChild:[dhc item:textNodeLocation]];
        
        //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
        for (int i=0; i<[originalEmail childElementCount]; i++) {
            if( [[[[originalEmail childNodes] item:i] nodeName] isEqualToString:@"BLOCKQUOTE"] ) {
                //this is the quoted text
                textNodeLocation=i;
                break;
            }
        }
    }
    
    RWH_LOG(@"New header location for Plain Text mail is %d", textNodeLocation);
}

- (void)removeOriginalHeaderPrefix {
    
    //Mountain Lion created the issue on new messages and "wrote" appears in a new div when replying
    // on those messages that arrive after mail.app is opened - so we'll just keep removing items
    // from the beginnning until we find the element that has the "wrote:" text in it.
    
    //unfortunately, there is no containsString routine so we have to do it by using a range.
    // this method is documented at http://mobiledevelopertips.com/cocoa/nsrange-and-nsstring-objects.html
    
    //setup a regular expression to find a colon followed by some space and a new line -
    // the first one should be the original line...
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":\\s*(\\n|\\r)" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange textRange = [regex rangeOfFirstMatchInString:[[originalEmail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[originalEmail firstChild] stringValue] length])];
    
    //keep removing items until we find the "wrote:" text...
    while ( textRange.location == NSNotFound ) {
        RWH_LOG(@"Range is: %@", NSStringFromRange(textRange));
        RWH_LOG(@"Length: %ld Text: %@",[[[originalEmail firstChild] stringValue] length],[[originalEmail firstChild] stringValue]);
        
        [originalEmail removeChild:[dhc item:0]];
        textRange = [regex rangeOfFirstMatchInString:[[originalEmail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[originalEmail firstChild] stringValue] length])];
    }
    
    //remove the line with the "wrote:" text
    [originalEmail removeChild:[dhc item:0]];
    
    //remove the first new line element to shorten the distance between the new email and quoted text
    // this is required in order to get the header inside the quoted text line
    if ([[[originalEmail firstChild] nodeName] isEqualToString:@"BR"]) {
        
        [originalEmail removeChild:[originalEmail firstChild]];
        
        RWH_LOG(@"Removed BR element, only %d children left",[originalEmail childElementCount]);
    }    
}

- (void)prepareQuotedPlainText {    
    originalEmail=[[[document htmlDocument]
                        descendantsWithClassName:ApplePlainTextBody] objectAtIndex:0];
    
    RWH_LOG(@"Original plain email: %@", originalEmail);
    
    if( [[originalEmail idName] isEqualToString:AppleMailSignature] ) {
        int itemNum = 2;
        
        //DOMNode *mailNode = [[originalEmail children] item:itemNum];
        
        //check that the second child isn't a break element and if so, go to the child 3
        if( [[[[originalEmail children] item:itemNum] outerHTML] isEqualToString:@"<br>"] ) {
            itemNum = 3;
        }
        
        originalEmail = (id)[[originalEmail children] item:itemNum];
    }
}

- (void)applyEntourage2004Support:(DOMDocumentFragment *) headerFragment {
    
    //kind of silly, but this code is required so that the adulation appears correctly in Entourage 2004
    //2004 would interpret the paragraph tag and ignore the specified style information creating large spaces
    //between line items
    DOMNodeList *fragmentNodes = [[headerFragment firstChild] childNodes];
    
    for(int i=0; i< fragmentNodes.length;i++) {
        RWH_LOG(@"Frag node %d: (Type %d) %@ %@ %@",i, [[fragnodes item:i] nodeType], [fragnodes item:i], [[fragnodes item:i] nodeName],[[fragnodes item:i] nodeValue]);
        
        if( [[fragmentNodes item:i] nodeType] == 1 ) {
            RWH_LOG(@"Outer HTML %@",[[fragnodes item:i] outerHTML]);
            
            if( [[[fragmentNodes item:i] nodeName] isEqualToString:@"FONT"] ) {
                NSString *fontTag = [[fragmentNodes item:i] outerHTML];
                NSArray *tagComponents = [fontTag componentsSeparatedByString:@" "];
                NSString *oldSize = @"";
                for( int j=0; j < tagComponents.count; j++) {
                    NSString *testString = [[tagComponents objectAtIndex:j] commonPrefixWithString:@"size" options:NSCaseInsensitiveSearch];
                    if( [testString isEqualToString:@"size"] ) {
                        oldSize = [tagComponents objectAtIndex:j];
                        RWH_LOG(@"sizeString : %@",oldSize);
                    }
                }
                oldSize = [@" " stringByAppendingString:oldSize];
                RWH_LOG(@"newsizetext : %@",fontTag);
                NSString *newTag = [fontTag stringByReplacingOccurrencesOfString:oldSize withString:@""];
                RWH_LOG(@"newString : %@",newTag);
                [[fragmentNodes item:i] setOuterHTML:newTag];
            }
        }
        
        if( [[[fragmentNodes item:i] nodeName] isEqualToString:@"P"] ) {
            //we have a paragraph element, so now replace it with a break element
            DOMDocumentFragment *brelem = [self createDocumentFragment:@"<br />"];
            if( i == 0) {
                //because the paragraphs are the containers so you get two initially...
                brelem = [self createDocumentFragment:@"<span />"];
            }
            DOMNodeList *pnodes = [[fragmentNodes item:i] childNodes];
            for(int j=0; j< pnodes.length;j++) {
                //copy all child nodes to the new node...
                [brelem appendChild:[pnodes item:j]];
            }
            //now replace the paragraph node...
            [[headerFragment firstChild] replaceChild:brelem oldChild:[fragmentNodes item:i] ];
        }
    }
}

- (DOMDocumentFragment *)createDocumentFragment:(NSString *)htmlString {
    return [[document htmlDocument]
            createDocumentFragmentWithMarkupString:htmlString];
}

@end
