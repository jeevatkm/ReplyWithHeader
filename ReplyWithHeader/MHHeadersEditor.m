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

@interface MHHeadersEditor (MHNoImplementation)
- (void)_subjectChanged;
- (id)backEnd;
- (unsigned long long)type;
- (id)originalMessageHeaders;
- (id)addressListForKey:(NSString *)key;
- (void)setAddresses:(id)arg1;
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

- (void)bringOutlookReplyAllBehaviour
{
    id backEnd = [[self valueForKey:@"_documentEditor"] backEnd];
    id mcMessageHeaders = [backEnd originalMessageHeaders];
    //int msgComposeType = [()backEnd type];
    
    //NSLog(@"Msg Compose type: %d", msgComposeType);
    
    //if (msgComposeType == 2)
    //{
    
    // TODO how to get msg compose type
    // TODO how to get current account email id
    
    NSMutableArray *newToAddressList = [[NSMutableArray alloc] init];
    
    id fromAddress = [mcMessageHeaders addressListForKey:@"from"];
    id toAddressList = [mcMessageHeaders addressListForKey:@"to"];
    MHLog(@"From: %@, To: %@", fromAddress, toAddressList);
    
    if (fromAddress) {
        [newToAddressList addObjectsFromArray:fromAddress];
    }
    
    if (toAddressList) {
        [newToAddressList addObjectsFromArray:toAddressList];
    }
    
    NSLog(@"newToAddressList: %@", newToAddressList);
    [[self valueForKey:@"_toField"] setAddresses:newToAddressList];
    
    NSMutableArray *newCcAddressList = [[NSMutableArray alloc] init];
    id ccAddressList = [mcMessageHeaders addressListForKey:@"cc"];
    
    if (ccAddressList) {
        [newCcAddressList addObjectsFromArray:ccAddressList];
    }
    
    NSLog(@"newCcAddressList: %@", newCcAddressList);
    [[self valueForKey:@"_ccField"] setAddresses:newCcAddressList];
    
    //}
}

@end
