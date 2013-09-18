RWH - quoting headers of email in Mail.app
------------------------------------------
[ReplyWithHeader][2] mail bundle enables Apple Mail application to represent reply message headers like forwarding.

* [Latest Release](#latest-release)
* [Mail Bundle/Plugin version details](#mail-bundleplugin-version-details)
* [Release Downloads](#release-downloads)
* [NEWS](#news)
* [Issue Tracker](#issue-tracker)
* [Author](#author)
* [Credits](#credits)
* [License](#license)
* [Steps to Installation ReplyWithHeader](#steps-to-installation-replywithheader)

* * *

Latest Release
--------------
* **Released in v3.5**
	* Added support for 10.8.5 - Mail 6.6 [1510]

Mail Bundle/Plugin version details
----------------------------------
* 3.x versions are for Mountain Lion
* 2.x versions are for Lion
* 1.x versions are for Snow Leopard and earlier

I hope this is helpful to choose appropriate plugin/bundle version :)

Release Downloads
-----------------
* Latest version from [https://app.box.com/s/5yo06qpgm299jp3k0hro][5] [Previous Releases available too]

NEWS
----
* Development started for RWH 3.6, [milestone details here][3]

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

License
-------
See [LICENSE][4]

* * *

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
<pre><code>RWH &lt;version number> mail bundle loaded successfully
RWH &lt;version number> Oh it's a wonderful life</pre></code>

[1]: http://myjeeva.com
[2]: http://myjeeva.com/replywithheader
[3]: https://github.com/jeevatkm/ReplyWithHeaders/issues
[4]: https://github.com/jeevatkm/ReplyWithHeaders/blob/master/ReplyWithHeader/LICENSE
[5]: https://app.box.com/s/5yo06qpgm299jp3k0hro
