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

@implementation ReplyWithHeader


#pragma mark Class initialization

+ (void)initialize {
    RWH_LOG();
    
    //class_setSuperclass - Deprecated, but there does not appear to be a better way for this...
    if (self == [ReplyWithHeader class]) {
        class_setSuperclass(self, NSClassFromString(@"MVMailBundle"));
    }
    
    [super registerBundle];
    
    //add the ReplyWithHeaderMessage methods to the ComposeBackEnd class
    [ReplyWithHeaderMessage rwhAddMethodsToClass:NSClassFromString(@"ComposeBackEnd")];
    
    //now switch the _continueToSetupContentsForView method in the ComposeBackEnd implementation so that the
    // newly added rph_continueToSetupContentsForView method is called instead...
    [NSClassFromString(@"ComposeBackEnd")
        rwhSwizzle:@selector(_continueToSetupContentsForView:withParsedMessages:)
        meth:@selector(rph_continueToSetupContentsForView:withParsedMessages:)
        classMeth:NO // it is an implementation method
     ];
    
    
    [ReplyWithHeaderPreferences rwhAddMethodsToClass:NSClassFromString(@"NSPreferences")];
    
    [NSClassFromString(@"NSPreferences")
     rwhSwizzle:@selector(sharedPreferences)
     meth:@selector(rwhSharedPreferences)
     classMeth:YES
     ];
    
        
    
    //enableBundle
    //headerText
    //entourage2004Support
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] retain];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES], @"enableBundle",
                          @"-----Original Message-----", @"headerText",
                          [NSNumber numberWithBool:NO], @"entourage2004Support",
                          nil];
    
    [prefs registerDefaults:dict];
    
    //The modules have been loaded
	NSLog(@"Loaded ReplyWithHeader %@",[[NSBundle bundleForClass:[ReplyWithHeader class]] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]);
    NSLog(@"ReplyWithHeaders: Oh its a wonderful life");
    
}


#pragma mark MVMailBundle class methods

+ (BOOL)hasPreferencesPanel {
    RWH_LOG();
    
    return YES;
}

+ (NSString*)preferencesOwnerClassName {
    RWH_LOG();
    
    return @"ReplyWithHeaderPreferencesModule";
}

+ (NSString*)preferencesPanelName {
    RWH_LOG();
    
    return @"RWH";
}

@end

@implementation NSObject (ReplyWithHeaderObject)

#pragma mark Class methods

+ (void)rwhAddMethodsToClass:(Class)cls
{
    RWH_LOG(@"%@", cls);
    
    unsigned int numMeths = 0;
    Method* meths = class_copyMethodList(object_getClass([self class]), &numMeths);
    Class c = object_getClass(cls);
    
    //add the methods
    [self rwhAddMethods:meths numMethods:numMeths toClass:&c origClass:&cls];
    
    //clean up the memory
    if (meths != nil)
    { free(meths); }
    
    //keep doing it until they are the same class
    while(c != cls)
    {
        c = cls;
        meths = class_copyMethodList([self class], &numMeths);
        [self rwhAddMethods:meths numMethods:numMeths toClass:&c origClass:&cls];
    }
}

+ (void)rwhAddMethods:(Method *)m numMethods:(unsigned int)cnt toClass:(Class *)c origClass:(Class *) cls
{
    unsigned int i = 0;
    
    //add the method from the current class (self) to the class identified
    for (i = 0; i < cnt; i++)
    {
        //add the methods to Class c class
        if(!class_addMethod(*c,method_getName(m[i]),method_getImplementation(m[i]),method_getTypeEncoding(m[i]) ))
        { RWH_LOG(@"rwhAddMethods: could not add %s to %@",sel_getName(method_getName(m[i])),*cls); }
        else
        { RWH_LOG(@"rwhAddMethods: added %s to %@",sel_getName(method_getName(m[i])),*cls); }
    }

}


+ (void)rwhSwizzle:(SEL)origSel meth:(SEL)newSel classMeth:(BOOL)cls
{
    //get the original method and the new method... need to test if it is a class or instance method to determine
    // the function to call to get the method
    Method origMeth = (cls?class_getClassMethod([self class], origSel):class_getInstanceMethod([self class], origSel));
    Method newMeth = (cls?class_getClassMethod([self class], newSel):class_getInstanceMethod([self class], newSel));

    //log the swizzle for debugging...
    RWH_LOG(@"%s (%p), %s (%p), %s",sel_getName(origSel), method_getImplementation(origMeth),
                                    sel_getName(newSel), method_getImplementation(newMeth),(cls ? "YES" : "NO"));
    //this is how we swizzle
    method_exchangeImplementations(origMeth, newMeth);
}

@end
