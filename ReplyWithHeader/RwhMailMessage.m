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


#import "RwhMailMessage.h"

@implementation RwhMailMessage

- (void)rph_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2 {
    //Log that we are here
    RWH_LOG();
    
    //if we sizzled, this should be fine... (because this would be calling the original implementation)
    [self rph_continueToSetupContentsForView: arg1 withParsedMessages: arg2];

    BOOL rwhEnabled = GET_BOOL_USER_DEFAULT(RwhBundleEnabled);
    BOOL rwhReplaceForwardHeaderEnabled = GET_BOOL_USER_DEFAULT(RwhForwardHeaderEnabled);
    
    //get my type and check it - reply or replyall only
    int selftype=[self type];
    
    RWH_LOG(@"message type is %d",selftype);
    
	if( rwhEnabled ) {    
        if( (selftype==1 || selftype==2) ) {
            //start by setting up the quoted text from the original email
            RwhMailQuotedOriginal *quotedText = [[RwhMailQuotedOriginal alloc] initWithBackEnd:self];
        
            //create the header string element
            RwhMailHeaderString *newheaderString = [[RwhMailHeaderString alloc] initWithBackEnd:self];
        
            //this is required for Mountain Lion - for some reason the mail headers are not bold anymore.
            [newheaderString boldHeaderLabels];
        
            RWH_LOG(@"Sig=%@",[newheaderString string]);
        
            //insert the new header text
            [quotedText insertMailHeader:newheaderString];
        }
        
        if( rwhReplaceForwardHeaderEnabled && selftype == 3 ) {
            //start by setting up the quoted text from the original email
            RwhMailQuotedOriginal *quotedText = [[RwhMailQuotedOriginal alloc] initWithBackEnd:self];
            [quotedText insertFwdHeader];
        }
    }
}


@end
