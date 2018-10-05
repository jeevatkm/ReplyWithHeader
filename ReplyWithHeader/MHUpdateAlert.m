/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2018 Jeevanandam M.
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
//  MHUpdateAlert.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/6/13.
//
//

#import <WebKit/WebKit.h>

#import "MHUpdateAlert.h"

@interface MHUpdateAlert ()
- (IBAction)downloadButtonClicked:(id)sender;
- (IBAction)laterButtonClicked:(id)sender;
@end

@implementation MHUpdateAlert

- (IBAction)downloadButtonClicked:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadLink]];
    [NSApp stopModal];
    [self close];
}

- (IBAction)laterButtonClicked:(id)sender
{
    [NSApp stopModal];
    [self close];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSString *pluginName = [MailHeader bundleName];    
    [[self window]
     setTitle:[NSString stringWithFormat:MHLocalizedStringByLocale(@"STRING_UPDATE_WINDOW_TITLE", MHLocaleIdentifier), pluginName]];
    
    [_subTitle setStringValue:[NSString stringWithFormat:MHLocalizedStringByLocale(@"STRING_UPDATE_WINDOW_SUBTITLE", MHLocaleIdentifier), pluginName]];
    [_versionDesc setStringValue:versionDesc];    
    [[_releaseNotesView mainFrame] loadHTMLString:releaseNotes baseURL:nil];
}

- (NSString *)windowNibName {
	return NSStringFromClass([MHUpdateAlert class]);
}

- (void)awakeFromNib
{
    [[self window] setShowsResizeIndicator: NO];
    [[self window] center];
    
    // default font
	[_releaseNotesView setPreferencesIdentifier:[MailHeader bundleIdentifier]];
	[[_releaseNotesView preferences] setStandardFontFamily:[[NSFont systemFontOfSize:8] familyName]];
	[[_releaseNotesView preferences] setDefaultFontSize:(int)[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
	[_releaseNotesView setFrameLoadDelegate:self];
    [_releaseNotesView setUIDelegate:self];
    [_releaseNotesView setEditingDelegate:self];
    
    [_laterButton setKeyEquivalent:@"\033"];
    [_downloadButton setKeyEquivalent:@"\r"];
}

- (id)initWithData:(NSString *)desc releaseNotes:(NSString *)notes donwloadLink:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        versionDesc = [desc copy];
        releaseNotes = [notes copy];
        downloadLink = [urlString copy];
        
        [self setShouldCascadeWindows:NO];
        [WebView MIMETypesShownAsHTML];
    }
    return self;
}

#pragma Mark WebView Delegates

// necessary to prevent weird scroll bar artifacting
- (void)webView:(WebView *)sender didFinishLoadForFrame:frame
{
    if ([frame parentFrame] == nil)
    {
		[sender display]; 
    }
}

// disable right-click context menu
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    return nil;
}

// disable text selection
- (BOOL)webView:(WebView *)webView shouldChangeSelectedDOMRange:(DOMRange *)currentRange
     toDOMRange:(DOMRange *)proposedRange
       affinity:(NSSelectionAffinity)selectionAffinity
 stillSelecting:(BOOL)flag
{
    return NO;
}

@end
