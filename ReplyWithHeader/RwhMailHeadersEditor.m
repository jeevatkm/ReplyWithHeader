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
//  RwhMailHeadersEditor.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/28/13.
//
//

#import "RwhMailHeadersEditor.h"
#import "RwhMailConstants.h"
#import "RwhMailMacros.h"

@interface RwhMailHeadersEditor (RwhNoImplementation)
- (void)_subjectChanged;
@end

@implementation RwhMailHeadersEditor

- (void)rwhLoadHeadersFromBackEnd:(id)arg1 {
    RWH_LOG();
    
    // calling original implementation
    [self rwhLoadHeadersFromBackEnd:arg1];
    
    if (GET_DEFAULT_BOOL(RwhMailSubjectPrefixTextEnabled)) {
        NSMutableString *subjectText = [[(NSTextField *)[self valueForKey:@"_subjectField"] stringValue] mutableCopy];
        
        NSRange range = [subjectText rangeOfString:@"Re: "];
        if (range.location != NSNotFound) {
            [subjectText replaceCharactersInRange:range withString:@"RE: "];
        }
        
        range = [subjectText rangeOfString:@"Fwd: "];
        if (range.location != NSNotFound) {
            [subjectText replaceCharactersInRange:range withString:@"FW: "];
        }
        
        [self willChangeValueForKey:@"_subjectField"];
        [(NSTextField *)[self valueForKey:@"_subjectField"] setStringValue:subjectText];
        [self didChangeValueForKey:@"_subjectField"];
        
        // cascading subject text change
        [self _subjectChanged];
    }    
}

@end
