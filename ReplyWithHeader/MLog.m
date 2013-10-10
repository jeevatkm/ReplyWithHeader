//
//  MLog.m
//  Originally by AgentM.  This code is in the public domain.
//  http://borkware.com/rants/agentm/mlog/


#import "MLog.h"

static BOOL __MLogOn = NO;

@implementation MLog

+ (void) initialize {
	//char * env = getenv("MLogOn");
    char * env = getenv("MHLog_ON"); // correction for env variable for plugin
	
	if (strcmp(env == NULL ? "" : env, "NO") != 0)
		__MLogOn = YES;
}


+ (void) logFile: (char *) sourceFile lineNumber: (int) lineNumber format: (NSString *) format, ...; {
	
    if (__MLogOn == NO)
		return;
    
	va_list ap;
	
	NSString *print, *file;	
		
	va_start(ap, format);
	
	file  = [[NSString alloc] initWithBytes: sourceFile 
									 length: strlen(sourceFile) 
								   encoding: NSUTF8StringEncoding];
	
	print = [[NSString alloc] initWithFormat:format arguments: ap];
	
	va_end(ap);
	
	// NSLog handles synchronization issues
	NSLog(@"%s: %d %@", [[file lastPathComponent] UTF8String], lineNumber, print);
	
	[print release];
	[file  release];
	
	return;
}


+ (void) setLogOn: (BOOL) logOn {
	
	__MLogOn = logOn;
}

@end
