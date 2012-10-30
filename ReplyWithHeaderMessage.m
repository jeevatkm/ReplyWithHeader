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
