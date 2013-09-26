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

// RwhMailQuotedOriginal Class completely rewritten by Jeevanandam M. on Sep 23, 2013 

#import "RwhMailBundle.h"
#import "RwhMailPreferencesModule.h"
#import "RwhMailConstants.h"
#import "RwhMailMacros.h"

@interface RwhMailPreferencesModule (PrivateMethods)
- (IBAction)rwhMailBundlePressed:(id)sender;
- (IBAction)rwhHeaderTypographyPressed:(id)sender;
- (IBAction)rwhSelectFontPressed:(id)sender;
- (IBAction)rwhHeaderLabelModePressed:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)openFeedback:(id)sender;
- (IBAction)openSupport:(id)sender;
@end

@implementation RwhMailPreferencesModule

#pragma mark Class private methods

- (void)toggleRwhPreferencesOptions:(BOOL *)state {    
    [_RwhHeaderTypographyEnabled setEnabled:state];    
    [_RwhForwardHeaderEnabled setEnabled:state];
    [_RwhMailHeaderOptionModeEnabled setEnabled:state];
    [_RwhEntourage2004SupportEnabled setEnabled:state];
    
    [self toggleRwhHeaderTypograpghyOptions:state];
    [self toggleRwhHeaderLabelOptions:state];
}

- (void)toggleRwhHeaderLabelOptions:(BOOL *)state {
    [_RwhMailHeaderOrderMode setEnabled:state];
    [_RwhMailHeaderLabelMode setEnabled:state];
}

- (void)toggleRwhHeaderTypograpghyOptions:(BOOL *)state {
    [_RwhMailSelectFont setEnabled:state];
    [_RwhMailColorWell setEnabled:state];
}

- (NSString *)rwhNameAndVersion {
    return [RwhMailBundle bundleNameAndVersion];
}

- (NSString *)rwhCopyright {
    return [RwhMailBundle bundleCopyright];
}

- (IBAction)rwhMailBundlePressed:(id)sender {
    [self toggleRwhPreferencesOptions:[sender state]];
}

- (IBAction)rwhHeaderTypographyPressed:(id)sender {
    [self toggleRwhHeaderTypograpghyOptions:[sender state]];
}

- (IBAction)rwhSelectFontPressed:(id)sender {
    RWH_LOG();
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    [fontManager setTarget:self];
    [fontManager orderFrontFontPanel:self];
    
    NSString *font = GET_DEFAULT_VALUE(RwhMailHeaderFontName);
    NSString *fontSize = GET_DEFAULT_VALUE(RwhMailHeaderFontSize);
    
    [fontManager setSelectedFont:[NSFont fontWithName:font size:[fontSize floatValue]] isMultiple:NO];
}

- (IBAction)rwhHeaderLabelModePressed:(id)sender {
    [self toggleRwhHeaderLabelOptions:[sender state]];
}

- (void)changeFont:(id)sender {
    RWH_LOG();
    
    NSFont *oldFont = _RwhMailHeaderFontNameAndSize.font;
    NSFont *font = [sender convertFont:oldFont];
    NSString *fontSize = [NSString stringWithFormat: @"%.0f", font.pointSize];
    
    NSString *fontDescription = [NSString stringWithFormat: @"%@ %.0f", font.fontName, font.pointSize];
    
    SET_USER_DEFAULT(font.fontName, RwhMailHeaderFontName);
    SET_USER_DEFAULT(fontSize, RwhMailHeaderFontSize);
    
    [_RwhMailHeaderFontNameAndSize setStringValue:fontDescription];
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
    [infoAlertBox setInformativeText:@"Please use Disqus thread on the page, I appreciate your feedback."];    
    [infoAlertBox setIcon:[RwhMailBundle bundleLogo]];
    
    [infoAlertBox runModal];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader#wp-comments"]];
    
    [infoAlertBox release];
}

// Open support page
- (IBAction)openSupport:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/jeevatkm/ReplyWithHeaders/issues"]];
}


#pragma mark NSPreferencesModule instance methods

- (void)awakeFromNib {
    RWH_LOG();
    
    [self toggleRwhPreferencesOptions:[RwhMailBundle isEnabled]];
    
    [_RwhMailHeaderFontNameAndSize
     setStringValue:[NSString stringWithFormat:@"%@ %@",
                     GET_DEFAULT_VALUE(RwhMailHeaderFontName),
                     GET_DEFAULT_VALUE(RwhMailHeaderFontSize)]];
    
    [_RwhMailBundleLogo setImage:[RwhMailBundle bundleLogo]];
}

- (NSString*)preferencesNibName {
    return RwhMailPreferencesNibName;
}

- (NSImage *)imageForPreferenceNamed:(NSString *)aName {    
	return [RwhMailBundle bundleLogo];
}

- (BOOL)isResizable {
	return YES;
}

@end
