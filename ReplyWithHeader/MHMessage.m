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

// MHMessage Class refactored & completely rewritten by Jeevanandam M. on Sep 23, 2013

#import "MHMessage.h"
#import "MHQuotedMailOriginal.h"

@interface MHMessage (MHNoImplementation)
- (id)type;
@end

@implementation MHMessage

- (void)MHContinueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2 {
    RWH_LOG();
    
    // calling the original implementation
    [self MHContinueToSetupContentsForView: arg1 withParsedMessages: arg2];
    
    // 1=Reply, 2=Reply All, 3=Forward, 4=Draft, 5=New
    int msgCompose = [self type];
    
	if (([RwhMailBundle isEnabled]) && (msgCompose == 1 || msgCompose == 2 || msgCompose == 3)) {
        // Initailzing the quoted text from the original email
        MHQuotedMailOriginal *quotedText = [[MHQuotedMailOriginal alloc] initWithMailMessage:self];
        
        // Create the header string element from the original email
        MHHeaderString *newheaderString = [[MHHeaderString alloc] initWithMailMessage:self];
        
        //insert the new header text
        [quotedText insertMailHeader:newheaderString msgComposeType:msgCompose];
        
        // once done recycle it
        [newheaderString release];
        [quotedText release];
    }
}

@end
