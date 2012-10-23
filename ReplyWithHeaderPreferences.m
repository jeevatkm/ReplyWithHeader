// replyWitHeaders MailBundle - compose reply with message headers as in forwards
//    Copyright (C) 2012 Jason Schroth
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "ReplyWithHeaderPreferences.h"

@implementation ReplyWithHeaderPreferences


#pragma mark Swizzled class methods

//see http://nohejl.name/2011/07/21/mail-preferences-modules-in-mac-os-x-10-7/
// for more info about why this is needed
+ (id)rwhSharedPreferences
{
    RWH_LOG();
    
    static BOOL added = NO;
    //we don't have the NSPreferences class, so get it by name during runtime
    id prefs = [NSClassFromString(@"NSPreferences") rwhSharedPreferences];
    
    if ((prefs != nil) && !added)
    {
        added = YES;
        
        [[NSClassFromString(@"NSPreferences") rwhSharedPreferences]
         addPreferenceNamed:[ReplyWithHeader preferencesPanelName]
         owner:[ReplyWithHeaderPreferencesModule sharedInstance]
         ];
    }
    
    return [NSClassFromString(@"NSPreferences") rwhSharedPreferences];
}

@end
