// replyWitHeaders MailBundle - compose reply with message headers as in forwards
//    Copyright (c) 2013 Saptarshi Guha and Jason Schroth
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    MIT License for more details.
//
//    You should have received a copy of the MIT License along with this
//    program.  If not, see <http://opensource.org/licenses/MIT>.


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
