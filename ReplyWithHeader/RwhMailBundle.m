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

#import <objc/objc-runtime.h>

#import "RwhMailBundle.h"
#import "MailHeaderPreferences.h"
#import "RwhMailMessage.h"
#import "NSObject+RwhMailBundle.h"
#import "RwhNotify.h"
#import "RwhMailHeadersEditor.h"
#import "NSPreferences+MailHeader.h"

@interface RwhMailBundle (RwhNoImplementation)
+ (void)registerBundle;
@end

@implementation RwhMailBundle

#pragma mark Class public methods

+ (void)initialize {
    [super initialize];
    
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from RwhMailBundle.
    if (self != [RwhMailBundle class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow bundles anymore. Fingers crossed that this never happens!
    if (!mvMailBundleClass) {
        NSLog(@"Mail.app doesn't support bundles anymore, So have a Beer and relax !");
        
        return;
    }
    
    // Registering RWH mail bundle
    [mvMailBundleClass registerBundle];
    
    // assigning default value if not present
    [self assignRwhMailDefaultValues];
    
    // for smooth upgrade to new UI
    [self smoothValueTransToNewRwhMailPrefUI];
    
    // Swizzling of Mail.app Classes
    [self addRwhMailMessageMethodsToComposeBackEnd];
    [self addRwhMailPreferencesMethodsToNSPreferences];    
    [self addRwhMailHeaderEditorMethodsToHeadersEditor];
    
    // RWH Bundle registered successfully
    NSLog(@"RWH %@ mail bundle registered", [self bundleVersionString]);
    NSLog(@"RWH %@ Oh it's a wonderful life", [self bundleVersionString]);
    
    if (![self isEnabled]) {
        NSLog(@"RWH mail bundle is disabled in mail preferences");
    }
    
    if (GET_DEFAULT_BOOL(RwhMailNotifyPluginNewVersion)) {        
        double delayInSeconds = 30.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            RwhNotify *notifier = [[RwhNotify alloc] init];
            [notifier checkNewVersion];            
            [notifier release];
        });
    }
}

+ (BOOL)isEnabled {
    return GET_DEFAULT_BOOL(RwhMailBundleEnabled);
}

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[RwhMailBundle class]];
    });
    return bundle;
}

+ (NSString *)bundleNameAndVersion {
    return [NSMutableString stringWithFormat:@"%@ %@", [self bundleName], [self bundleVersionString]];
}

+ (NSString *)bundleName {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailBundleNameKey];
}

+ (NSString *)bundleVersionString {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailBundleShortVersionKey];
}

+ (NSString *)bundleShortName {
    return RwhMailBundleShortName;
}

+ (NSString *)bundleCopyright {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailCopyRightKey];
}

+ (NSImage *)bundleLogo {
    static NSImage *logo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logo = [[NSImage alloc]
                initByReferencingFile:[[self bundle] pathForImageResource:@"ReplyWithHeader"]];
        [logo setSize:NSMakeSize(128, 128)];
    });
    return logo;
}


#pragma mark MVMailBundle class methods

+ (BOOL)hasPreferencesPanel {
    // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle.
    return YES;
}

+ (NSString*)preferencesOwnerClassName {
    return NSStringFromClass([MailHeaderPreferences class]);
}

+ (NSString*)preferencesPanelName {
    return [self bundleShortName];
}


#pragma mark Class private methods

+ (void)assignRwhMailDefaultValues {
    RWH_LOG();
    
    if (!GET_DEFAULT(RwhMailBundleEnabled)) {
        SET_DEFAULT_BOOL(YES, RwhMailBundleEnabled);
    }
    
    if (!GET_DEFAULT(RwhMailForwardHeaderEnabled)) {
        SET_DEFAULT_BOOL(YES, RwhMailForwardHeaderEnabled);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderTypographyEnabled)) {
        SET_DEFAULT_BOOL(YES, RwhMailHeaderTypographyEnabled);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderOptionModeEnabled)) {
        SET_DEFAULT_BOOL(YES, RwhMailHeaderOptionModeEnabled);
    }
    
    if (!GET_DEFAULT(RwhMailNotifyPluginNewVersion)) {
        SET_DEFAULT_BOOL(YES, RwhMailNotifyPluginNewVersion);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderFontName)) {
        SET_USER_DEFAULT(RwhMailDefaultHeaderFontName , RwhMailHeaderFontName);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderFontSize)) {
        SET_USER_DEFAULT(RwhMailDefaultHeaderFontSize , RwhMailHeaderFontSize);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderColor)) {
        SET_USER_DEFAULT([NSArchiver archivedDataWithRootObject:[NSColor blackColor]], RwhMailHeaderColor);
    }
    
    if (!GET_DEFAULT(RwhMailEntourage2004SupportEnabled)) {
        SET_DEFAULT_BOOL(NO, RwhMailEntourage2004SupportEnabled);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderLabelMode)) {
        SET_DEFAULT_INT(1, RwhMailHeaderLabelMode);
    }
    
    if (!GET_DEFAULT(RwhMailHeaderOrderMode)) {
        SET_DEFAULT_INT(1, RwhMailHeaderOrderMode);
    }
    
    if (!GET_DEFAULT(RwhMailSubjectPrefixTextEnabled)) {
        SET_DEFAULT_BOOL(YES, RwhMailSubjectPrefixTextEnabled);
    }
}

+ (void)smoothValueTransToNewRwhMailPrefUI {
    RWH_LOG();
    
    if (GET_DEFAULT_BOOL(@"enableBundle")) {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"enableBundle"), RwhMailBundleEnabled);
        
        REMOVE_DEFAULT(@"enableBundle");
    }
    
    if (GET_DEFAULT_BOOL(@"replaceForward")) {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"replaceForward"), RwhMailForwardHeaderEnabled);
        
        REMOVE_DEFAULT(@"replaceForward");
    }
    
    if (GET_DEFAULT_BOOL(@"entourage2004Support")) {
        SET_DEFAULT_BOOL(GET_DEFAULT_BOOL(@"entourage2004Support"), RwhMailEntourage2004SupportEnabled);
        
        REMOVE_DEFAULT(@"entourage2004Support");
    }
    
    if (GET_DEFAULT(@"headerText")) {
        REMOVE_DEFAULT(@"headerText");
    }
    
    if (GET_DEFAULT(@"forwardHeader")) {
        REMOVE_DEFAULT(@"forwardHeader");
    }
    
    // [start] for issue #17
    if (GET_DEFAULT(@"RwhForwardHeaderText")) {
        REMOVE_DEFAULT(@"RwhForwardHeaderText");
    }
    
    if (GET_DEFAULT(@"RwhReplyHeaderText")) {        
        REMOVE_DEFAULT(@"RwhReplyHeaderText");
    }    
    // [end]
}

+ (void)addRwhMailMessageMethodsToComposeBackEnd {
    [RwhMailMessage rwhAddMethodsToClass:NSClassFromString(@"ComposeBackEnd")];
    
    [NSClassFromString(@"ComposeBackEnd")
     rwhSwizzle:@selector(_continueToSetupContentsForView:withParsedMessages:)
     meth:@selector(rwhContinueToSetupContentsForView:withParsedMessages:)
     classMeth:NO
     ];
}

+ (void)addRwhMailHeaderEditorMethodsToHeadersEditor {
    [RwhMailHeadersEditor rwhAddMethodsToClass:NSClassFromString(@"HeadersEditor")];
    
    [NSClassFromString(@"HeadersEditor")
     rwhSwizzle:@selector(loadHeadersFromBackEnd:)
     meth:@selector(rwhLoadHeadersFromBackEnd:)
     classMeth:NO
     ];
}

+ (void)addRwhMailPreferencesMethodsToNSPreferences {
    
    Class nsPref = NSClassFromString(@"NSPreferences");    
    if (nsPref) {
        [nsPref
         rwhSwizzle:@selector(sharedPreferences)
         meth:@selector(MHSharedPreferences)
         classMeth:YES
         ];
        
        [nsPref
         rwhSwizzle:@selector(windowWillResize:toSize:)
         meth:@selector(MHWindowWillResize:toSize:)
         classMeth:NO
         ];
        
        [nsPref
         rwhSwizzle:@selector(toolbarItemClicked:)
         meth:@selector(MHToolbarItemClicked:)
         classMeth:NO
         ];
        
        [nsPref
         rwhSwizzle:@selector(showPreferencesPanelForOwner:)
         meth:@selector(MHShowPreferencesPanelForOwner:)
         classMeth:NO
         ];
    }
}

@end
