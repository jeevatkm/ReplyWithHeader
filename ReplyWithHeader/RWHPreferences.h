//
//  RWHPreferences.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/5/18.
//

@interface RWHPreferences : NSWindowController<NSTableViewDelegate, NSTableViewDataSource>
{
    NSMutableDictionary *signaturesData;
    NSInteger accountIndex;
    
//    IBOutlet NSBox *_preferencesView;
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
    IBOutlet NSPopUpButton *_MHLineSpaceBeforeHeaderPopup;
    IBOutlet NSPopUpButton *_MHLineSpaceAfterHeaderPopup;
    IBOutlet NSPopUpButton *_MHLineSpaceBeforeHeaderSepPopup;
    IBOutlet NSTableView *_accountsTableView;
    IBOutlet NSTableView *_signaturesTableView;
    IBOutlet NSButton *_MHPaypalBtn;
}

@property(weak, readonly) NSString *NameAndVersion, *Copyright;

- (void)toggleMailPreferencesOptions:(BOOL *)state;

@end
