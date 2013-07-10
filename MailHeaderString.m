// replyWitHeaders MailBundle - compose reply with message headers as in forwards
//    Copyright (c) 2013 Saptarshi Guha and Jason Schroth
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    MIT License for more details.
//
//    You should have received a copy of the MIT License along with this
//    program.  If not, see <http://opensource.org/licenses/MIT>.

//
//  MailHeaderString.m
//  ReplyWithHeader
//
//  Created by Jason Schroth on 8/15/12.
//
//

#import "MailHeaderString.h"

@implementation MailHeaderString

-(id)init
{
    if (self = [super init]) {
        //good stuff...
    }
    else {
        RWH_LOG(@"MailHeaderString: Init failed");
    }
    return self;
}

-(id)initWithStr: (NSAttributedString *)str
{
    //initialze the value with a mutable copy of the attributed string
    if( self = [super init] )
    {
        //   NSAttributedString *headerString =[[self originalMessageHeaders] attributedStringShowingHeaderDetailLevel:1];
        //	useHeadIndents:NO
        //	useBold:boldhead
        //	includeBCC:YES];
        
        headstr = [str mutableCopy];
        
        //remove the color attribute so that the text is black instead of gray
        //also remove paragraph style included in the header to avoid spacing issues when received by some mail clients
        [headstr removeAttribute:@"NSColor" range:NSMakeRange(0,[headstr length])];
        [headstr removeAttribute:@"NSParagraphStyle" range:NSMakeRange(0,[headstr length])];
        
    }
    else {
        RWH_LOG(@"MailHeaderString: Init failed");
    }
    
    return self;
}


-(id)initWithBackEnd:(id)backend
{
    //initialze the value with a mutable copy of the attributed string
    if( self = [super init] )
    {
        //Mountain Lion call
        //headstr =[[backend originalMessageHeaders] attributedStringShowingHeaderDetailLevel:1
        //	useHeadIndents:NO
        //	useBold:YES
        //	includeBCC:YES];

        //new call for Lion
        headstr = [[[backend originalMessageHeaders] attributedStringShowingHeaderDetailLevel:1] mutableCopy];
        
        
        //remove the color attribute so that the text is black instead of gray
        //also remove paragraph style included in the header to avoid spacing issues when received by some mail clients
        [headstr removeAttribute:@"NSColor" range:NSMakeRange(0,[headstr length])];
        [headstr removeAttribute:@"NSParagraphStyle" range:NSMakeRange(0,[headstr length])];
        RWH_LOG(@"MailHeaderString: created headstr: %@",headstr);
    }
    else {
        RWH_LOG(@"MailHeaderString: Init Backend failed");
    }
    
    return self;
}

/*
 * descr: Bolds the lables for header elements (i.e., From:, To:, Subject:, Date:, etc.).
 */
-(void)boldHeaderLabels
{
    //get all of the fonts in use, but only use the first one
    NSDictionary *dict = [headstr fontAttributesInRange:NSMakeRange(0,[headstr length])];
    
    NSEnumerator *enumer = [dict objectEnumerator];
    
    NSFont *basicFont  = (NSFont *) [enumer nextObject]; //[dict objectForKey:key];
    RWH_LOG(@"font = %@",basicFont);
    
    NSString *fontName = [basicFont fontName];
    RWH_LOG(@"orig font name is: %@",fontName);
    const CGFloat *mat = [basicFont matrix];
    
    //check if the font is already bold before making it bold
    NSRange boldRangeLoc;
    boldRangeLoc =[fontName rangeOfString:@"-Bold"];
    if( boldRangeLoc.location == NSNotFound )
    {
        fontName = [[fontName autorelease] stringByAppendingString:@"-Bold"];
    }
    
    RWH_LOG(@"font name is: %@",fontName);
    
    NSFont *boldFont = [NSFont fontWithName:fontName matrix:mat];
    
    //setup a regular expression to find a word followed by a colon and then space
    // should get the first item (e.g. "From:").
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:[headstr string] options:0 range:NSMakeRange(0, [headstr length])];
    
    RWH_LOG(@"Match Range is: %@", NSStringFromRange(rangeOfFirstMatch));
    [headstr addAttribute:@"NSFont" value:boldFont range:rangeOfFirstMatch];
    
    //new regex and for loop to process the rest of the attribute names (e.g. Subject:, To:, Cc:, etc.)
    regex = [NSRegularExpression regularExpressionWithPattern:@"(\\n|\\r)[\\w\\-\\s]+:\\s" options: NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches=[regex matchesInString:[headstr string] options:0 range:NSMakeRange(0,[headstr length])];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        [headstr addAttribute:@"NSFont" value:boldFont range:matchRange];
    }
}

-(WebArchive *)getWebArch
{
    WebArchive *arch = [headstr webArchiveForRange:NSMakeRange(0,[headstr length]) fixUpNewlines:YES];
    return arch;
}

-(NSMutableAttributedString *)string
{
    return headstr;
}

@end
