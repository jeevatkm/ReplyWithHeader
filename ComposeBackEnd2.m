// replyWitHeaders MailBundle - compose reply with message headers as in forwards
//    Copyright (C) 2008 saptarshi guha saptarshi.guha@gmail.com
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.



#import "ComposeBackEnd2.h"

#import "WebKit/DOMDocumentFragment.h"
#import "WebKit/DOMNodeList.h"
#import "WebKit/DOMHTMLCollection.h"
#import "WebKit/DOMHTMLElement.h"
#import "WebKit/DOMHTMLDocument.h"
#import "WebKit/DOMHTMLDivElement.h"
#import "WebKit/WebResource.h"
#import "WebKit/WebArchive.h"
#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>

IMP rph_imp1,rph_sih_imp;
SEL rph_sel1,rph_sih_sel;
Class ComposeBackEndClass ;


char *rph_ms = "_continueToSetupContentsForView:withParsedMessages:";
char *rph_sih = "setOriginalMessageWebArchive:";

@implementation ComposeBackEnd2



+(void)load{
	ComposeBackEndClass = NSClassFromString(@"ComposeBackEnd");
	if(!ComposeBackEndClass){
		NSLog(@"ReplyWithHeader: Could not find ComposeBackEnd, not good");
		return;
	}
    

	class_setSuperclass([self class], ComposeBackEndClass);

   /*Class MessageHeadersClass = NSClassFromString(@"MessageHeaders");
    unsigned int outCount;
    Method *array = class_copyMethodList(MessageHeadersClass, &outCount);
    NSLog(@"Count=%d",outCount);
    
    for( int i = 0; i < outCount; i++ )
    {
        //char *type = method_copyReturnType(array[i]);
        NSLog(@"Meth=%s returns=%s",sel_getName(method_getName(array[i])),method_copyReturnType(array[i]));
    }
    */
	
	Method oldm,newm;
	oldm  = 
		class_getInstanceMethod(self, sel_registerName(rph_ms)); //Called 1st
	newm  = 
		class_getInstanceMethod(self, @selector(rph_continueToSetupContentsForView:withParsedMessages:));
	
	rph_sel1 = sel_registerName(rph_ms);
	rph_imp1 = class_getMethodImplementation(ComposeBackEndClass, rph_sel1);

    method_exchangeImplementations(oldm, newm);
	
//	oldm  = 
//	class_getInstanceMethod(self, sel_registerName(rph_sih)); //Called 1st
//	newm  = 
//	class_getInstanceMethod(self, @selector(rph_setOriginalMessageWebArchive:));
//	
//	rph_sih_sel = sel_registerName(rph_ms);
//	rph_sih_imp = class_getMethodImplementation(ComposeBackEndClass, rph_sel1);
//	
//    method_exchangeImplementations(oldm, newm);
	
}

-(void)domystuff{
    return;
}

//- (void)rph_setOriginalMessageWebArchive:(id)fp8{
//	NSLog(@"setOriginalMessageWebArchive %@",fp8);
//}
- (void)rph_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2
{
//	NSLog(@"Inside my_continueToSetupContentsForView=%@",self);
//	NSLog(@"%@",arg1);
//	NSLog(@"%@",arg2);
	id beforewhat;
	(rph_imp1)(self,rph_sel1,arg1,arg2);
	int selftype=[self type];
		int which =0;
	if( selftype==1 || selftype ==2) {
		id document = [self document];
//		NSLog(@"Document=%@",document);
		DOMDocumentFragment *border=[ [document htmlDocument]
								 createDocumentFragmentWithMarkupString:
                                 @"-----Original Message-----"
								// @"<div style='border:none;border-top:solid #B5C4DF 1.0pt;padding:0 0 0 0;margin:10px 0 5px 0;'></div>"
								 ];

		BOOL boldhead=YES;
//		DOMNode *voo = [document htmlDocument];
//		DOMNodeList *vl = [[[[[voo childNodes] item:0] childNodes] item:0] childNodes];
			
		DOMHTMLDivElement *origemail=[[[document htmlDocument] 
									   descendantsWithClassName:@"AppleOriginalContents"] objectAtIndex:0];
	
		int howdeep = 0; //AppleOriginalContents=0 ApplePlainTextBody=1
		if([origemail firstChild]==NULL){
			origemail=[[[document htmlDocument] descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0]; 
//			NSLog(@"Orig is now %@", origemail);
			howdeep=1;
//			DOMNodeList *vl = [origemail childNodes];
//			for(int i=0;i< vl.length;i++){
//				id ii=[ vl item:i];
//				NSLog(@"%d(%d,%@,%@,%@,%@,%@)=",i,[ii nodeType],[ii nodeName],[ii attributes],[ii prefix],[ii namespaceURI],[ii localName]);
//				if([ii nodeType] != 3) NSLog(@"Origemail child (%@) = %@",[vl item:i],[[vl item:i] outerHTML]);
//				else NSLog(@"ND(%d)=%@",i,[ [vl item:i] data]);
//			}
			
			
						//	children] item:1];
			if ([[ origemail idName] isEqualToString:@"AppleMailSignature"]){
				origemail=[[[[[document htmlDocument] descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0]
							children] item:2];
			if ([[origemail outerHTML] isEqualToString:@"<br>"]) 
				origemail=[[[[[document htmlDocument] descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0]
							children] item:3];
			}	
			boldhead=NO;
		}
        
	NSAttributedString *headerString =[[self originalMessageHeaders] 
                                       attributedStringShowingHeaderDetailLevel:1];
									//	useHeadIndents:NO
									//	useBold:boldhead
									//	includeBCC:YES];
        
	DOMNodeList *dhc = [origemail childNodes];
	//NSUserDefaults *nsd=	[NSUserDefaults standardUserDefaults];
	//BOOL signatureattop = [nsd boolForKey:@"SignaturePlacedAboveQuotedText"];	
//	for(int i=0; i< dhc.length;i++){	
//		NSLog(@"%d=(Type %d) %@\n%@\n",i, [[dhc item:i] nodeType], [dhc item:i], [[dhc item:i] nodeName]);
//	}
	// the first one is "On .... X wrote"
		if(dhc.length>1 && howdeep==0) {
			[origemail removeChild:[dhc item:0]]; 
//            NSLog(@"Removed Original Text, only %d children left",[origemail childElementCount]);
            if( [[[origemail firstChild] nodeName] isEqualToString:@"BR"] ) {                
                [origemail removeChild:[origemail firstChild]];
//                NSLog(@"Removed BR element, only %d children left",[origemail childElementCount]);
            }
		}
		if(dhc.length>1 && howdeep==1) {
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
					which=i; break;
				}}
				
			// if signature at top, item==3 else item==1
			[origemail removeChild:[dhc item:which]];
            
            
            //find the quoted text - if plain text (blockquote does not exist), -which- will point to br element
            for(int i =0;i < [origemail childElementCount];i++) {
                if( [[[[origemail childNodes] item:i] nodeName] isEqualToString:@"BLOCKQUOTE"] ) {                
                    //this is the quoted text
                    which=i;
                    break;
                    
                }
            }
		}
	
    //remove the color attribute so that the text is black instead of gray
    NSMutableAttributedString *newheaderString = [headerString mutableCopy];
    [newheaderString removeAttribute:@"NSColor" range:NSMakeRange(0,[newheaderString length])];
    
    //NSLog(@"Sig=%@",newheaderString);
    
	WebArchive * headerwebarchive=[newheaderString webArchiveForRange:NSMakeRange(0,[newheaderString length]) fixUpNewlines:YES];
	DOMDocumentFragment *headerfragment=[ [document htmlDocument] createFragmentForWebArchive:headerwebarchive];
	if(howdeep==0){
			[[origemail firstChild] insertBefore:headerfragment refChild: [[origemail firstChild] firstChild] ];
			[[origemail firstChild] insertBefore:border refChild: [[origemail firstChild] firstChild]];
	}else if(howdeep==1){
		if(which>0){
            //check if this is plain text by seeing if -which- points to a br element... if not, include in blockquote
            if( [[[[origemail childNodes] item:which] nodeName] isEqualToString:@"BR"] ) {
                [origemail insertBefore:headerfragment refChild:[dhc item:which] ];
                [origemail insertBefore:border refChild:[dhc item:which] ];
            }
            else {
                [[[origemail childNodes] item:which] insertBefore:headerfragment refChild:[[[origemail childNodes] item:which] firstChild] ];
                [[[origemail childNodes] item:which] insertBefore:border refChild:[[[origemail childNodes] item:which] firstChild] ];
            }
		}
	}
		
	}
}


@end
