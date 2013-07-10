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
