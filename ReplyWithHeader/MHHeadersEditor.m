/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
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
@end

@implementation MHHeadersEditor

- (void)MHLoadHeadersFromBackEnd:(id)arg1
{
    MH_LOG();
    
    // calling original implementation
    [self MHLoadHeadersFromBackEnd:arg1];
    
    if (GET_DEFAULT_BOOL(MHSubjectPrefixTextEnabled))
    {
        NSMutableString *subjectText = [[(NSTextField *)[self valueForKey:@"_subjectField"] stringValue] mutableCopy];
        
        NSRange range = [subjectText rangeOfString:MHLocalizedString(@"STRING_SEARCH_PREFIX_SUBJECT_REPLY")];
        if (range.location != NSNotFound)
        {
            [subjectText replaceCharactersInRange:range withString:MHLocalizedString(@"STRING_REPLACE_PREFIX_SUBJECT_REPLY")];
        }
        
        range = [subjectText rangeOfString:MHLocalizedString(@"STRING_SEARCH_PREFIX_SUBJECT_FWD")];
        if (range.location != NSNotFound)
        {
            [subjectText replaceCharactersInRange:range withString:MHLocalizedString(@"STRING_REPLACE_PREFIX_SUBJECT_FWD")];
        }
        
        [self willChangeValueForKey:@"_subjectField"];
        [(NSTextField *)[self valueForKey:@"_subjectField"] setStringValue:subjectText];
        [self didChangeValueForKey:@"_subjectField"];
        
        // cascading subject text change
        [self _subjectChanged];
    }    
}

@end
