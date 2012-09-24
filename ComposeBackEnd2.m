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

#import "MailHeaderString.h"

#import "MailQuotedOriginal.h"

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
	
    //get my type and check it
    int selftype=[self type];
	if( selftype==1 || selftype ==2)
    {
        //start by setting up the quoted text from the original email
        MailQuotedOriginal *quotedText = [[MailQuotedOriginal alloc] initWithBackEnd:self];
        
        //create the header string element
        MailHeaderString *newheaderString = [[MailHeaderString alloc] initWithBackEnd:self];
        
        //this is required for Mountain Lion - for some reason the mail headers are not bold anymore.
        [newheaderString boldHeaderLabels];
        
//        NSLog(@"Sig=%@",[newheaderString string]);
        
        //insert the new header text
        [quotedText insertMailHeader:newheaderString];
    }
}


@end
