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


#import "NSPreferencesModule.h"

/*!
 * @class
 * The <code>MHPreferences</code> class is the subclass of
 * <code>NSPreferencesModule</code> that displays and manages preferences
 * specific to the MailHeader plugin.
 *
 * MHPreferences Class refactored & completely rewritten by Jeevanandam M. on Sep 23, 2013 
 */
@interface MHPreferences : NSPreferencesModule <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
    NSMutableDictionary *signaturesData;
    NSInteger accountIndex;
    
    IBOutlet NSTabView *_MHBundleTabBox;
    IBOutlet NSButton *_MHBundleEnabled;
    IBOutlet NSButton *_MHForwardHeaderEnabled;
    //IBOutlet NSButton *_MHHeaderTypographyEnabled;
    IBOutlet NSButton *_MHSelectFont;
    //IBOutlet NSButton *_MHHeaderOptionEnabled;
    IBOutlet NSButton *_MHNotifyNewVersion;
    IBOutlet NSButton *_MHSubjectPrefixTextEnabled;
    IBOutlet NSButton *_MHRawHeadersEnabled;
    IBOutlet NSMatrix *_MHRemoveSignatureEnabled;
    IBOutlet NSTextField *_MHHeaderInfoFontAndSize;
    IBOutlet NSColorWell *_MHColorWell;
    /*IBOutlet NSMatrix *_MHHeaderOrderMode;
    IBOutlet NSMatrix *_MHHeaderLabelMode; */
    IBOutlet NSPopUpButton *_MHLanguagePopup;
    IBOutlet NSMatrix *_MHHeaderAttributionFromTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionToCcTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionLblSeqTagStyle;
    IBOutlet NSTableView *_accountsTableView;
    IBOutlet NSTableView *_signaturesTableView;
    IBOutlet NSButton *_MHPaypalBtn;
}

@property(weak, readonly) NSString *NameAndVersion, *Copyright;

#pragma mark NSPreferencesModule instance methods

- (void)awakeFromNib;
- (NSString*)preferencesNibName;
- (NSImage *)imageForPreferenceNamed:(NSString *)aName;
- (BOOL)isResizable;

@end
