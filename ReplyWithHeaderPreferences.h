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


/*!
 * @header
 * Defines the <code>ReplyWithHeaderPreferences</code> category for
 * <code>NSPreferences</code>.
 * @version \@(#) $Id$
 * @updated $Date$
 */
#import "ReplyWithHeader.h"

/*!
 * @class
 * Adds a method for overriding the preference-loading behavior of
 * <code>NSPreferences</code>.
 * @version \@(#) $Id$
 * @updated $Date$
 */
@interface ReplyWithHeaderPreferences : NSObject


#pragma mark Swizzled class methods
/*! @group Swizzled class methods */

/*!
 * Adds the RWH preferences.
 * @result
 *   The shared <code>NSPreferences</code> for this application.
 */
+ (id)rwhSharedPreferences;


@end
