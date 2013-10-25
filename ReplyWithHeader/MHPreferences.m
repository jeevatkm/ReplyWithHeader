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

// MHPreferences Class refactored & completely rewritten by Jeevanandam M. on Sep 23, 2013 

#import "MHPreferences.h"

@interface MHPreferences (PrivateMethods)
    - (IBAction)MailHeaderBundlePressed:(id)sender;
    - (IBAction)HeaderTypographyPressed:(id)sender;
    - (IBAction)SelectFontButtonPressed:(id)sender;
    - (IBAction)HeaderLabelModePressed:(id)sender;
    - (IBAction)openWebsite:(id)sender;
    - (IBAction)openFeedback:(id)sender;
    - (IBAction)openSupport:(id)sender;
    - (IBAction)notifyNewVersionPressed:(id)sender;
@end

@implementation MHPreferences

#pragma mark Class private methods

- (void)toggleRwhPreferencesOptions:(BOOL *)state
{
    [_MHHeaderTypographyEnabled setEnabled:state];    
    [_MHForwardHeaderEnabled setEnabled:state];
    [_MHHeaderOptionEnabled setEnabled:state];
    [_MHEntourage2004SupportEnabled setEnabled:state];
    [_MHNotifyNewVersion setEnabled:state];
    [_MHSubjectPrefixTextEnabled setEnabled:state];
    
    [self toggleRwhHeaderTypograpghyOptions:state];
    [self toggleRwhHeaderLabelOptions:state];
}

- (void)toggleRwhHeaderLabelOptions:(BOOL *)state
{
    [_MHHeaderOrderMode setEnabled:state];
    [_MHHeaderLabelMode setEnabled:state];
}

- (void)toggleRwhHeaderTypograpghyOptions:(BOOL *)state
{
    [_MHSelectFont setEnabled:state];
    [_MHColorWell setEnabled:state];
}

- (NSString *)NameAndVersion
{
    return [MailHeader bundleNameAndVersion];
}

- (NSString *)Copyright
{
    return [MailHeader bundleCopyright];
}

- (IBAction)MailHeaderBundlePressed:(id)sender
{
    [self toggleRwhPreferencesOptions:[sender state]];
}

- (IBAction)HeaderTypographyPressed:(id)sender
{
    [self toggleRwhHeaderTypograpghyOptions:[sender state]];
}

- (IBAction)SelectFontButtonPressed:(id)sender
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    [fontManager setTarget:self];
    [fontManager orderFrontFontPanel:self];
    
    NSString *font = GET_DEFAULT_VALUE(MHHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(MHHeaderFontSize);
    
    [fontManager setSelectedFont:[NSFont fontWithName:font size:[fontSize floatValue]] isMultiple:NO];
}

- (IBAction)HeaderLabelModePressed:(id)sender
{
    [self toggleRwhHeaderLabelOptions:[sender state]];
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
    [[[infoAlert buttons] objectAtIndex:0] setKeyEquivalent:@"\r"];
    
    [infoAlert runModal];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader#wp-comments"]];
    
    CLEAN(infoAlert);
}

- (IBAction)openSupport:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/jeevatkm/ReplyWithHeaders/issues"]];
}

- (IBAction)notifyNewVersionPressed:(id)sender
{
    
    if (![sender state])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        
        [alert setIcon:[MailHeader bundleLogo]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Are you sure you want to disable it?"];
        [alert setInformativeText:@"Missing a opportunity of new version release notification."];
        
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
        
        CLEAN(alert);
    }    
}


#pragma mark NSPreferencesModule instance methods

- (void)awakeFromNib
{   
    [self toggleRwhPreferencesOptions:[MailHeader isEnabled]];
    
    [_MHHeaderInfoFontAndSize
     setStringValue:[NSString stringWithFormat:@"%@ %@",
                     GET_DEFAULT_VALUE(MHHeaderFontName),
                     GET_DEFAULT_VALUE(MHHeaderFontSize)]];
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( ![MailHeader isLocaleSupported] ) {
        [self toggleRwhHeaderLabelOptions:FALSE];
        [_MHHeaderOptionEnabled setEnabled:FALSE];
        
        NSString *toolTip = @"Currently this feature is supported in english(en) locale only.";
        [_MHHeaderOptionEnabled setToolTip:toolTip];
        [_MHHeaderLabelMode setToolTip:toolTip];
        [_MHHeaderOrderMode setToolTip:toolTip];
    }
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

@end
