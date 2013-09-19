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

#import "RwhMailBundle.h"
#import "RwhMailMacros.h"

@implementation RwhMailBundle


#pragma mark Class initialization

+ (void)initialize {
    
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from RwhMailBundle.
    if(self != [RwhMailBundle class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow plugins anymore. Fingers crossed that this never happens!
    if(!mvMailBundleClass)
        return;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop
    
    // Registering RWH mail bundle
    [super registerBundle];
    
    if (!GET_USER_DEFAULT(RwhMailBundleEnabled)) {
        SET_BOOL_USER_DEFAULT(YES, RwhMailBundleEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailForwardHeaderEnabled)) {
        SET_BOOL_USER_DEFAULT(YES, RwhMailForwardHeaderEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailEntourage2004SupportEnabled)) {
        SET_BOOL_USER_DEFAULT(NO, RwhMailEntourage2004SupportEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailReplyHeaderText)) {
        SET_BOOL_USER_DEFAULT(RwhMailDefaultReplyHeaderText, RwhMailReplyHeaderText);
    }
    
    if (!GET_USER_DEFAULT(RwhMailForwardHeaderText)) {
        SET_BOOL_USER_DEFAULT(RwhMailDefaultForwardHeaderText, RwhMailForwardHeaderText);
    }
    
    // add the RwhMailMessage methods to the ComposeBackEnd class
    [RwhMailMessage rwhAddMethodsToClass:NSClassFromString(@"ComposeBackEnd")];
    
    // now switch the _continueToSetupContentsForView method in the ComposeBackEnd implementation
    // so that the newly added rwhContinueToSetupContentsForView method is called instead...
    [NSClassFromString(@"ComposeBackEnd")
     rwhSwizzle:@selector(_continueToSetupContentsForView:withParsedMessages:)
     meth:@selector(rwhContinueToSetupContentsForView:withParsedMessages:)
     classMeth:NO // it is an implementation method
     ];
    
    
    [RwhMailPreferences rwhAddMethodsToClass:NSClassFromString(@"NSPreferences")];
    
    [NSClassFromString(@"NSPreferences")
     rwhSwizzle:@selector(sharedPreferences)
     meth:@selector(rwhSharedPreferences)
     classMeth:YES
     ];
    
    // RWH Bundle registered successfully
    NSLog(@"RWH %@ mail bundle registered", GET_BUNDLE_VALUE(RwhMailBundleVersionKey));
    NSLog(@"RWH %@ Oh it's a wonderful life", GET_BUNDLE_VALUE(RwhMailBundleVersionKey));
}


#pragma mark MVMailBundle class methods

+ (BOOL)hasPreferencesPanel {
    // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle.
    return YES;
}

+ (NSString*)preferencesOwnerClassName {
    return NSStringFromClass([RwhMailPreferencesModule class]);
}

+ (NSString*)preferencesPanelName {
    return RwhMailBundleShortName;
}

@end

@implementation NSObject (RwhMailBundleObject)

#pragma mark Class methods

+ (void)rwhAddMethodsToClass:(Class)cls {
    
    RWH_LOG(@"%@", cls);
    
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
            RWH_LOG(@"rwhAddMethods: could not add %s to %@",sel_getName(method_getName(m[i])),*cls);
        }
        else {
            RWH_LOG(@"rwhAddMethods: added %s to %@",sel_getName(method_getName(m[i])),*cls);
        }
    }
    
}

+ (void)rwhSwizzle:(SEL)origSel meth:(SEL)newSel classMeth:(BOOL)cls {
    // get the original method and the new method... need to test if it is a class or instance 
    // method to determine the function to call to get the method
    Method origMeth = (cls?class_getClassMethod([self class], origSel):class_getInstanceMethod([self class], origSel));
    Method newMeth = (cls?class_getClassMethod([self class], newSel):class_getInstanceMethod([self class], newSel));
    
    //log the swizzle for debugging...
    RWH_LOG(@"%s (%p), %s (%p), %s",sel_getName(origSel), method_getImplementation(origMeth),
            sel_getName(newSel), method_getImplementation(newMeth),(cls ? "YES" : "NO"));
    
    //this is how we swizzle
    method_exchangeImplementations(origMeth, newMeth);
}

@end