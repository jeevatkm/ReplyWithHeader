/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
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
//  NSObject+MailHeader.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/21/13.
//
//

#import "NSObject+MailHeader.h"

@implementation NSObject (MailHeader)

#pragma mark Class methods

+ (void)rwhAddMethodsToClass:(Class)cls {
    
    MH_LOG(@"%@", cls);
    
    unsigned int numMeths = 0;
    Method* meths = class_copyMethodList(object_getClass([self class]), &numMeths);
    Class c = object_getClass(cls);
    
    //add the methods
    [self rwhAddMethods:meths numMethods:numMeths toClass:&c origClass:&cls];
    
    //clean up the memory
    if (meths != nil) {
        free(meths);
    }
    
    //keep doing it until they are the same class
    while(c != cls) {
        c = cls;
        meths = class_copyMethodList([self class], &numMeths);
        [self rwhAddMethods:meths numMethods:numMeths toClass:&c origClass:&cls];
    }
}

+ (void)rwhAddMethods:(Method *)m numMethods:(unsigned int)cnt toClass:(Class *)c origClass:(Class *) cls {
    unsigned int i = 0;
    
    //add the method from the current class (self) to the class identified
    for (i = 0; i < cnt; i++) {
        //add the methods to Class c class
        BOOL result = class_addMethod(*c, method_getName(m[i]), method_getImplementation(m[i]),method_getTypeEncoding(m[i]));
        
        if( !result )  {
            MH_LOG(@"rwhAddMethods: could not add %s to %@",sel_getName(method_getName(m[i])),*cls);
        }
        else {
            MH_LOG(@"rwhAddMethods: added %s to %@",sel_getName(method_getName(m[i])),*cls);
        }
    }
    
}

+ (void)rwhSwizzle:(SEL)origSel meth:(SEL)newSel classMeth:(BOOL)cls {
    // get the original method and the new method... need to test if it is a class or instance
    // method to determine the function to call to get the method
    Method origMeth = (cls?class_getClassMethod([self class], origSel):class_getInstanceMethod([self class], origSel));
    Method newMeth = (cls?class_getClassMethod([self class], newSel):class_getInstanceMethod([self class], newSel));
    
    //log the swizzle for debugging...
    MH_LOG(@"%s (%p), %s (%p), %s",sel_getName(origSel), method_getImplementation(origMeth),
            sel_getName(newSel), method_getImplementation(newMeth),(cls ? "YES" : "NO"));
    
    //this is how we swizzle
    method_exchangeImplementations(origMeth, newMeth);
}

@end
