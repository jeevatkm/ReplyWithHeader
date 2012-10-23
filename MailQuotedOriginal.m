//
//  MailQuotedOriginal.m
//  ReplyWithHeader
//
//  Created by Jason Schroth on 8/16/12.
//
//

#import "MailQuotedOriginal.h"

@implementation MailQuotedOriginal

-(id)init
{
    if (self = [super init]) {
        //good stuff...
    }
    else {
        RWH_LOG(@"MailQuotedOriginal: Init failed");
    }
    return self;
}


-(id)initWithBackEnd:(id)backend
{
    //initialze the value with a mutable copy of the attributed string
    if( self = [super init] )
    {
		//set the class document variable
        document = [backend document];
        RWH_LOG(@"Document=%@",document);
        
        //now initialize the other vars
        [self initVars];
        
        //if there is not a child in the original email, it must be plain text
        if([origemail firstChild]==NULL)
        {
            //prep the plain text
            [self prepQuotedPlainText];
        }
        
        //now that the email is set... set the child nodes
        dhc = [origemail childNodes];
        
        //now get the quoted content and remove the first part (where it says "On ... X wrote"
        if( dhc.length > 1)
        {
            if( isPlainText )
            {   
                [self removeOriginalPlainTextHeader];
            }
            else
            {
                [self removeOriginalHeader];
            }
        }
    }
    
    return self;
}


-(void)initVars
{
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] retain];
    NSString *headLine = [prefs objectForKey:@"headerText"];
    //now set the border variable
    border = [[document htmlDocument] createDocumentFragmentWithMarkupString: headLine];
    // @"<div style='border:none;border-top:solid #B5C4DF 1.0pt;padding:0 0 0 0;margin:10px 0 5px 0;'></div>"
    
    boldhead=YES;
    //		DOMNode *voo = [document htmlDocument];
    //		DOMNodeList *vl = [[[[[voo childNodes] item:0] childNodes] item:0] childNodes];
    
    origemail=[[[document htmlDocument]
                descendantsWithClassName:@"AppleOriginalContents"] objectAtIndex:0];
    
    //howdeep = 0; //AppleOriginalContents=0 ApplePlainTextBody=1
    isPlainText = NO; //AppleOriginalContents: (isPlainText=NO) | ApplePlainTextBody: (isPlainText=YES)
    textNodeLocation = 0;

}

-(void)prepQuotedPlainText
{
    
    origemail=[[[document htmlDocument] descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0];
    RWH_LOG(@"Orig is now %@", origemail);
    
    isPlainText = YES;
    
    //DOMNodeList *vl = [origemail childNodes];
    //for(int i=0;i< vl.length;i++)
    //{
    //  id ii=[ vl item:i];
    //  RWH_LOG(@"%d(%d,%@,%@,%@,%@,%@)=",i,[ii nodeType],[ii nodeName],[ii attributes],[ii prefix],[ii namespaceURI],[ii localName]);
    //	if([ii nodeType] != 3) RWH_LOG(@"Origemail child (%@) = %@",[vl item:i],[[vl item:i] outerHTML]);
    //	else RWH_LOG(@"ND(%d)=%@",i,[ [vl item:i] data]);
    //}
    
    if( [[origemail idName] isEqualToString:@"AppleMailSignature"] )
    {
        int itemnum = 2;
        //check that the second child isn't a break element and if so, go to the child 3
        if( [[[[origemail children] item:itemnum] outerHTML] isEqualToString:@"<br>"] )
        {
            itemnum = 3;
        }
        
        origemail = [[origemail children] item:itemnum];
    }

    //this is plain text so do not bold the header...
    boldhead=NO;
    
}

-(void)removeOriginalHeader
{
    //NSUserDefaults *nsd=	[NSUserDefaults standardUserDefaults];
    //BOOL signatureattop = [nsd boolForKey:@"SignaturePlacedAboveQuotedText"];
    //    RWH_LOG(@"isPlainText = %d", isPlainText);
    //	for(int i=0; i< dhc.length;i++){
    //		RWH_LOG(@"%d=(Type %d) %@\n%@\n",i, [[dhc item:i] nodeType], [dhc item:i], [[dhc item:i] nodeName]);
    //	}
    
    //Mountain Lion created the issue on new messages and "wrote" appears in a new div when replying
    // on those messages that arrive after mail.app is opened - so we'll just keep removing items
    // from the beginnning until we find the element that has the "wrote:" text in it.
    
    //unfortunately, there is no containsString routine so we have to do it by using a range.
    // this method is documented at http://mobiledevelopertips.com/cocoa/nsrange-and-nsstring-objects.html
    NSRange textRange;
    NSString* wrotestring = @"wrote:";
    textRange =[[[origemail firstChild] stringValue] rangeOfString:wrotestring];
    //keep removing items until we find the "wrote:" text...
    while( textRange.location == NSNotFound )
    {
        RWH_LOG(@"Range is: %@", NSStringFromRange(textRange));
        RWH_LOG(@"Length=%ld Text=%@",[[[origemail firstChild] stringValue] length],[[origemail firstChild] stringValue]);
        [origemail removeChild:[dhc item:0]];
        textRange =[[[origemail firstChild] stringValue] rangeOfString:wrotestring];
    }
    //remove the line with the "wrote:" text
    [origemail removeChild:[dhc item:0]];
    
    //remove the first new line element to shorten the distance between the new email and quoted text
    if( [[[origemail firstChild] nodeName] isEqualToString:@"BR"] )
    {
        [origemail removeChild:[origemail firstChild]];
        RWH_LOG(@"Removed BR element, only %d children left",[origemail childElementCount]);
    }

}

-(void)removeOriginalPlainTextHeader
{
    // is this signature?
    //			RWH_LOG(@"Sig=%@ %d<%@>",[dhc item:0],[[dhc item:0] nodeType],[[dhc item:0] stringValue]);
    //			RWH_LOG(@"Sig=%@ %d<%@>",[dhc item:1],[[dhc item:1] nodeType],[[dhc item:1] stringValue]);
    //			RWH_LOG(@"Sig=%@ %d<%@>",[dhc item:2],[[dhc item:2] nodeType],[[dhc item:2] stringValue]);
    //			RWH_LOG(@"Sig=%@ %d<%@>",[dhc item:3],[[dhc item:3] nodeType],[[dhc item:3] stringValue]);
    //			RWH_LOG(@"Sig=%@ %d<%@>",[dhc item:4],[[dhc item:4] nodeType],[[dhc item:4] stringValue]);
    //
    //			RWH_LOG(@"===END===");
    
    for(int i =0;i < dhc.length;i++) {
        if ([[dhc item:i] nodeType]==3){
            // Text node, On ..., Wrote is text
            textNodeLocation=i; break;
        }}
    
    // if signature at top, item==3 else item==1
    [origemail removeChild:[dhc item:textNodeLocation]];
    //            RWH_LOG(@"removed item %d",textNodeLocation);
    
    //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
    for(int i =0;i < [origemail childElementCount];i++)
    {
        if( [[[[origemail childNodes] item:i] nodeName] isEqualToString:@"BLOCKQUOTE"] )
        {
            //this is the quoted text
            textNodeLocation=i;
            //                    RWH_LOG(@"textNodeLocation item is now %d",textNodeLocation);
            break;
        }
    }
}

-(void)insertMailHeader:(MailHeaderString *)headStr
{
    //this routine will also add the border
    DOMDocumentFragment *headerfragment=[[document htmlDocument] createFragmentForWebArchive:[headStr getWebArch]];
    
    //check if we need to do Entourage 2004 text size transformations...
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] retain];
    BOOL supportEntourage = [prefs boolForKey:@"entourage2004Support"];
    
    if( supportEntourage )
    {
        [self supportEntourage2004:headerfragment];
    }
    
    if( isPlainText )
    {
        if( textNodeLocation>0 )
        {
            //check if this is plain text by seeing if textNodeLocation points to a br element...
            //  if not, include in blockquote
            if( [[[[origemail childNodes] item:textNodeLocation] nodeName] isEqualToString:@"BR"] )
            {
                [origemail insertBefore:headerfragment refChild:[dhc item:textNodeLocation] ];
                [origemail insertBefore:border refChild:[dhc item:textNodeLocation] ];
            }
            else
            {
                [[[origemail childNodes] item:textNodeLocation] insertBefore:headerfragment refChild:[[[origemail childNodes] item:textNodeLocation] firstChild] ];
                [[[origemail childNodes] item:textNodeLocation] insertBefore:border refChild:[[[origemail childNodes] item:textNodeLocation] firstChild] ];
            }
		}
    }
    else
    {   
        //depending on the options selected to increase quote level or whatever, a reply might not have a grandchild from the first child
        //so we need to account for that... man this gets complicated... so if it is a textnode, there are no children... :(
        //so account for that too
        int numgrandchild = 0;
        if( ![ [[origemail firstChild] nodeName] isEqualToString:@"#text"] )
        {
            numgrandchild = [[origemail firstChild] childElementCount];
        }
        
        RWH_LOG(@"numgrandchildren %d=(Type %d) %@\n%@\n",numgrandchild, [[origemail firstChild] nodeType], [origemail firstChild], [[origemail firstChild] nodeName]);
        if( numgrandchild == 0 )
        {
			[origemail insertBefore:headerfragment refChild: [origemail firstChild] ];
			[origemail insertBefore:border refChild: [origemail firstChild] ];
        }
        else
        {
			[[origemail firstChild] insertBefore:headerfragment refChild: [[origemail firstChild] firstChild] ];
			[[origemail firstChild] insertBefore:border refChild: [[origemail firstChild] firstChild]];
        }

    }
    
}

-(void)supportEntourage2004:(DOMDocumentFragment *) headFrag
{
    
    //kind of silly, but this code is required so that the adulation appears correctly in Entourage 2004
    //2004 would interpret the paragraph tag and ignore the specified style information creating large spaces
    //between line items
    DOMNodeList *fragnodes = [[headFrag firstChild] childNodes];
    
    for(int i=0; i< fragnodes.length;i++)
    {
        RWH_LOG(@"%d=(Type %d) %@ %@ %@",i, [[fragnodes item:i] nodeType], [fragnodes item:i], [[fragnodes item:i] nodeName],[[fragnodes item:i] nodeValue]);
        
        if( [[fragnodes item:i] nodeType] == 1 )
        {
            RWH_LOG(@" HTML = %@",[[fragnodes item:i] outerHTML]);
            
            if( [[[fragnodes item:i] nodeName] isEqualToString:@"FONT"] )
            {
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
        
        if( [[[fragnodes item:i] nodeName] isEqualToString:@"P"] )
        {
            //we have a paragraph element, so now replace it with a break element
            DOMDocumentFragment *brelem=[ [document htmlDocument]
                                         createDocumentFragmentWithMarkupString:
                                         @"<br />"
                                         ];
            if( i == 0)
            {
                //because the paragraphs are the containers so you get two initially...
                brelem = [ [document htmlDocument]
                          createDocumentFragmentWithMarkupString:
                          @"<span />"
                          ];
            }
            DOMNodeList *pnodes = [[fragnodes item:i] childNodes];
            for(int j=0; j< pnodes.length;j++)
            {
                //copy all child nodes to the new node...
                [brelem appendChild:[pnodes item:j]];
            }
            //now replace the paragraph node...
            [[headFrag firstChild] replaceChild:brelem oldChild:[fragnodes item:i] ];
        }
    }
}

@end
