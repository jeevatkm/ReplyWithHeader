* NEWS
Monday 16-Sep-2013
- Updated Support for 10.8.5 (Mail 6.6 [1510]) 

Wednesday 10-Jul-2013
- Changed license terms to MIT license with agreement from Saptarshi Guha
- Due to unforeseen circumstances, I am no longer able to support this software. I hope someone else will be able to continue supporting it going forward.

Wednesday 05-Jun-2013
 - Updated support for 10.8.4 (Mail 6.5 (1508))
 - Download latest version https://www.box.com/s/vvazf1g87b0rumtng4k1 (past versions will be posted here soon)

Monday 22-Oct-2012
- New Preferences Pane (RWH) in Mail Preferences
  - enable or disable the plugin from the preferences.
  - specify the leading string (i.e. "-----Original Message-----").
  - Enable or Disable font fixes for Entourage 2004.

Sunday 12-Aug-2012
- Mountain Lion support
- Extra "wrote" line that appears when responding to new messages handled (I think, but it is difficult to repeat)
- Attribute names are now bold again

Thursday Oct 13
- Info.plist updated by Jason Schroth for 10.7.2
- version 1.1.7
- Removed the older UUIDs that were there for 10.6 installations. Snow Leopard supports ends at is 1.1.5.

Wed Sep 14 
- Fixes provided Jason Schroth to make ReplyWithHeader compatible with Lion (version 1.1.6)
- Version 1.1.5 works for Snow Leopard.

Sun Mar 27 14:08:21 PDT 2011
- Updated for Mail and Message 4.5
- Version is 1.1.5

Sun Nov 28 10:59:29 PST 2010:
- Updated the bundle for the latest Message and Mail framework UUIDs.
- Version is 1.1.4

* About
The reply in Mail.app creates a new email with the preamble

On 21 July 2010, John Doe wrote:

....


When forward, the first few lines is the 

From:
Subject:
Date:

etc.

ReplyWithHeaders causes the reply message to behave like forwarding.

* Requirements:
At least

Mail: Version 6.2 (1499)

Mountain Lion: 10.8

* Installation

1. Quit Mail.app
2. Save and unzip the attachment in ~/Library/Mail/Bundles (create the directory if missing)
   Unzipping will return "ReplyWithHeaders.mailbundle" - copy this to ~/Library/Mail/Bundles
3. In the terminal:

   > defaults write com.apple.mail EnableBundles -bool true

4. Start Console.app (/Applications/Utilities)
5. In the search bar (top right corner of Console.app) type: Mail

   This will restrict your information to Mail.app messages
6. Restart Mail.app

In the console, if all goes well, you should see

Loaded ReplyWithHeader
ReplyWithHeaders: Oh its a wonderful life



