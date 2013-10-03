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
//  NSPreferences+MailHeader.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/30/13.
//
//

#import "NSPreferences+MailHeader.h"
#import "MHPreferences.h"
#import "RwhMailBundle.h"

@implementation NSPreferences (MailHeader)

+ (id)MHSharedPreferences {
	static BOOL added = NO;
	
	id preferences = [self MHSharedPreferences];
    
    if(preferences == nil)
        return nil;
    
    if(added)
        return preferences;
    
    // Check modules, if MailHeaderPreferences is not yet in there.
    NSPreferencesModule *mailHeaderPreferences = [MHPreferences sharedInstance];
    NSString *preferencesName = [RwhMailBundle preferencesPanelName];
    [preferences addPreferenceNamed:preferencesName owner:mailHeaderPreferences];
    added = YES;
	
    NSWindow *preferencesPanel = [preferences valueForKey:@"_preferencesPanel"];
    NSToolbar *toolbar = [preferencesPanel toolbar];
    
    // If the toolbar is nil, the setup will be done later by Mail.app.
    if(!toolbar)
        return preferences;
    
    [preferences resizeWindowToShowAllToolbarItems:preferencesPanel];
    
    return preferences;
}


- (NSSize)sizeForWindowShowingAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    float width = 0.0f;
	NSArray *subviews = [[[[[window toolbar]
                            valueForKey:@"_toolbarView"] subviews] objectAtIndex:0] subviews];
    for (NSView *view in subviews) {
        width += view.frame.size.width;
	}
    // Add padding to fit them all.
    width += 10;
    
    return NSMakeSize(width > frame.size.width ? width : frame.size.width, frame.size.height);
}

- (NSSize)MHWindowWillResize:(id)window toSize:(NSSize)toSize {
    return [self sizeForWindowShowingAllToolbarItems:window];
}

- (void)resizeWindowToShowAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    frame.size = [self sizeForWindowShowingAllToolbarItems:window];
    [window setFrame:frame display:YES];
}

- (void)MHToolbarItemClicked:(id)toolbarItem {
    // Resize the window, otherwise it would make it small
    // again.
    [self MHToolbarItemClicked:toolbarItem];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

- (void)MHShowPreferencesPanelForOwner:(id)owner {
    [self MHShowPreferencesPanelForOwner:owner];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

@end
