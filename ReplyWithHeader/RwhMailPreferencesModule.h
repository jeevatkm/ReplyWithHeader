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
@interface RwhMailPreferencesModule : NSPreferencesModule


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
