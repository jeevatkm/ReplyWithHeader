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
        NSLog(@"MailQuotedOriginal: Init failed");
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
        //		NSLog(@"Document=%@",document);
        
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
    //now set the border variable
    border = [[document htmlDocument] createDocumentFragmentWithMarkupString: @"-----Original Message-----"];
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
    //			NSLog(@"Orig is now %@", origemail);
    
    isPlainText = YES;
    
    //DOMNodeList *vl = [origemail childNodes];
    //for(int i=0;i< vl.length;i++)
    //{
    //  id ii=[ vl item:i];
    //  NSLog(@"%d(%d,%@,%@,%@,%@,%@)=",i,[ii nodeType],[ii nodeName],[ii attributes],[ii prefix],[ii namespaceURI],[ii localName]);
    //	if([ii nodeType] != 3) NSLog(@"Origemail child (%@) = %@",[vl item:i],[[vl item:i] outerHTML]);
    //	else NSLog(@"ND(%d)=%@",i,[ [vl item:i] data]);
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
    //    NSLog(@"isPlainText = %d", isPlainText);
    //	for(int i=0; i< dhc.length;i++){
    //		NSLog(@"%d=(Type %d) %@\n%@\n",i, [[dhc item:i] nodeType], [dhc item:i], [[dhc item:i] nodeName]);
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
        //NSLog(@"Range is: %@", NSStringFromRange(textRange));
        //NSLog(@"Length=%ld Text=%@",[[[origemail firstChild] stringValue] length],[[origemail firstChild] stringValue]);
        [origemail removeChild:[dhc item:0]];
        textRange =[[[origemail firstChild] stringValue] rangeOfString:wrotestring];
    }
    //remove the line with the "wrote:" text
    [origemail removeChild:[dhc item:0]];
    
    //remove the first new line element to shorten the distance between the new email and quoted text
    if( [[[origemail firstChild] nodeName] isEqualToString:@"BR"] )
    {
        [origemail removeChild:[origemail firstChild]];
        //                NSLog(@"Removed BR element, only %d children left",[origemail childElementCount]);
    }

}

-(void)removeOriginalPlainTextHeader
{
    // is this signature?
    //			NSLog(@"Sig=%@ %d<%@>",[dhc item:0],[[dhc item:0] nodeType],[[dhc item:0] stringValue]);
    //			NSLog(@"Sig=%@ %d<%@>",[dhc item:1],[[dhc item:1] nodeType],[[dhc item:1] stringValue]);
    //			NSLog(@"Sig=%@ %d<%@>",[dhc item:2],[[dhc item:2] nodeType],[[dhc item:2] stringValue]);
    //			NSLog(@"Sig=%@ %d<%@>",[dhc item:3],[[dhc item:3] nodeType],[[dhc item:3] stringValue]);
    //			NSLog(@"Sig=%@ %d<%@>",[dhc item:4],[[dhc item:4] nodeType],[[dhc item:4] stringValue]);
    //
    //			NSLog(@"===END===");
    
    for(int i =0;i < dhc.length;i++) {
        if ([[dhc item:i] nodeType]==3){
            // Text node, On ..., Wrote is text
            textNodeLocation=i; break;
        }}
    
    // if signature at top, item==3 else item==1
    [origemail removeChild:[dhc item:textNodeLocation]];
    //            NSLog(@"removed item %d",textNodeLocation);
    
    //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
    for(int i =0;i < [origemail childElementCount];i++)
    {
        if( [[[[origemail childNodes] item:i] nodeName] isEqualToString:@"BLOCKQUOTE"] )
        {
            //this is the quoted text
            textNodeLocation=i;
            //                    NSLog(@"textNodeLocation item is now %d",textNodeLocation);
            break;
        }
    }
}

-(void)insertMailHeader:(MailHeaderString *)headStr
{
    //this routine will also add the border
    DOMDocumentFragment *headerfragment=[[document htmlDocument] createFragmentForWebArchive:[headStr getWebArch]];
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
        
        //        NSLog(@"numgrandchildren %d=(Type %d) %@\n%@\n",numgrandchild, [[origemail firstChild] nodeType], [origemail firstChild], [[origemail firstChild] nodeName]);
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

@end
