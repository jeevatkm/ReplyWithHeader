RWH - quoting headers of email in Mail.app
------------------------------------------
[ReplyWithHeader][2] mail bundle enables Apple Mail application to represent reply message headers like forwarding.

Released v3.5
-------------
* Added support for 10.8.5 - Mail 6.6 [1510]
* Detailed information is [available here][2] coming soon!!!

Mail Bundle Download
--------------------
* Latest version from [https://app.box.com/s/5yo06qpgm299jp3k0hro][5] [Previous Releases available too]

Development started for v3.6
----------------------------
* Preferences UI improvement in Mail.app
* Enhancements implementation

Issue Tracker
-------------
Please submit any bugs or annoyances on the [Issues][3]

***Note: Existing enhancements requests will be taken care in upcoming days!***

Author
------
Jeevanandam M. - jeeva@myjeeva.com ([myjeeva.com][1])

Credits
-------
* Jason Schroth (jschroth) extended his helping hands towards maintaining [ReplyWithHeader][2] mail bundle from Aug 9th, 2012 to Sep 16, 2013
* Saptarshi Guha (saptarshiguha) initially started [ReplyWithHeader][2] mail bundle development for Apple Mail Application on Oct 22nd, 2010. He handed over the project to Jason Schroth (jschroth).

Requirements
------------
At least Mail: Version 6.2 (1499) Mountain Lion: 10.8

License
-------
See [LICENSE][4]

Steps to Installation ReplyWithHeader
-------------------------------------

1. Quit Mail.app
2. Download and unzip the attachment in `~/Library/Mail/Bundles` (create the directory if missing)
   Unzipping will return `ReplyWithHeaders.mailbundle` - copy this to `~/Library/Mail/Bundles`
3. In the terminal
<pre><code>defaults write com.apple.mail EnableBundles -bool true</pre></code>

4. Restart Mail.app

**Verification**

1. Start Console.app (/Applications/Utilities)

2. In the search bar (top right corner of Console.app) type: **Mail**

   This will restrict your information to Mail.app messages

3. In the console, if all goes well, you should see
<pre><code>RWH 3.5 mail bundle loaded sccessfully
RWH 3.5 Oh it's a wonderful life</pre></code>

[1]: http://myjeeva.com
[2]: http://myjeeva.com/replywithheader
[3]: https://github.com/jeevatkm/ReplyWithHeaders/issues
[4]: https://github.com/jeevatkm/ReplyWithHeaders/blob/master/ReplyWithHeader/LICENSE
[5]: https://app.box.com/s/5yo06qpgm299jp3k0hro
