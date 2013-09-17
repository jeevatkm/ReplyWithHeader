/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
 *               2012, 2013 Jason Schroth
 *               2010, 2013 Saptarshi Guha
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
    DOMDocumentFragment *fwdborder;
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
-(void)insertFwdHeader;
-(void)supportEntourage2004:(DOMDocumentFragment *) headFrag;

@end
