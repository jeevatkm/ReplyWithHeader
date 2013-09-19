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
//

#import "RwhMailQuotedOriginal.h"

@implementation RwhMailQuotedOriginal

- (id)init {
    if (self = [super init]) {
        //good stuff...
    }
    else {
        RWH_LOG(@"MailQuotedOriginal: Init failed");
    }
    return self;
}


- (id)initWithBackEnd:(id)backend {
    //initialze the value with a mutable copy of the attributed string
    if( self = [super init] ) {
		//set the class document variable
        document = [backend document];
        
        RWH_LOG(@"Document=%@",document);
        
        //now initialize the other vars
        [self initVars];
        
        //if there is not a child in the original email, it must be plain text
        if([origemail firstChild]==NULL) {
            //prep the plain text
            [self prepQuotedPlainText];
        }
        
        //now that the email is set... set the child nodes
        dhc = [origemail childNodes];
        
        //now get the quoted content and remove the first part (where it says "On ... X wrote"
        if( dhc.length > 1) {
            if( isPlainText ) {   
                [self removeOriginalPlainTextHeader];
            }
            else {
                [self removeOriginalHeader];
            }
        }
    }
    else {
        RWH_LOG(@"MailQuotedOriginal: Init Backend failed");
    }
    
    return self;
}


- (void)initVars {
    
    NSString *replyHeadline = GET_USER_DEFAULT(RwhMailReplyHeaderText);
    NSString *forwardHeadline = GET_USER_DEFAULT(RwhMailForwardHeaderText);
    
    RWH_LOG(@"MailQuotedOriginal: initvar Header text: %@", replyHeadline);    
    
    //now set the border variable
    border = [[document htmlDocument] createDocumentFragmentWithMarkupString: replyHeadline];
    // @"<div style='border:none;border-top:solid #B5C4DF 1.0pt;padding:0 0 0 0;margin:10px 0 5px 0;'></div>"
    
    fwdborder = [[document htmlDocument] createDocumentFragmentWithMarkupString: forwardHeadline];
    
    boldhead=YES;
    //		DOMNode *voo = [document htmlDocument];
    //		DOMNodeList *vl = [[[[[voo childNodes] item:0] childNodes] item:0] childNodes];
    
    origemail=[[[document htmlDocument]
                descendantsWithClassName:@"AppleOriginalContents"] objectAtIndex:0];
    
    //howdeep = 0; //AppleOriginalContents=0 ApplePlainTextBody=1
    isPlainText = NO; //AppleOriginalContents: (isPlainText=NO) | ApplePlainTextBody: (isPlainText=YES)
    textNodeLocation = 0;

}

- (void)prepQuotedPlainText {
    
    origemail=[[[document htmlDocument] descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0];
    
    RWH_LOG(@"Orig is now %@", origemail);
    
    isPlainText = YES;
    
    if( [[origemail idName] isEqualToString:@"AppleMailSignature"] ) {
        int itemnum = 2;
        //check that the second child isn't a break element and if so, go to the child 3
        if( [[[[origemail children] item:itemnum] outerHTML] isEqualToString:@"<br>"] ) {
            itemnum = 3;
        }
        
        origemail = [[origemail children] item:itemnum];
    }

    //this is plain text so do not bold the header...
    boldhead=NO;
    
}

- (void)removeOriginalHeader {
    
    //Mountain Lion created the issue on new messages and "wrote" appears in a new div when replying
    // on those messages that arrive after mail.app is opened - so we'll just keep removing items
    // from the beginnning until we find the element that has the "wrote:" text in it.
    
    //unfortunately, there is no containsString routine so we have to do it by using a range.
    // this method is documented at http://mobiledevelopertips.com/cocoa/nsrange-and-nsstring-objects.html
    
    //setup a regular expression to find a colon followed by some space and a new line -
    // the first one should be the original line...
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":\\s*(\\n|\\r)" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange textRange = [regex rangeOfFirstMatchInString:[[origemail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[origemail firstChild] stringValue] length])];
    
    //keep removing items until we find the "wrote:" text...
    while( textRange.location == NSNotFound ) {
        RWH_LOG(@"Range is: %@", NSStringFromRange(textRange));
        RWH_LOG(@"Length=%ld Text=%@",[[[origemail firstChild] stringValue] length],[[origemail firstChild] stringValue]);
        
        [origemail removeChild:[dhc item:0]];
        textRange = [regex rangeOfFirstMatchInString:[[origemail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[origemail firstChild] stringValue] length])];
    }
    
    //remove the line with the "wrote:" text
    [origemail removeChild:[dhc item:0]];
    
    //remove the first new line element to shorten the distance between the new email and quoted text
    // this is required in order to get the header inside the quoted text line
    if( [[[origemail firstChild] nodeName] isEqualToString:@"BR"] ) {
        
        [origemail removeChild:[origemail firstChild]];
        
        RWH_LOG(@"Removed BR element, only %d children left",[origemail childElementCount]);
    }

}

- (void)removeOriginalPlainTextHeader {  
    
    for(int i =0;i < dhc.length;i++) {
        if( [[dhc item:i] nodeType]==3 ) {
            // Text node, On ..., Wrote is text
            textNodeLocation=i; break;
        }
    }
    
    RWH_LOG(@"Removing plain text header at %d",textNodeLocation);
    
    // if signature at top, item==3 else item==1
    [origemail removeChild:[dhc item:textNodeLocation]];
    
    //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
    for(int i =0;i < [origemail childElementCount];i++) {
        if( [[[[origemail childNodes] item:i] nodeName] isEqualToString:@"BLOCKQUOTE"] ) {
            //this is the quoted text
            textNodeLocation=i;
            // RWH_LOG(@"textNodeLocation item is now %d",textNodeLocation);
            break;
        }
    }
    
    RWH_LOG(@"New header location is %d",textNodeLocation);
    
}


- (void)removeOriginalForwardHeader {
    
    //remove the elements with text followed by a colon
    //setup a regular expression to find a colon followed by some space and a new line -
    // the first one should be the original line...
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[^:]+:" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange textRange = [regex rangeOfFirstMatchInString:[[origemail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[origemail firstChild] stringValue] length])];
    
    //keep removing items until we find the "wrote:" text...
    while( textRange.location == NSNotFound ) {
        
        RWH_LOG(@"Range is: %@", NSStringFromRange(textRange));
        RWH_LOG(@"Length=%ld Text=%@",[[[origemail firstChild] stringValue] length],[[origemail firstChild] stringValue]);
        
        [origemail removeChild:[dhc item:0]];
        textRange = [regex rangeOfFirstMatchInString:[[origemail firstChild] stringValue] options:0 range:NSMakeRange(0, [[[origemail firstChild] stringValue] length])];
    }
    
    //remove the line with the "wrote:" text
    [origemail removeChild:[dhc item:0]];
    
    //remove the first new line element to shorten the distance between the new email and quoted text
    // this is required in order to get the header inside the quoted text line
    if( [[[origemail firstChild] nodeName] isEqualToString:@"BR"] ) {
        [origemail removeChild:[origemail firstChild]];
        
        RWH_LOG(@"Removed BR element, only %d children left",[origemail childElementCount]);
    }    
}


- (void)insertMailHeader:(RwhMailHeaderString *)headStr {
    //this routine will also add the border
    DOMDocumentFragment *headerfragment=[[document htmlDocument] createFragmentForWebArchive:[headStr getWebArch]];
    
    //check if we need to do Entourage 2004 text size transformations...
    BOOL isEntourage2004SupportRequired = GET_BOOL_USER_DEFAULT(RwhMailEntourage2004SupportEnabled);
    // NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] retain];
    // BOOL supportEntourage = [prefs boolForKey:@"entourage2004Support"];
    
    if( isEntourage2004SupportRequired ) {
        [self supportEntourage2004:headerfragment];
    }
    
    if( isPlainText ) {
        if( textNodeLocation>0 ) {
            //check if this is plain text by seeing if textNodeLocation points to a br element...
            //  if not, include in blockquote
            if( [[[[origemail childNodes] item:textNodeLocation] nodeName] isEqualToString:@"BR"] ) {
                [origemail insertBefore:headerfragment refChild:[dhc item:textNodeLocation] ];
                [origemail insertBefore:border refChild:[dhc item:textNodeLocation] ];
            }
            else {
                [[[origemail childNodes] item:textNodeLocation] insertBefore:headerfragment refChild:[[[origemail childNodes] item:textNodeLocation] firstChild] ];
                [[[origemail childNodes] item:textNodeLocation] insertBefore:border refChild:[[[origemail childNodes] item:textNodeLocation] firstChild] ];
            }
		}
    }
    else {   
        //depending on the options selected to increase quote level or whatever, a reply might not have a grandchild from the first child
        //so we need to account for that... man this gets complicated... so if it is a textnode, there are no children... :(
        //so account for that too
        int numgrandchild = 0;
        if( ![ [[origemail firstChild] nodeName] isEqualToString:@"#text"] ) {
            numgrandchild = [[origemail firstChild] childElementCount];
        }
        
        RWH_LOG(@"numgrandchildren %d=(Type %d) %@\n%@\n",numgrandchild, [[origemail firstChild] nodeType], [origemail firstChild], [[origemail firstChild] nodeName]);
        
        if( numgrandchild == 0 ) {
			[origemail insertBefore:headerfragment refChild: [origemail firstChild] ];
			[origemail insertBefore:border refChild: [origemail firstChild] ];
        }
        else {
			[[origemail firstChild] insertBefore:headerfragment refChild: [[origemail firstChild] firstChild] ];
			[[origemail firstChild] insertBefore:border refChild: [[origemail firstChild] firstChild]];
        }

    }
    
}

- (void)insertFwdHeader {
    
    if( isPlainText ) {
        if( textNodeLocation>0 ) {
            //check if this is plain text by seeing if textNodeLocation points to a br element...
            //  if not, include in blockquote
            if( [[[[origemail childNodes] item:textNodeLocation] nodeName] isEqualToString:@"BR"] ) {
                [origemail insertBefore:fwdborder refChild:[dhc item:textNodeLocation] ];
            }
            else {
                [[[origemail childNodes] item:textNodeLocation] insertBefore:fwdborder refChild:[[[origemail childNodes] item:textNodeLocation] firstChild] ];
            }
		}
    }
    else {
        //depending on the options selected to increase quote level or whatever, a reply might not have a grandchild from the first child
        //so we need to account for that... man this gets complicated... so if it is a textnode, there are no children... :(
        //so account for that too
        int numgrandchild = 0;
        if( ![ [[origemail firstChild] nodeName] isEqualToString:@"#text"] ) {
            numgrandchild = [[origemail firstChild] childElementCount];
        }
        
        RWH_LOG(@"numgrandchildren %d=(Type %d) %@\n%@\n",numgrandchild, [[origemail firstChild] nodeType], [origemail firstChild], [[origemail firstChild] nodeName]);
        if( numgrandchild == 0 ) {
			[origemail insertBefore:fwdborder refChild: [origemail firstChild] ];
        }
        else {
			[[origemail firstChild] insertBefore:fwdborder refChild: [[origemail firstChild] firstChild]];
        }
        
    }
}

- (void)supportEntourage2004:(DOMDocumentFragment *) headFrag {
    
    //kind of silly, but this code is required so that the adulation appears correctly in Entourage 2004
    //2004 would interpret the paragraph tag and ignore the specified style information creating large spaces
    //between line items
    DOMNodeList *fragnodes = [[headFrag firstChild] childNodes];
    
    for(int i=0; i< fragnodes.length;i++) {
        RWH_LOG(@"%d=(Type %d) %@ %@ %@",i, [[fragnodes item:i] nodeType], [fragnodes item:i], [[fragnodes item:i] nodeName],[[fragnodes item:i] nodeValue]);
        
        if( [[fragnodes item:i] nodeType] == 1 ) {
            RWH_LOG(@" HTML = %@",[[fragnodes item:i] outerHTML]);
            
            if( [[[fragnodes item:i] nodeName] isEqualToString:@"FONT"] ) {
                NSString *fontTag = [[fragnodes item:i] outerHTML];
                NSArray *tagComponents = [fontTag componentsSeparatedByString:@" "];
                NSString *oldSize;
                for( int j=0; j < tagComponents.count; j++) {
                    NSString *testString = [[tagComponents objectAtIndex:j] commonPrefixWithString:@"size" options:NSCaseInsensitiveSearch];
                    if( [testString isEqualToString:@"size"] ) {
                        oldSize = [tagComponents objectAtIndex:j];
                        RWH_LOG(@" sizeString = %@",oldSize);
                    }
                }
                oldSize = [@" " stringByAppendingString:oldSize];
                RWH_LOG(@" newsizetext = %@",fontTag);
                NSString *newTag = [fontTag stringByReplacingOccurrencesOfString:oldSize withString:@""];
                RWH_LOG(@" newString = %@",newTag);
                [[fragnodes item:i] setOuterHTML:newTag];
            }
        }
        
        if( [[[fragnodes item:i] nodeName] isEqualToString:@"P"] ) {
            //we have a paragraph element, so now replace it with a break element
            DOMDocumentFragment *brelem=[ [document htmlDocument]
                                         createDocumentFragmentWithMarkupString:
                                         @"<br />"
                                         ];
            if( i == 0) {
                //because the paragraphs are the containers so you get two initially...
                brelem = [ [document htmlDocument]
                          createDocumentFragmentWithMarkupString:
                          @"<span />"
                          ];
            }
            DOMNodeList *pnodes = [[fragnodes item:i] childNodes];
            for(int j=0; j< pnodes.length;j++) {
                //copy all child nodes to the new node...
                [brelem appendChild:[pnodes item:j]];
            }
            //now replace the paragraph node...
            [[headFrag firstChild] replaceChild:brelem oldChild:[fragnodes item:i] ];
        }
    }
}

@end
