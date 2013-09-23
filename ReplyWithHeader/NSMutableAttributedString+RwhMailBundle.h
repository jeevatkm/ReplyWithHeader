//
//  NSMutableAttributedString+RwhMailBundle.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/23/13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (RwhMailBundle)

+ (void)trimLeadingWhitespaceAndNewLine:(NSMutableAttributedString *)attString;
+ (void)trimTrailingWhitespaceAndNewLine:(NSMutableAttributedString *)attString;

@end
