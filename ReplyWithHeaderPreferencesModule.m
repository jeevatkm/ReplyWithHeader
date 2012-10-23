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



#import "ReplyWithHeaderPreferencesModule.h"

@implementation ReplyWithHeaderPreferencesModule

#pragma mark NSPreferencesModule instance methods

- (NSString*)preferencesNibName
{
    RWH_LOG();
    return @"ReplyWithHeaderPanel";
}

#pragma mark Instance methods

- (NSString*)rwhVersion
{
    return [[[NSBundle bundleForClass:[ReplyWithHeader class]] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end
