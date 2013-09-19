/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
 *               2012, 2013 Jason Schroth
 *               2010, 2011 Saptarshi Guha
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

//
//  RwhMacros.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/18/13.
//
// Added for best practice #11 (https://github.com/jeevatkm/ReplyWithHeaders/issues/11)

#define GET_USER_DEFAULT(k) [[NSUserDefaults standardUserDefaults] objectForKey: k]
#define SET_USER_DEFAULT(o,k) [[NSUserDefaults standardUserDefaults] setObject: o forKey: k]
#define REMOVE_USER_DEFAULT(k) [[NSUserDefaults standardUserDefaults] removeObjectForKey: k]
#define GET_BOOL_USER_DEFAULT(k) [[NSUserDefaults standardUserDefaults] boolForKey: k]
#define SET_BOOL_USER_DEFAULT(b,k) SET_USER_DEFAULT( [NSNumber numberWithBool: b], k )

#define GET_BUNDLE_VALUE(k) [[[NSBundle bundleForClass:[ReplyWithHeader class]] infoDictionary] objectForKey: k]
