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



#import "ReplyWithHeaderMessage.h"

@implementation ReplyWithHeaderMessage

- (void)rph_continueToSetupContentsForView:(id)arg1 withParsedMessages:(id)arg2
{
    //Log that we are here
    RWH_LOG();
    
    //if we sizzled, this should be fine... (because this would be calling the original implementation)
    [self rph_continueToSetupContentsForView: arg1 withParsedMessages: arg2];
	
    NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] retain];
    BOOL enabled = [prefs boolForKey:@"enableBundle"];
    BOOL replaceForward = [prefs boolForKey:@"replaceForward"];
    
    //get my type and check it - reply or replyall only
    int selftype=[self type];
    RWH_LOG(@"message type is %d",selftype);
    
	if( enabled )
    {
    
        if( (selftype==1 || selftype==2) )
        {
            //start by setting up the quoted text from the original email
            MailQuotedOriginal *quotedText = [[MailQuotedOriginal alloc] initWithBackEnd:self];
        
            //create the header string element
            MailHeaderString *newheaderString = [[MailHeaderString alloc] initWithBackEnd:self];
        
            //this is required for Mountain Lion - for some reason the mail headers are not bold anymore.
            [newheaderString boldHeaderLabels];
        
            RWH_LOG(@"Sig=%@",[newheaderString string]);
        
            //insert the new header text
            [quotedText insertMailHeader:newheaderString];
        }
        if( replaceForward && selftype == 3 )
        {
            //start by setting up the quoted text from the original email
            MailQuotedOriginal *quotedText = [[MailQuotedOriginal alloc] initWithBackEnd:self];
            [quotedText insertFwdHeader];
            
        }
    }
}


@end
