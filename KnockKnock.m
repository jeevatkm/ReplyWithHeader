//
//  KnockKnock.m
//  ReplyWithHeader
//
//  Created by Saptarshi Guha on 10/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//Essentia: http://www.mronge.com/2009/09/10/nasty-hacking-with-64-bit-objective-c/

#import "KnockKnock.h"
#import <objc/runtime.h>

NSBundle *GetMePlease(void) {
	return [NSBundle bundleForClass:[KnockKnock class]];
}

@implementation KnockKnock

+ (void) initialize {
	[super initialize];
	
	//We attempt to get a reference to the MVMailBundle class so we can swap superclasses, failing that 
	//we disable ourselves and are done since this is an undefined state
	Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
	if(!mvMailBundleClass)
		NSLog(@"ReplyWithHeaders: Mail.app does not have a MVMailBundle class available");
	else
	{
		class_setSuperclass([self class], mvMailBundleClass);
		[KnockKnock registerBundle];
		NSLog(@"Loaded ReplyWithHeaders");
	}
}
- (id) init {
	if ((self = [super init])) {
		NSLog(@"ReplyWithHeaders: Oh its a wonderful life");
	}else NSLog(@"And maybe not so");
	return self;
}
@end
