/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2019 Jeevanandam M.
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
//  MHPreferences.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/5/18.
//

@interface MHPreferences : NSWindowController<NSTableViewDelegate, NSTableViewDataSource>
{
    NSMutableDictionary *signaturesData;
    NSInteger accountIndex;
    
    IBOutlet NSTabView *_MHBundleTabBox;
    IBOutlet NSButton *_MHBundleEnabled;
    IBOutlet NSButton *_MHSelectFont;
    IBOutlet NSButton *_MHNotifyNewVersion;
    IBOutlet NSButton *_MHSubjectPrefixTextEnabled;
    IBOutlet NSButton *_MHRawHeadersEnabled;
    IBOutlet NSMatrix *_MHRemoveSignatureEnabled;
    IBOutlet NSTextField *_MHHeaderInfoFontAndSize;
    IBOutlet NSColorWell *_MHColorWell;
    IBOutlet NSPopUpButton *_MHLanguagePopup;
    IBOutlet NSMatrix *_MHHeaderAttributionFromTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionToCcTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionLblSeqTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionDateTagStyle;
    IBOutlet NSMatrix *_MHHeaderAttributionTimeTagStyle;
    IBOutlet NSButton *_MHHeaderAttributionShortTimeZoneStyle;
    IBOutlet NSPopUpButton *_MHLineSpaceBeforeHeaderPopup;
    IBOutlet NSPopUpButton *_MHLineSpaceAfterHeaderPopup;
    IBOutlet NSPopUpButton *_MHLineSpaceBeforeHeaderSepPopup;
    IBOutlet NSButton *_MHHeaderBlueLineBorderEnabled;
    IBOutlet NSTableView *_accountsTableView;
    IBOutlet NSTableView *_signaturesTableView;
    IBOutlet NSButton *_MHPaypalBtn;
}

@property(weak, readonly) NSString *NameAndVersion, *Copyright;

- (void)toggleMailPreferencesOptions:(BOOL *)state;

@end
