/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
 *               2012, 2013 Jason Schroth
 *               2010, 2013 Saptarshi Guha
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
