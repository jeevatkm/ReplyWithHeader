//
//  NSObject+RwhMailSwizzle.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/21/13.
//
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

@interface NSObject (RwhMailBundle)

+ (void)rwhAddMethodsToClass:(Class)cls;
+ (void)rwhAddMethods:(Method *)m numMethods:(unsigned int)cnt toClass:(Class *)c origClass:(Class *) cls;
+ (void)rwhSwizzle:(SEL)origSel meth:(SEL)newSel classMeth:(BOOL)cls;

@end
