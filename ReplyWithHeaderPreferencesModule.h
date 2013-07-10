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
- (NSString*)rwhCopyright;

@end
