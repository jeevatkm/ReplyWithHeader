//
//  NSObject+RwhMailSwizzle.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/21/13.
//
//

#import "NSObject+RwhMailBundle.h"

@implementation NSObject (RwhMailBundle)

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
