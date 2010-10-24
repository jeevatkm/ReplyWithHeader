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
#import "WebKit/DOMHTMLCollection.h"
#import "WebKit/DOMHTMLElement.h"
#import "WebKit/DOMHTMLDivElement.h"
#import "WebKit/WebResource.h"
#import "WebKit/WebArchive.h"
#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>

IMP rph_imp1;
SEL rph_sel1;
Class ComposeBackEndClass ;
char *rph_ms = "_continueToSetupContentsForView:withParsedMessages:";
@implementation ComposeBackEnd2

+(void)load{
	ComposeBackEndClass = NSClassFromString(@"ComposeBackEnd");
	if(!ComposeBackEndClass){
		NSLog(@"ReplyWithHeader: Could not find ComposeBackEnd, not good");
		return;
	}
	class_setSuperclass([self class], ComposeBackEndClass);
	
	
	Method oldm,newm;
	oldm  = 
		class_getInstanceMethod(self, sel_registerName(rph_ms)); //Called 1st
	newm  = 
		class_getInstanceMethod(self, @selector(rph_continueToSetupContentsForView:withParsedMessages:));
	
	rph_sel1 = sel_registerName(rph_ms);
	rph_imp1 = class_getMethodImplementation(ComposeBackEndClass, rph_sel1);

    method_exchangeImplementations(oldm, newm);
}

- (void)rph_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2
{
//	NSLog(@"Inside my_continueToSetupContentsForView=%@",self);
//	NSLog(@"%@",arg1);
//	NSLog(@"%@",arg2);
	(rph_imp1)(self,rph_sel1,arg1,arg2);
	int selftype=[self type];
	if( selftype==1 || selftype ==2) {
		id document = [self document];
//		NSLog(@"Document=%@",document);
		DOMDocumentFragment *border=[ [document htmlDocument]
								 createDocumentFragmentWithMarkupString:
								 @"<div style='border:none;border-top:solid #B5C4DF 1.0pt;padding:0 0 0 0;margin:10px 0 5px 0;'></div>"
								 ];

		BOOL boldhead=YES;
		DOMHTMLDivElement *origemail=[[[document htmlDocument] 
									   descendantsWithClassName:@"AppleOriginalContents"] objectAtIndex:0];
//		NSLog(@"DOMHTMLDivElement=%@",origemail);
	
		if(origemail==NULL){
			origemail=[[[[[document htmlDocument] 
							descendantsWithClassName:@"ApplePlainTextBody"] objectAtIndex:0]
							children] item:1];
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
										attributedStringShowingHeaderDetailLevel:1
										useHeadIndents:NO
										useBold:boldhead
										includeBCC:YES];
	DOMHTMLCollection *dhc = [origemail children];
//	for(int i=0; i< dhc.length;i++){	
//		NSLog(@"%d=%@\n",i, [dhc item:i]);
//	}
	// the first one is "On .... X wrote"
	if(dhc.length>1) [origemail removeChild:[dhc item:0]];
	WebArchive * headerwebarchive=[headerString webArchiveForRange:NSMakeRange(0,[headerString length]) fixUpNewlines:YES];
	DOMDocumentFragment *headerfragment=[ [document htmlDocument] createFragmentForWebArchive:headerwebarchive];
	[origemail insertBefore:headerfragment refChild: [origemail firstChild] ];
	[origemail insertBefore:border refChild: [origemail firstChild] ];
	}
}


@end
