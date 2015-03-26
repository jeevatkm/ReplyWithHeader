/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Jeevanandam M.
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
//  NSString+MailHeader.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 07/03/15.
//
//

#import "NSString+MailHeader.h"
#import "MailHeader.h"

@implementation NSString (MailHeader)

- (BOOL)isBlank
{
    if([[self trim] isEqualToString:@""])
        return YES;
    return NO;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)contains:(NSString *)string
{
    if (string)
    {
        NSRange range = [self rangeOf:string];
        return (range.location != NSNotFound);
    }
    else
    {
        return NO;
    }
    
}

- (NSRange)rangeOf:(NSString *)str
{
    return [self rangeOf:str byLocale:[MailHeader currentLocale]];
}

- (NSRange)rangeOf:(NSString *)str byLocale:(NSLocale *)locale
{
    return [self rangeOfString:str
                       options:NSCaseInsensitiveSearch
                         range:NSMakeRange(0, self.length)
                        locale:locale];
}

- (NSMutableAttributedString *)mutableAttributedString
{
    return [[NSMutableAttributedString alloc] initWithString:[[self trim] copy]];
}

- (NSAttributedString *)attributedString
{
    return [[NSAttributedString alloc] initWithString:[[self trim] copy]];
}

@end
