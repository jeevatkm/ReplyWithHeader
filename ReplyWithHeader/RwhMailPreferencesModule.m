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



#import "RwhMailPreferencesModule.h"

@implementation RwhMailPreferencesModule

- (void)awakeFromNib {
    RWH_LOG();
    
    [self toggleRwhPreferencesOptions:GET_BOOL_USER_DEFAULT(RwhBundleEnabled)];
}

- (IBAction)rwhMailBundlePressed:(id)sender {
    RWH_LOG();
    
    [self toggleRwhPreferencesOptions:[sender state]];
}


#pragma mark NSPreferencesModule instance methods

- (NSString*)preferencesNibName {
    RWH_LOG();
    
    return RwhMailPreferencesNibName;
}

#pragma mark Instance methods

- (void)toggleRwhPreferencesOptions: (BOOL *)state {
    if ( state ) {
        [self enableRwhPreferencesOptions];
        
        NSLog(@"RWH %@ mail bundle is enabled in perferences", GET_BUNDLE_VALUE(RwhBundleVersionKey));
    } else {
        [self disableRwhPreferencesOptions];
        
        NSLog(@"RWH %@ mail bundle is disabled in perferences", GET_BUNDLE_VALUE(RwhBundleVersionKey));
    }
}

- (void)enableRwhPreferencesOptions {
    [_RwhReplyHeaderText setEnabled:YES];
    [_RwhEntourage2004SupportEnabled setEnabled:YES];
    [_RwhForwardHeaderEnabled setEnabled:YES];
    [_RwhForwardHeaderText setEnabled:YES];
}

- (void)disableRwhPreferencesOptions {
    [_RwhReplyHeaderText setEnabled:NO];
    [_RwhEntourage2004SupportEnabled setEnabled:NO];
    [_RwhForwardHeaderEnabled setEnabled:NO];
    [_RwhForwardHeaderText setEnabled:NO];
}

- (NSString*)rwhVersion {
    return GET_BUNDLE_VALUE(RwhBundleVersionKey);
}


- (NSString*)rwhCopyright {
    return GET_BUNDLE_VALUE(RwhCopyRightOwnerKey);
}
@end
