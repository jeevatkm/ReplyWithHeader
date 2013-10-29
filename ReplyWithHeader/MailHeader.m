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
 *
 * MailHeader Class completely rewritten by Jeevanandam M. on Sep 21, 2013
 */

#import "MailHeader.h"
#import "MHCodeInjector.h"
#import "MHPreferences.h"
#import "MHUpdater.h"

@interface MailHeader (MHNoImplementation)
+ (void)registerBundle;
@end

@implementation MailHeader

#pragma mark Class public methods

+ (BOOL)isEnabled
{
    return GET_DEFAULT_BOOL(MHBundleEnabled);
}

+ (BOOL)isLocaleSupported
{
    static BOOL supported;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *preferredLocale = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if ( preferredLocale && [preferredLocale isEqualToString:@"en"] ) {
            supported = TRUE;
        }
        else
        {
            supported = FALSE;
        }
    });
    return supported;
}

+ (NSBundle *)bundle
{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[MailHeader class]];
    });
    return bundle;
}

+ (NSString *)bundleIdentifier
{
    return [[[self bundle] infoDictionary] objectForKey:MHBundleIdentifier];
}

+ (NSString *)bundleNameAndVersion
{
    return [NSMutableString stringWithFormat:@"%@ v%@", [self bundleName], [self bundleVersionString]];
}

+ (NSString *)bundleName
{
    return MHLocalizedString(@"PLUGIN_NAME");
}

+ (NSString *)bundleVersionString
{
    return [[[self bundle] infoDictionary] objectForKey:MHBundleShortVersionKey];
}

+ (NSString *)bundleCopyright
{
    return MHLocalizedString(@"COPYRIGHT");
}

+ (NSImage *)bundleLogo
{
    static NSImage *logo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logo = [[NSImage alloc]
                initByReferencingFile:[[self bundle] pathForImageResource:@"ReplyWithHeader"]];
        [logo setSize:NSMakeSize(128, 128)];
    });
    return logo;
}

+ (NSString *)localizedString:(NSString *)key
{
    NSBundle *mhBundle = [MailHeader bundle];
    NSString *localString = NSLocalizedStringFromTableInBundle(key, @"MailHeader", mhBundle, nil);
    
    if(![localString isEqualToString:key])
        return localString;
    
    NSBundle *englishLanguage = [NSBundle
                                 bundleWithPath:[mhBundle
                                                 pathForResource:@"en" ofType:@"lproj" inDirectory:@"MailHeader"]];
    return [englishLanguage localizedStringForKey:key value:@"" table:@"MailHeader"];
}

+ (NSString *)localeLanguageCode
{
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
    MHLog(@"Current Locale language code is %@", languageCode);
    return languageCode;
}

+ (void)assignUserDefaults
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES], MHBundleEnabled,
                          [NSNumber numberWithBool:YES], MHForwardHeaderEnabled,
                          [NSNumber numberWithBool:YES], MHTypographyEnabled,
                          [NSNumber numberWithBool:YES], MHHeaderOptionEnabled,
                          [NSNumber numberWithBool:YES], MHPluginNotifyNewVersion,
                          MHDefaultHeaderFontName, MHHeaderFontName,
                          MHDefaultHeaderFontSize, MHHeaderFontSize,
                          [NSArchiver archivedDataWithRootObject:[NSColor blackColor]], MHHeaderColor,
                          [NSNumber numberWithBool:NO], MHEntourage2004SupportEnabled,
                          [NSNumber numberWithBool:YES], MHSubjectPrefixTextEnabled,
                          [NSNumber numberWithBool:NO], MHRemoveSignatureEnabled,
                          [NSNumber numberWithInt:2], MHHeaderLabelMode,
                          [NSNumber numberWithInt:2], MHHeaderOrderMode,
                          [NSNumber numberWithBool:NO], MHLogEnabled,
                          nil
                          ];
    
    // set defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

+ (void)smoothValueTransToNewMailPrefUI
{   
    if (GET_DEFAULT_BOOL(@"enableBundle"))
    {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"enableBundle"), MHBundleEnabled);
        
        REMOVE_DEFAULT(@"enableBundle");
    }
    
    if (GET_DEFAULT_BOOL(@"replaceForward"))
    {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"replaceForward"), MHForwardHeaderEnabled);
        
        REMOVE_DEFAULT(@"replaceForward");
    }
    
    if (GET_DEFAULT_BOOL(@"entourage2004Support"))
    {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"entourage2004Support"), MHEntourage2004SupportEnabled);
        
        REMOVE_DEFAULT(@"entourage2004Support");
    }
    
    if (GET_DEFAULT(@"headerText"))
    {
        REMOVE_DEFAULT(@"headerText");
    }
    
    if (GET_DEFAULT(@"forwardHeader"))
    {
        REMOVE_DEFAULT(@"forwardHeader");
    }
    
    // [start] for issue #17
    if (GET_DEFAULT(@"RwhForwardHeaderText"))
    {
        REMOVE_DEFAULT(@"RwhForwardHeaderText");
    }
    
    if (GET_DEFAULT(@"RwhReplyHeaderText"))
    {
        REMOVE_DEFAULT(@"RwhReplyHeaderText");
    }
    // [end]
}


#pragma mark MVMailBundle class methods

+ (BOOL)hasPreferencesPanel
{
    // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle.
    return YES;
}

+ (NSString*)preferencesOwnerClassName
{
    return NSStringFromClass([MHPreferences class]);
}

+ (NSString*)preferencesPanelName
{
    return MHLocalizedString(@"MAIL_HEADER_PREFERENCES");
}


#pragma mark MVMailBundle initialize

+ (void)initialize
{
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from MailHeader.
    if (self != [MailHeader class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow bundles anymore. Fingers crossed that this never happens!
    if (!mvMailBundleClass) {
        NSLog(@"Mail.app doesn't support bundles anymore, so have a beer and relax !");
        
        return;
    }
    
    // Registering plugin in Mail.app
    [mvMailBundleClass registerBundle];
    
    // Assigning default value if not present
    [self assignUserDefaults];
    
    // For smooth upgrade to new User Interface
    [self smoothValueTransToNewMailPrefUI];
    
    // Add hooks into Mail.app Classes
    [MHCodeInjector injectMailHeaderCode];
    
    // Bundle registered successfully
    NSLog(@"%@ plugin loaded", [self bundleNameAndVersion]);
    
    // Logger
    [MLog setLogOn:GET_DEFAULT_BOOL(MHLogEnabled)];
    
    if (![self isEnabled])
    {
        NSLog(@"%@ plugin is disabled in preferences", [self bundleName]);
    }
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( ![self isLocaleSupported] )
    {
        NSLog(@"%@ - Outlook order mode, currently supported in english locale only.",
              [self bundleName]);
        
        //SET_DEFAULT_INT(1, MHHeaderLabelMode);
        SET_DEFAULT_INT(1, MHHeaderOrderMode);
    }
    
    if (GET_DEFAULT_BOOL(MHPluginNotifyNewVersion))
    {
        double delayInSeconds = 30.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){            
            MHUpdater *updater = [[MHUpdater alloc] init];
            if ([updater isUpdateAvailable])
                [updater showUpdateAlert];
        });
    }
}

@end
