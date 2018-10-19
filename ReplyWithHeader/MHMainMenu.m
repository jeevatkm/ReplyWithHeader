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
//  MHMainMenu.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/5/18.
//

#import "MHMainMenu.h"
#import "MHPreferences.h"

@interface MHMainMenu (MHNoImplementation)

+ (id)sharedApplication;

@end

@implementation MHMainMenu

@synthesize preferences;
@synthesize rwhMenu;
@synthesize rwhEnable;
@synthesize rwhAllHeaders;

+ (instancetype)sharedInstance
{
    static MHMainMenu *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MHMainMenu alloc] init];
        
        NSMenuItem *rwhPrefMenu = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(showPreferencesAction:) keyEquivalent:@""];
        [rwhPrefMenu setTarget:self];
        [rwhPrefMenu setEnabled:TRUE];
        
        sharedInstance.rwhEnable = [[NSMenuItem alloc] initWithTitle:@"Enable" action:@selector(rwhEnableAction:) keyEquivalent:@""];
        [sharedInstance.rwhEnable setTarget:self];
        [sharedInstance.rwhEnable setEnabled:TRUE];
        if (GET_DEFAULT_BOOL(MHBundleEnabled))
        {
            [sharedInstance.rwhEnable setState:NSControlStateValueOn];
        }
        
        sharedInstance.rwhAllHeaders = [[NSMenuItem alloc] initWithTitle:@"Include All Headers" action:@selector(includeAllHeadersAction:) keyEquivalent:@""];
        [sharedInstance.rwhAllHeaders setTarget:self];
        [sharedInstance.rwhAllHeaders setEnabled:TRUE];
        if (GET_DEFAULT_BOOL(MHRawHeadersEnabled))
        {
            [sharedInstance.rwhAllHeaders setState:NSControlStateValueOn];
        }
        
        sharedInstance.rwhMenu = [[NSMenu alloc] initWithTitle:@"RWH"];
        [sharedInstance.rwhMenu addItem:sharedInstance.rwhEnable];
        [sharedInstance.rwhMenu addItem:[NSMenuItem separatorItem]];
        [sharedInstance.rwhMenu addItem:sharedInstance.rwhAllHeaders];
        [sharedInstance.rwhMenu addItem:[NSMenuItem separatorItem]];
        [sharedInstance.rwhMenu addItem:rwhPrefMenu];
        
        sharedInstance.preferences = [[MHPreferences alloc] init];
    });
    return sharedInstance;
}

+(void)addMainMenu
{
    MHLog(@"Adding RWH main menu");
    Class mailApp = NSClassFromString(@"MailApp");
    NSMenu *mainMenu = [[mailApp sharedApplication] mainMenu];
    
    NSMenuItem *rwhMainMenu = [[NSMenuItem alloc] init];
    [rwhMainMenu setTitle:@"RWH"];
    [rwhMainMenu setSubmenu:[[self sharedInstance] rwhMenu]];
    [rwhMainMenu setTarget:self];

    [mainMenu insertItem:rwhMainMenu atIndex:[mainMenu numberOfItems] - 1];
    [[mailApp sharedApplication] setMainMenu:mainMenu];
    
    MHLog(@"RWH: %@", [[mailApp sharedApplication] mainMenu]);
    MHLog(@"RWH main menu added successfully");
}

+ (void)rwhEnableAction:(id)sender
{
    MHLog(@"RWH: rwhEnableAction called");
    if ([MailHeader isEnabled])
    {
        SET_DEFAULT_BOOL(FALSE, MHBundleEnabled);
        [[[self sharedInstance] rwhEnable] setState:NSControlStateValueOff];
    }
    else
    {
        SET_DEFAULT_BOOL(TRUE, MHBundleEnabled);
        [[[self sharedInstance] rwhEnable] setState:NSControlStateValueOn];
    }
}

+ (void)includeAllHeadersAction:(id)sender
{
    MHLog(@"RWH: includeAllHeadersAction called");
    if (GET_DEFAULT_BOOL(MHRawHeadersEnabled))
    {
        SET_DEFAULT_BOOL(FALSE, MHRawHeadersEnabled);
        [[[self sharedInstance] rwhAllHeaders] setState:NSControlStateValueOff];
    }
    else
    {
        SET_DEFAULT_BOOL(TRUE, MHRawHeadersEnabled);
        [[[self sharedInstance] rwhAllHeaders] setState:NSControlStateValueOn];
    }
}

+ (void)showPreferencesAction:(id)sender
{
    MHLog(@"showPreferencesAction called");
    [[[self sharedInstance] preferences] toggleMailPreferencesOptions:[MailHeader isEnabled]];
    [[[self sharedInstance] preferences] showWindow:self];
}

@end
