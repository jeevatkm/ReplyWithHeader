/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Jeevanandam M.
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
//  MHHeadersEditor.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/28/13.
//
//

#import "MHHeadersEditor.h"
#import "NSString+MailHeader.h"

@interface MHHeadersEditor (MHNoImplementation)
- (void)_subjectChanged;
- (id)backEnd;
- (id)originalMessageHeaders;
- (id)addressListForKey:(NSString *)key;
- (void)setAddresses:(id)arg1;
- (id)mailAccount;
- (id)firstEmailAddress;
- (id)emailAliases;
@end

@implementation MHHeadersEditor

- (void)MHLoadHeadersFromBackEnd:(id)arg1
{
    [self MHLoadHeadersFromBackEnd:arg1];
    
    [self bringOutlookReplyAllBehaviour];
    
    if (GET_DEFAULT_BOOL(MHSubjectPrefixTextEnabled))
    {
        NSMutableString *subjectText = [[(NSTextField *)[self valueForKey:@"_subjectField"] stringValue] mutableCopy];
        
        NSRange range = [subjectText rangeOfString:MHLocalizedStringByLocale(@"STRING_SEARCH_PREFIX_SUBJECT_REPLY", MHLocaleIdentifier)];
        if (range.location != NSNotFound)
        {
            [subjectText replaceCharactersInRange:range withString:MHLocalizedStringByLocale(@"STRING_REPLACE_PREFIX_SUBJECT_REPLY", MHLocaleIdentifier)];
        }
        
        range = [subjectText rangeOfString:MHLocalizedStringByLocale(@"STRING_SEARCH_PREFIX_SUBJECT_FWD", MHLocaleIdentifier)];
        if (range.location != NSNotFound)
        {
            [subjectText replaceCharactersInRange:range withString:MHLocalizedStringByLocale(@"STRING_REPLACE_PREFIX_SUBJECT_FWD", MHLocaleIdentifier)];
        }
        
        [self willChangeValueForKey:@"_subjectField"];
        [(NSTextField *)[self valueForKey:@"_subjectField"] setStringValue:subjectText];
        [self didChangeValueForKey:@"_subjectField"];
        
        // cascading subject text change
        [self _subjectChanged];
    }
}

// for issue - https://github.com/jeevatkm/ReplyWithHeader/issues/82
- (void)bringOutlookReplyAllBehaviour
{
    id addressField = [self valueForKey:@"_toField"];
    if ([addressField respondsToSelector:@selector(addresses)])
    {
        id docEditor = [self valueForKey:@"_documentEditor"];
        id mcMessageHeaders = [[docEditor backEnd] originalMessageHeaders];
        id account = [self mailAccount];
        MHLog(@"Account: %@, Header: %@", account, mcMessageHeaders);
        
        int msgComposeType = [[docEditor valueForKey:@"_messageType"] intValue];
        MHLog(@"msgComposeType: %d", msgComposeType);
    
        // Only for ReplyAll
        if (msgComposeType == 2)
        {
            // Preparing Cc list
            NSArray *oldToList = [[self valueForKey:@"_toField"] addresses];
            NSMutableArray *currentCcList = [[[self valueForKey:@"_ccField"] addresses] mutableCopy];
            [currentCcList removeObjectsInArray:oldToList];
            [[self valueForKey:@"_ccField"] setAddresses:currentCcList];
            MHLog(@"Updated CC list: %@", currentCcList);
            
            // Preparing To list
            NSMutableArray *newToAddressList = [[NSMutableArray alloc] init];
            id fromAddress = [mcMessageHeaders addressListForKey:@"from"];
            id toAddressList = [mcMessageHeaders addressListForKey:@"to"];
            
            MHLog(@"From: %@, To: %@", fromAddress, toAddressList);
            
            if (fromAddress)
            {
                [newToAddressList addObjectsFromArray:fromAddress];
            }
            
            if (toAddressList)
            {
                [newToAddressList addObjectsFromArray:toAddressList];
            }
            
            
            NSArray *emailAliases = [account emailAliases];
            MHLog(@"Email Aliases: %@", emailAliases);
            
            if (emailAliases == nil) {
                NSString *firstEmailAddress = [account firstEmailAddress];
                MHLog(@"Look for firstEmailAddress: %@", firstEmailAddress);

                for (int i=0; i<[newToAddressList count]; i++)
                {
                    NSString *eid = [newToAddressList objectAtIndex:i];
                    if ([eid rangeOf:firstEmailAddress].location != NSNotFound)
                    {
                        MHLog(@"Found firstEmailAddress: %@, Index is %d", firstEmailAddress, i);
                        [newToAddressList removeObjectAtIndex:i];
                    }
                }
            } else {
                for(int i=0; i<[emailAliases count]; i++) {
                    NSString *emailId = [emailAliases[i] valueForKey:@"alias"];
                    MHLog(@"email %@", emailId);
                    
                    for (int i=0; i<[newToAddressList count]; i++)
                    {
                        NSString *eid = [newToAddressList objectAtIndex:i];
                        if ([eid rangeOf:emailId].location != NSNotFound)
                        {
                            MHLog(@"Found emailAlias: %@, Index is %d", emailId, i);
                            [newToAddressList removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }
            
            MHLog(@"newToAddressList: %@", newToAddressList);
            [[self valueForKey:@"_toField"] setAddresses:newToAddressList];
        }
    }
    else
    {
        MHLog(@"Outlook Reply behavior is not applied");
    }
}

@end
