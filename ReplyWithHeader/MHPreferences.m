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

// MHPreferences Class refactored & completely rewritten by Jeevanandam M. on Sep 23, 2013

#import "MHPreferences.h"
#import "MHSignature.h"
#import "Signature.h"
#import "MHDisplayNotes.h"

@interface MHPreferences (MHNoImplementation)
- (id)signatureAccounts;
- (id)signatures;
@end

@interface MHPreferences (PrivateMethods)
    - (IBAction)mailHeaderBundlePressed:(id)sender;
    - (IBAction)headerTypographyPressed:(id)sender;
    - (IBAction)selectFontButtonPressed:(id)sender;
    - (IBAction)headerLabelModePressed:(id)sender;
    - (IBAction)signatureMatrixPressed:(id)sender;
    - (IBAction)openWebsite:(id)sender;
    - (IBAction)openFeedback:(id)sender;
    - (IBAction)openSupport:(id)sender;
    - (IBAction)openCredits:(id)sender;
    - (IBAction)notifyNewVersionPressed:(id)sender;
@end

@implementation MHPreferences

#pragma mark Class private methods

- (void)toggleMailPreferencesOptions:(BOOL *)state
{
    [_MHHeaderTypographyEnabled setEnabled:state];
    [_MHForwardHeaderEnabled setEnabled:state];
    [_MHHeaderOptionEnabled setEnabled:state];
    [_MHNotifyNewVersion setEnabled:state];
    [_MHSubjectPrefixTextEnabled setEnabled:state];
    [_MHRemoveSignatureEnabled setEnabled:state];
    [_MHLanguagePopup setEnabled:state];
    [_MHHeaderAttributionFromTagStyle setEnabled:state];
    
    [self toggleHeaderTypograpghyOptions:state];
    [self toggleHeaderLabelOptions:state];
    [self toggleSignatureTables:state];
}

- (void)toggleHeaderLabelOptions:(BOOL *)state
{
    [_MHHeaderOrderMode setEnabled:state];
    [_MHHeaderLabelMode setEnabled:state];
}

- (void)toggleHeaderTypograpghyOptions:(BOOL *)state
{
    [_MHSelectFont setEnabled:state];
    [_MHColorWell setEnabled:state];
    [_MHHeaderInfoFontAndSize setEnabled:state];
}

- (void)toggleSignatureTables:(BOOL *)state
{
    [_accountsTableView setEnabled:state];
    [_signaturesTableView setEnabled:state];
}

- (NSString *)NameAndVersion
{
    return [MailHeader bundleNameAndVersion];
}

- (NSString *)Copyright
{
    return [MailHeader bundleCopyright];
}

- (IBAction)mailHeaderBundlePressed:(id)sender
{
    [self toggleMailPreferencesOptions:[sender state]];
}

- (IBAction)headerTypographyPressed:(id)sender
{
    [self toggleHeaderTypograpghyOptions:[sender state]];
}

- (IBAction)selectFontButtonPressed:(id)sender
{
    NSString *font = GET_DEFAULT_VALUE(MHHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(MHHeaderFontSize);
    
    [[NSFontPanel sharedFontPanel] setDelegate:self];
    [[NSFontPanel sharedFontPanel] setEnabled:YES];
    [[NSFontPanel sharedFontPanel] makeKeyAndOrderFront:self];

    [[NSFontPanel sharedFontPanel]
     setPanelFont:[NSFont fontWithName:font size:[fontSize floatValue]] isMultiple:NO];
}

- (IBAction)headerLabelModePressed:(id)sender
{
    [self toggleHeaderLabelOptions:[sender state]];
}

- (IBAction)signatureMatrixPressed:(id)sender
{
    NSInteger tag = [sender selectedTag];
    if (1 == tag) {
        [self toggleSignatureTables:FALSE];
    } else {
        [self toggleSignatureTables:TRUE];
    }
}

- (void)changeFont:(id)sender
{
    NSFont *oldFont = _MHHeaderInfoFontAndSize.font;
    NSFont *font = [sender convertFont:oldFont];
    NSString *fontSize = [NSString stringWithFormat: @"%.0f", font.pointSize];
    
    NSString *fontDescription = [NSString stringWithFormat: @"%@ %.0f", font.fontName, font.pointSize];
    
    SET_USER_DEFAULT(font.fontName, MHHeaderFontName);
    SET_USER_DEFAULT(fontSize, MHHeaderFontSize);
    
    [_MHHeaderInfoFontAndSize setStringValue:fontDescription];
}

- (IBAction)openWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader"]];
}

- (IBAction)openFeedback:(id)sender
{
    
    NSAlert *infoAlert = [[NSAlert alloc] init];
    
    [infoAlert setAlertStyle:NSInformationalAlertStyle];
    [infoAlert setMessageText:[NSMutableString stringWithFormat:@"Feedback: %@", [MailHeader bundleNameAndVersion]]];
    [infoAlert setInformativeText:@"Please use Disqus thread on the page, I appreciate your feedback."];    
    [infoAlert setIcon:[MailHeader bundleLogo]];
    // #58 - commented outfor 10.9.2
    //[[[infoAlert buttons] objectAtIndex:0] setKeyEquivalent:@"\r"];
    
    [infoAlert runModal];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader#wp-comments"]];
}

- (IBAction)openSupport:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/jeevatkm/ReplyWithHeader/issues"]];
}

- (IBAction)openCredits:(id)sender
{
    NSString *filePath = [[MailHeader bundle] pathForResource:@"Credits" ofType:@"rtf"];
    MHDisplayNotes *displayNotes = [[MHDisplayNotes alloc] initWithPath:filePath];
    [NSApp runModalForWindow:[displayNotes window]];    
}

- (IBAction)notifyNewVersionPressed:(id)sender
{
    if (![sender state])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        
        [alert setIcon:[MailHeader bundleLogo]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Are you sure you want to disable it?"];
        [alert setInformativeText:@"Missing an opportunity of new version release notification."];
        
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Disable"];
        
        NSArray *buttons = [alert buttons];
        // note: rightmost button is index 0
        [[buttons objectAtIndex:1] setKeyEquivalent:@"\033"];
        [[buttons objectAtIndex:0] setKeyEquivalent:@"\r"];
        
        if ([alert runModal] != NSAlertSecondButtonReturn)
        {
            SET_DEFAULT_BOOL(YES, MHPluginNotifyNewVersion);
            
            [_MHNotifyNewVersion setState:YES];
        }
    }    
}

- (void)loadSignatures
{
    id signatureBundle = [[NSClassFromString(@"SignatureBundle") alloc] init];
    id signatures = [signatureBundle signatures];
    signaturesData = nil;
    signaturesData = [[NSMutableDictionary alloc] init];
    
    NSInteger aCount = 0;
    for (id obj in [signatureBundle signatureAccounts])
    {
        BOOL isActive = (BOOL)[obj valueForKey:@"isActive"];
        
        if (isActive)
        {
            NSString *name = [obj valueForKey:@"displayName"];
            NSString *uniqueId = [[obj valueForKey:@"accountInfo"] valueForKey:@"uniqueId"];
            NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
            
            NSInteger sCount = 0;
            NSArray *signs = [signatures objectForKey:uniqueId];
            if ([signs count] > 0)
            {
                for (int sc = 0; sc<[signs count]; sc++)
                {
                    Signature *s = [signs objectAtIndex:sc];
                    MHSignature *value = [[MHSignature alloc] initWithName:[s name] uniqueId:[s uniqueId] values:nil];
                    [values setObject:value forKey:[self integerToString:sCount]];
                    
                    sCount++;
                }
            }
            
            MHSignature *account = [[MHSignature alloc] initWithName:name uniqueId:uniqueId values:values];
            [signaturesData setObject:account forKey:[self integerToString:aCount]];
            
            aCount++;
        }
    }
    
    [_accountsTableView reloadData];
}

- (NSString*)integerToString:(NSInteger)key
{
    return [NSString stringWithFormat: @"%d", (int)key];
}

- (void)selectRFSignatureForAccount:(NSInteger)key
{
    MHSignature *account = (MHSignature*)[signaturesData objectForKey:[self integerToString:accountIndex]];
    NSString *aui = [[account uniqueId] copy];    
    NSString *sui = [[(MHSignature*)[[account values] objectForKey:[self integerToString:key]] uniqueId] copy];
    
    NSString *sKey = [NSString stringWithFormat:@"MH-S-%@", aui];
    SET_USER_DEFAULT(sui, sKey);
    
    NSLog(@"RWH: Signature mapping for account [%@, %@]: %@", [account name], aui, sui);
}

- (void)highlightSignatureRow
{
    MHSignature *account = (MHSignature*)[signaturesData objectForKey:[self integerToString:accountIndex]];
    NSString *sKey = [NSString stringWithFormat:@"MH-S-%@", [[account uniqueId] copy]];
    
    NSString *signatureId = GET_DEFAULT(sKey);
    MHLog(@"Account [%@, %@]: %@", [account name], sKey, signatureId);
    
    if (nil == signatureId)
    {
        NSLog(@"RWH: Signature mapping doesn't exist");
        
        for (int ic=0; ic<[[[account values] allKeys] count]; ic++) {
            [_signaturesTableView deselectRow:ic];
        }
    }
    else
    {
        MHLog(@"Account Signatures: %@", [account values]);
        
        for (id k in [account values])
        {
            if ([[(MHSignature*)[[account values] objectForKey:k] uniqueId] isEqualToString:signatureId])
            {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[(NSString*)k integerValue]];
                [_signaturesTableView selectRowIndexes:indexSet byExtendingSelection:NO];

                break;
            }
        }
    }
}


#pragma mark NSTableView datasource delegates

// Provides no of rows in the table
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([[tableView identifier] isEqualToString:@"accountsTable"])
    {
        return [[signaturesData allKeys] count];
    }
    else if ([[tableView identifier] isEqualToString:@"signaturesTable"])
    {
        return [[[(MHSignature*)[signaturesData objectForKey:[self integerToString:accountIndex]] values] allKeys] count];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([[aTableView identifier] isEqualToString:@"accountsTable"])
    {
        return [[(MHSignature*)[signaturesData
                  objectForKey:[self integerToString:rowIndex]] name] copy];
    }
    else if ([[aTableView identifier] isEqualToString:@"signaturesTable"])
    {
        return [[(MHSignature*)[[(MHSignature*)[signaturesData
         objectForKey:[self integerToString:accountIndex]] values]
           objectForKey:[self integerToString:rowIndex]] name] copy];
    }
    
    return @"";
}


#pragma mark NSTableView delegate

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return NO;
}

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    MHLog(@"firstIndex %d, lastIndex %d", [proposedSelectionIndexes firstIndex], [proposedSelectionIndexes lastIndex]);
    
    if ([proposedSelectionIndexes firstIndex] != -1)
    {
        if ([[tableView identifier] isEqualToString:@"accountsTable"])
        {
            accountIndex = [proposedSelectionIndexes firstIndex];
            [_signaturesTableView reloadData];
            
            [self highlightSignatureRow];
        }
        else if ([[tableView identifier] isEqualToString:@"signaturesTable"])
        {
            [self selectRFSignatureForAccount:[proposedSelectionIndexes firstIndex]];
        }
    }
    
    return proposedSelectionIndexes;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 17.0;
}


#pragma mark NSTabView delegates

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([@"2" isEqual:[tabViewItem identifier]])
    {
        [self loadSignatures];
    }
}


#pragma mark NSPreferencesModule instance methods

- (void)awakeFromNib
{   
    [self toggleMailPreferencesOptions:[MailHeader isEnabled]];
    
    [_MHHeaderInfoFontAndSize
     setStringValue:[NSString stringWithFormat:@"%@ %@",
                     GET_DEFAULT_VALUE(MHHeaderFontName),
                     GET_DEFAULT_VALUE(MHHeaderFontSize)]];
    
    NSArray *localizations = [[MailHeader bundle] localizations];
    [_MHLanguagePopup removeAllItems];
    
    NSString *supportedLocales = @"";
    for (NSString *lang in localizations)
    {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:lang];
        NSString *name = [locale displayNameForKey:NSLocaleIdentifier value:lang];
        supportedLocales = [supportedLocales stringByAppendingString:name];
        supportedLocales = [supportedLocales stringByAppendingString:@" "];
        
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setRepresentedObject:lang];
        [item setTitle:name];
        
        [[_MHLanguagePopup menu] addItem:item];
    }
    
    MHLog(@"Supported languages %@", supportedLocales);
    
    NSString *localeIdentifier = GET_DEFAULT(MHBundleHeaderLanguageCode);
    if (!localeIdentifier)
    {
        localeIdentifier = [MailHeader localeIdentifier];
    }
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    NSString *name = [locale displayNameForKey:NSLocaleIdentifier value:localeIdentifier];
    [_MHLanguagePopup selectItemWithTitle:name];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languagePopUpSelectionChanged:)
                                                 name:NSMenuDidSendActionNotification
                                               object:[_MHLanguagePopup menu]];   
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( ![MailHeader isLocaleSupported] ) {
        
        [self toggleMailPreferencesOptions:FALSE];
        
        [_MHBundleEnabled setEnabled:FALSE];
        
        NSString *toolTip = [NSString stringWithFormat:@"%@ is currently not supported in your Locale[%@] it may not work as expected, so disabling it.\n\nPlease contact plugin author for support.", [MailHeader bundleNameAndVersion], [MailHeader localeIdentifier]];
        
        [_MHBundleTabBox setToolTip:toolTip];
    }
    
    [self toggleSignatureTables:!GET_DEFAULT_BOOL(MHRemoveSignatureEnabled)];
}

- (NSString*)preferencesNibName
{
    return MHPreferencesNibName;
}

- (NSImage *)imageForPreferenceNamed:(NSString *)aName
{
	return [MailHeader bundleLogo];
}

- (BOOL)isResizable
{
	return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)languagePopUpSelectionChanged:(NSNotification *)notification {
    NSMenuItem *selectedItem = [_MHLanguagePopup selectedItem];
    
    MHLog(@"Choosen language & identifier: %@ - %@",
          [selectedItem title], [selectedItem representedObject]);
    
    SET_USER_DEFAULT([selectedItem representedObject], MHBundleHeaderLanguageCode);
}

@end
