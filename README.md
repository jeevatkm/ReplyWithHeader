Quoting reply and forward headers of email in Mail.app
------------------------------------------------------
[ReplyWithHeader][2] mail plugin enables Apple Mail.app to represent reply and forward headers meaningful and blends with corporate world email communication.

* [Plugin Homepage][2]
* [Latest Release - Download from MacUpdate.com][5]
* [Issue Tracker](#issue-tracker)
* [Author](#author)
* [Credits](#credits)
* [License](#license)
* [Steps to Installation ReplyWithHeader](#steps-to-installation-replywithheader)

* * *

Issue Tracker
-------------
Please submit any bugs or annoyances [here][3]

Author
------
Jeevanandam M. (jeeva@myjeeva.com)

Credits
-------
* Jason Schroth (jschroth) extended his helping hands towards maintaining [ReplyWithHeader][2] mail bundle from Aug 9th, 2012 to Sep 16, 2013
* Saptarshi Guha (saptarshiguha) initially started [ReplyWithHeader][2] mail bundle development for Apple Mail Application on Oct 22nd, 2010. He handed over the project to Jason Schroth (jschroth).

License
-------
See [LICENSE][4]

* * *

Steps to Installation ReplyWithHeader
-------------------------------------

1. Quit Mail.app
2. Download and unzip the attachment in `~/Library/Mail/Bundles` (create the directory if missing)
   Unzipping will return `ReplyWithHeader.mailbundle` - copy this to `~/Library/Mail/Bundles`
3. In the terminal
<pre><code>defaults write com.apple.mail EnableBundles -bool true</pre></code>

4. Restart Mail.app

**Verification**

1. Start Console.app (/Applications/Utilities)

2. In the search bar (top right corner of Console.app) type: **Mail**

   This will restrict your information to Mail.app messages

3. In the console, if all goes well, you should see
<pre><code>RWH &lt;version number> plugin loaded
RWH &lt;version number> Wow! it's a wonderful life</pre></code>

[1]: http://myjeeva.com
[2]: http://myjeeva.com/replywithheader
[3]: https://github.com/jeevatkm/ReplyWithHeaders/issues
[4]: https://github.com/jeevatkm/ReplyWithHeaders/blob/master/ReplyWithHeader/LICENSE
[5]: https://www.macupdate.com/app/mac/49256/replywithheader
