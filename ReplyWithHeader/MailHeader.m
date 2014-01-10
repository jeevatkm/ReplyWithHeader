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

// This method differ from [NSLocale currentLocale], plugin depends on Mail.app preferred lanaguge mode.
+ (NSLocale *)currentLocale
{
    static NSLocale *locale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = [self localeIdentifier];
        locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
        MHLog(@"Current Locale Identifier: %@", identifier);
    });
    return [NSLocale currentLocale];
}

+ (NSString *)localeIdentifier
{
    NSString *identifier = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    
    if ([identifier isEqualToString:@"zh_CN"])
        identifier = @"zh-Hans";
    else if ([identifier isEqualToString:@"zh_TW"])
        identifier = @"zh-Hant";
    else if ([identifier hasPrefix:@"en"]) // for issue #39 - considering all en-* into one umberlla
        identifier = @"en";
    
    return identifier;
}

// for issue #21 - https://github.com/jeevatkm/ReplyWithHeader/issues/21
+ (BOOL)isLocaleSupported
{
    BOOL supported = [[[self bundle] localizations] containsObject:[self localeIdentifier]];
        
    MHLog(@"%@ - Is locale supported: %@",[self bundleNameAndVersion], supported ? @"YES" : @"NO");
    
    return supported;
}

+ (BOOL)isSpecificLocale
{
    NSString *currentLocaleIdentifier = [self localeIdentifier];
    return ([currentLocaleIdentifier isEqualToString:@"ja"]
            || [currentLocaleIdentifier isEqualToString:@"zh-Hans"]
            || [currentLocaleIdentifier isEqualToString:@"zh-Hant"]);
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
    return MHLocalizedStringByLocale(@"PLUGIN_NAME", MHLocaleIdentifier);
}

+ (NSString *)bundleVersionString
{
    return [[[self bundle] infoDictionary] objectForKey:MHBundleShortVersionKey];
}

+ (NSString *)bundleCopyright
{
    return MHLocalizedStringByLocale(@"COPYRIGHT", MHLocaleIdentifier);
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
    NSBundle *mhBundle = [self bundle];
    NSString *localString = NSLocalizedStringFromTableInBundle(key, @"MailHeader", mhBundle, nil);
    
    if(![localString isEqualToString:key])
        return localString;
    
    return [self localizedString:key localeIdentifier:@"en"];
}

+ (NSString *)localizedString:(NSString *)key localeIdentifier:(NSString *)identifier
{
    NSString *filePath = [[self bundle] pathForResource:@"MailHeader"
                                                       ofType:@"strings"
                                                  inDirectory:@""
                                              forLocalization:identifier];
    
    NSDictionary *stringDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *string = [stringDict objectForKey:key];
    
    if ( string == nil )
    {
        MHLog(@"Localized String locale: %@ key: %@ value: %@", identifier, key, string);
        return [self localizedString:key localeIdentifier:@"en"];
    }
    
    MHLog(@"Localized String locale: %@ key: %@ value: %@", identifier, key, string);
    
    return [stringDict objectForKey:key];
}

+ (id)getConfigValue:(NSString *)key
{
    static NSDictionary *configDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [[self bundle] pathForResource:@"Config" ofType:@"plist"];
        configDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    });
    
    return [configDictionary objectForKey:key];    
}

+ (id)getConfigValue:(NSString *)key languageCode:(NSString *)identifier
{
    NSString *filePath = [[self bundle] pathForResource:@"Config"
                                                 ofType:@"plist"
                                            inDirectory:@""
                                        forLocalization:identifier];
    
    NSDictionary *configDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [configDictionary objectForKey:key];
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
                          [NSNumber numberWithBool:YES], MHSubjectPrefixTextEnabled,
                          [NSNumber numberWithBool:NO], MHRemoveSignatureEnabled,
                          [NSNumber numberWithInt:2], MHHeaderLabelMode,
                          [NSNumber numberWithInt:2], MHHeaderOrderMode,
                          [NSNumber numberWithInt:0], MHHeaderAttributionFromTagStyle,
                          [NSNumber numberWithBool:NO], MHLogEnabled,
                          nil
                          ];
    
    if ( !GET_DEFAULT(MHBundleHeaderLanguageCode) )
    {
        SET_USER_DEFAULT(MHLocaleIdentifier, MHBundleHeaderLanguageCode);
    }
    
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
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"entourage2004Support"), @"MHEntourage2004SupportEnabled");
        
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
    
    // issue #42
    if (GET_DEFAULT(@"MHEntourage2004SupportEnabled"))
    {
        REMOVE_DEFAULT(@"MHEntourage2004SupportEnabled");
    }
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
    return MHLocalizedStringByLocale(@"MAIL_HEADER_PREFERENCES", MHLocaleIdentifier);
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
    
    // For smooth upgrade to new User Interface
    [self smoothValueTransToNewMailPrefUI];
    
    // Assigning default value if not present
    [self assignUserDefaults];
    
    // Add hooks into Mail.app Classes
    [MHCodeInjector injectMailHeaderCode];
    
    // Bundle registered successfully
    NSLog(@"%@ plugin loaded", [self bundleNameAndVersion]);
    
    // Logger
    [MLog setLogOn:GET_DEFAULT_BOOL(MHLogEnabled)];
    
    // fix for #26 https://github.com/jeevatkm/ReplyWithHeader/issues/26
    if ( ![self isLocaleSupported] )
    {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[self localeIdentifier]];
        NSString *name = [locale displayNameForKey:NSLocaleIdentifier value:[self localeIdentifier]];
        
        NSLog(@"WARNING :: %@ is currently not supported in your Locale[ %@(%@) ] it may not work as expected, so disabling it.\nPlease contact plugin author for support (http://myjeeva.com/replywithheader).",
              [self bundleNameAndVersion], name, [self localeIdentifier]);
        
        SET_DEFAULT_BOOL(FALSE, MHBundleEnabled);
    }

    if (![self isEnabled])
    {
        NSLog(@"%@ plugin is disabled in mail preferences", [self bundleName]);
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
