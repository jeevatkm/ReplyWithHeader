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
//  MHCodeInjector.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/6/13.
//
//

#import "MHCodeInjector.h"
#import "JRLPSwizzle.h"

#pragma mark Constants and global variables

NSString *MailHeaderSwizzledMethodPrefix = @"MH";

@implementation MHCodeInjector

+ (void)injectMailHeaderCode
{
    NSError * __autoreleasing error = nil;
    
    Class composeBackEnd = NSClassFromString(@"ComposeBackEnd");
    if (composeBackEnd)
    {
        [composeBackEnd jrlp_addMethodsFromClass:NSClassFromString(@"MHMailMessage") error:&error];
        
        [composeBackEnd jrlp_swizzleMethod:@selector(_continueToSetupContentsForView:withParsedMessages:) withMethod:@selector(MH_continueToSetupContentsForView:withParsedMessages:) error:&error];
        
        [composeBackEnd jrlp_swizzleMethod:@selector(includeHeaders)
                                withMethod:@selector(MHincludeHeaders) error:&error];
        
        [composeBackEnd jrlp_swizzleMethod:@selector(okToAddSignatureAutomatically)
                                withMethod:@selector(MHokToAddSignatureAutomatically) error:&error];
        
        [composeBackEnd jrlp_swizzleMethod:@selector(signatureId)
                                withMethod:@selector(MHsignatureId) error:&error];
    }
    
    Class headerEditor = NSClassFromString(@"HeadersEditor");
    if (headerEditor)
    {
        [headerEditor jrlp_addMethodsFromClass:NSClassFromString(@"MHHeadersEditor") error:&error];
        
        [headerEditor jrlp_swizzleMethod:@selector(loadHeadersFromBackEnd:)
                              withMethod:@selector(MHLoadHeadersFromBackEnd:) error:&error];
    }
    
    
    Class nsPref = NSClassFromString(@"NSPreferences");
    if (nsPref)
    {
        [nsPref jrlp_swizzleClassMethod:@selector(sharedPreferences)
                        withClassMethod:@selector(MHSharedPreferences) error:&error];
        
        [nsPref jrlp_swizzleMethod:@selector(windowWillResize:toSize:)
                        withMethod:@selector(MHWindowWillResize:toSize:) error:&error];
        
        [nsPref jrlp_swizzleMethod:@selector(toolbarItemClicked:)
                        withMethod:@selector(MHToolbarItemClicked:) error:&error];
        
        [nsPref jrlp_swizzleMethod:@selector(showPreferencesPanelForOwner:)
                        withMethod:@selector(MHShowPreferencesPanelForOwner:) error:&error];
    }
}

@end
