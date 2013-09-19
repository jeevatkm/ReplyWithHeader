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


/*!
 * @header
 * Defines the <code>RwhMailBundle</code> Mail bundle (the entrypoint for the
 * plugin) and the <code>RwhMailBundleObject</code> category for
 * <code>NSObject</code>.
 * @copyright Copyright (c) 2013 Saptarshi Guha and Jason Schroth
 * @version \@(#) $Id$
 * @updated $Date$
 */

#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>

#import "RwhMailHeaderString.h"
#import "RwhMailQuotedOriginal.h"
#import "RwhMailMessage.h"
#import "RwhMailPreferences.h"
#import "RwhMailPreferencesModule.h"
#import "RwhMailMacros.h"
#import "RwhMailConstants.h"

/*!
 * @class
 * The <code>RwhMailBundle</code> class is the subclass of
 * <code>MVMailBundle</code> that provides the plugin entrypoint for the
 * RwhMailBundle plugin.
 * @version \@(#) $Id$
 * @updated $Date$
 */
@interface RwhMailBundle : NSObject {
    
}

#pragma mark Class initialization
/*! @group Class initialization */

/*!
 * Registers this plugin and swizzles the methods necessary for RwhMailBundle's
 * functionality.
 */
//+ (void)initialize;

@end

/*!
 * @category
 * Adds a method for method swizzling to <code>NSObject</code> instances.
 * @version \@(#) $Id$
 * @updated $Date$
 */
@interface NSObject (RwhMailBundleObject)

#pragma mark Class methods
/*! @group Class methods */

/*!
 * Adds the methods from this class to the specified class.
 * @param inClass
 *   The <code>Class</code> to which this class's methods should be added.
 */
+ (void)rwhAddMethodsToClass:(Class)cls;

/*!
 * Actually m the specified methods specified to the specified class.  
 * @param m
 *   The list of methods from the cls <code>Class</code>.
 * @param cnt
 *   The number of methods in the list of methods.
 * @param c
 *   The reference to the Class to which the methods will be added.
 * @param cls
 *   The reference to the Class from which the methods were taken.
 */
+ (void)rwhAddMethods:(Method *)m numMethods:(unsigned int)cnt toClass:(Class *)c origClass:(Class *) cls;

/*!
 * Swizzles two methods.  See http://www.cocoadev.com/index.pl?MethodSwizzling
 * @param origSel
 *   The selector specifying the method being replaced.
 * @param newSel
 *   The selector specifying the replacement method.
 * @param cls
 *   The <code>BOOL</code> indicating whether or not the methods being swizzled
 *   are class methods.
 */
+ (void)rwhSwizzle:(SEL)origSel meth:(SEL)newSel classMeth:(BOOL)cls;

@end
