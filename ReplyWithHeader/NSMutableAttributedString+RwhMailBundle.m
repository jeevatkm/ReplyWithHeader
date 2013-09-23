//
//  NSMutableAttributedString+RwhMailBundle.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/23/13.
//
//

#import "NSMutableAttributedString+RwhMailBundle.h"

@implementation NSMutableAttributedString (RwhMailBundle)

+ (void)trimLeadingWhitespaceAndNewLine:(NSMutableAttributedString *)attString {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [attString.string rangeOfCharacterFromSet:charSet];
    while (range.length != 0 && range.location == 0) {
        [attString replaceCharactersInRange:range withString:@""];
        range = [attString.string rangeOfCharacterFromSet:charSet];
    }
}

+ (void)trimTrailingWhitespaceAndNewLine:(NSMutableAttributedString *)attString {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [attString.string rangeOfCharacterFromSet:charSet
             options:NSBackwardsSearch];
    while (range.length != 0 && NSMaxRange(range) == attString.length) {
        [attString replaceCharactersInRange:range withString:@""];
        range = [attString.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
    }
}

@end
