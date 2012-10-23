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



#import "NSPreferencesModule.h"
#import "ReplyWithHeader.h"

/*!
 * @class
 * The <code>ReplyWithHeaderPreferencesModule</code> class is the subclass of
 * <code>NSPreferencesModule</code> that displays and manages preferences
 * specific to the ReplyWithHeader plugin.
 * @version \@(#) $Id$
 * @updated $Date$
 */
@interface ReplyWithHeaderPreferencesModule : NSPreferencesModule


#pragma mark NSPreferencesModule instance methods
/*! @group NSPreferencesModule instance methods */

/*!
 * Returns the name of the nib file containing the ReplyWithHeader preferences
 * panel.
 * @result
 *   <code>ReplyWithHeaderPanel</code>.
 */
- (NSString*)preferencesNibName;

#pragma mark Instance methods

- (NSString*)rwhVersion;

@end
