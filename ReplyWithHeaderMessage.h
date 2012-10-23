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


#import "ReplyWithHeader.h"

@interface ReplyWithHeaderMessage : NSObject


#pragma mark Implementation methods
/*! @group implementation methods */
/*!
 * Changes the Contents for view, adding the message headers to Reply and Reply All messages
 * the format of this function is taken from ComposeBackEnd _continueToSetupContentsForView method
 * @param arg1
 *   I am not sure what this arg is but it is required by ComposeBackEnd _continueToSetupContentsForView method
 * @param arg2
 *   I am not sure what this arg is but it is required by ComposeBackEnd _continueToSetupContentsForView method
 */
- (void)rph_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2;


@end
