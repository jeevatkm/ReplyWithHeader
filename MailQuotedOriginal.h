//
//  MailQuotedOriginal.h
//  ReplyWithHeader
//
//  Created by Jason Schroth on 8/16/12.
//
//

#import <Foundation/Foundation.h>
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

#import "MailHeaderString.h"

@interface MailQuotedOriginal : NSObject{
@private
    id document;
    DOMDocumentFragment *border;
    BOOL boldhead;
    DOMHTMLDivElement *origemail;
    BOOL isPlainText; //howdeep
    int textNodeLocation; //which
    DOMNodeList *dhc; //document header children
}

-(id)init;
-(id)initWithBackEnd: (id)backend;
@end

//private methods declared here
@interface MailQuotedOriginal ()
-(void)initVars;
-(void)prepQuotedPlainText;
-(void)removeOriginalPlainTextHeader;
-(void)removeOriginalHeader;
-(void)insertMailHeader:(MailHeaderString *)headStr;
-(void)supportEntourage2004:(DOMDocumentFragment *) headFrag;

@end
