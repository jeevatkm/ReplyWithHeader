/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Jeevanandam M.
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

#import "MHMailMessage.h"
#import "MHQuotedMailOriginal.h"
#import "MHHeaderString.h"
#import "Signature.h"

@interface MHMailMessage (MHNoImplementation)
- (int)type;
- (id)account;
- (id)deliveryAccount;
@end

@implementation MHMailMessage

- (void)MH_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2
{
    [self MH_continueToSetupContentsForView: arg1 withParsedMessages: arg2];
    
    // 1=Reply, 2=Reply All, 3=Forward, 4=Draft, 5=New
    int msgCompose = [self type];
    
    MHLog(@"Message compose type is %d", msgCompose);
    
	if (([MailHeader isEnabled]) && (msgCompose == 1 || msgCompose == 2 || msgCompose == 3))
    {
        // Initailzing the quoted text from the original email
        MHQuotedMailOriginal *quotedText = [[MHQuotedMailOriginal alloc] initWithMailMessage:self msgComposeType:msgCompose];
        
        // Create the header string element from the original email
        MHHeaderString *newheaderString = [[MHHeaderString alloc] initWithMailMessage:self];
        
        //insert the new header text
        [quotedText insertMailHeader:newheaderString];
    }
}

// for issue #24 - https://github.com/jeevatkm/ReplyWithHeader/issues/24
- (BOOL)MHokToAddSignatureAutomatically
{
    return (([MailHeader isEnabled] && ([self type] == 1 || [self type] == 2 || [self type] == 3))
        ? !GET_DEFAULT_BOOL(MHRemoveSignatureEnabled) : [self MHokToAddSignatureAutomatically]);
}

// for issue #27 - https://github.com/jeevatkm/ReplyWithHeader/issues/27
- (BOOL)MHincludeHeaders
{
    BOOL include = [self MHincludeHeaders];
    
    if([MailHeader isEnabled] && GET_DEFAULT_BOOL(MHForwardHeaderEnabled) && [self type] == 3)
        include = FALSE;
    
    return include;
}

- (id)MHsignatureId
{
    if ([MailHeader isEnabled] && ([self type] == 1 || [self type] == 2 || [self type] == 3) && !GET_DEFAULT_BOOL(MHRemoveSignatureEnabled))
    {
        //NSString *uniqueId = [[[self account] valueForKey:@"accountInfo"] valueForKey:@"uniqueId"];
        // for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/90
        NSString *uniqueId = @"";
        //if ([[MailHeader getOSXVersion] isEqualToString:@"10.11"]) TODO - cleanup before release
        if ([MailHeader isElCapitan])
        {
            MHLog(@"It's El Capitan, handle accordingly");
            uniqueId = [[self account] valueForKey:@"identifier"];
        }
        else
        {
            uniqueId = [[[self account] valueForKey:@"accountInfo"] valueForKey:@"uniqueId"];
        }
        
        NSString *sKey = [NSString stringWithFormat:@"MH-S-%@", uniqueId];
        NSString *signatureId = GET_DEFAULT(sKey);
        
        MHLog(@"Account ID: %@, Name: %@, Signature ID: %@", sKey, [[self account] valueForKey:@"displayName"], signatureId);
        
        if (nil == signatureId)
        {
            return [self MHsignatureId];
        }
        
        return [signatureId copy];
    }
    
    return [self MHsignatureId];
}

@end
