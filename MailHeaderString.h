//
//  MailHeaderString.h
//  ReplyWithHeader
//
//  Created by Jason Schroth on 8/15/12.
//
//

#import <Foundation/Foundation.h>
#import "WebKit/WebResource.h"
#import "WebKit/WebArchive.h"
#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>

@interface MailHeaderString : NSObject {
    @private
    NSMutableAttributedString *headstr;
}

-(id)init;
-(id)initWithStr: (NSAttributedString *)str;
-(id)initWithBackEnd: (id)backend;

-(void)boldHeaderLabels;
-(WebArchive *)getWebArch;
-(NSMutableAttributedString *)string;

@end
