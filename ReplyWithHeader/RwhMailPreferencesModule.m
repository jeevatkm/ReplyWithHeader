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


#import "RwhMailBundle.h"
#import "RwhMailPreferencesModule.h"

NSString *rwhMailIconName = @"ReplyWithHeader";

@implementation RwhMailPreferencesModule

#pragma mark Instance methods

- (void)toggleRwhPreferencesOptions: (BOOL *)state {
    if ( state ) {
        [self enableRwhPreferencesOptions];
    } else {
        [self disableRwhPreferencesOptions];
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



- (NSString *)rwhNameAndVersion {
    return [RwhMailBundle bundleNameAndVersion];
}

- (NSString*)rwhCopyright {
    return [RwhMailBundle bundleCopyright];
}

- (IBAction)rwhMailBundlePressed:(id)sender {
    [self toggleRwhPreferencesOptions:[sender state]];
}

// Open website page
- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader"]];
}

// Open Feedback email
- (IBAction)openFeedback:(id)sender {
    
    NSAlert *infoAlertBox = [[NSAlert alloc] init];
    
    [infoAlertBox setAlertStyle:NSInformationalAlertStyle];
    [infoAlertBox setMessageText:[NSMutableString stringWithFormat:@"Feedback: %@", [RwhMailBundle bundleNameAndVersion]]];
    [infoAlertBox setInformativeText:@"Please use Disqus thread for RWH feedback, I appreciate your feedback."];
    
    [infoAlertBox runModal];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader#wp-comments"]];
    
}

// Open support page
- (IBAction)openSupport:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/jeevatkm/ReplyWithHeaders/issues"]];
}

// load RWH logo
- (void)loadRwhMailBundleLogo {
    [_RwhMailBundleLogo
     setImage:[RwhMailBundle loadImage:rwhMailIconName setSize:NSMakeSize(128, 128)]];
}


#pragma mark NSPreferencesModule instance methods

- (void)awakeFromNib {
    [self toggleRwhPreferencesOptions:[RwhMailBundle isEnabled]];
    
    [self loadRwhMailBundleLogo];
}

- (NSString*)preferencesNibName {
    return RwhMailPreferencesNibName;
}

- (NSImage *)imageForPreferenceNamed:(NSString *)aName {
	return [RwhMailBundle loadImage:rwhMailIconName setSize:NSMakeSize(128, 128)];
}

- (BOOL)isResizable {
	return NO;
}

@end
