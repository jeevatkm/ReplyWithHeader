/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2016 Jeevanandam M.
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
//  MHUpdater.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/6/13.
//
//

#import "MHUpdater.h"
#import "SUStandardVersionComparator.h"
#import "MHUpdateAlert.h"

@implementation MHUpdater

- (void)showUpdateAlert
{
    [NSApp runModalForWindow:[_alert window]];
}

- (BOOL)isUpdateAvailable
{
    BOOL found = FALSE;
    if (jsonDic)
    {
        NSDictionary *latest = [[jsonDic objectForKey:@"releases"] objectForKey:@"latest"];
        NSString *serverVersion = [latest objectForKey:@"shortVersion"];
        NSString *currentVersion = [MailHeader bundleVersionString];
        
        NSComparisonResult result = [comparator compareVersion:currentVersion toVersion:serverVersion];
        NSString *possibleMatch = [NSString stringWithFormat:@"%@-beta", serverVersion];
        if (result == NSOrderedAscending || ([currentVersion isEqualToString:possibleMatch]))
        {            
            NSString *versionDesc = [NSString stringWithFormat:MHLocalizedStringByLocale(@"STRING_UPDATE_VERSION_DESC", MHLocaleIdentifier),
                                     [MailHeader bundleName],
                                     serverVersion,
                                     currentVersion];
            NSLog(@"%@ v%@ now available! -- you have v%@",
                  [MailHeader bundleName], serverVersion, currentVersion);
            
            NSString *releaseNotes = [latest objectForKey:@"releaseNotes"];            
            NSString *downloadLink = [latest objectForKey:@"downloadUrl"];
            
            _alert = [[MHUpdateAlert alloc]
                      initWithData:versionDesc releaseNotes:releaseNotes donwloadLink:downloadLink];
            
            found = TRUE;
        }
    }
    return found;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *appCastUrl = [[[MailHeader bundle] infoDictionary] objectForKey:MHAppCastURLKey];        
        NSData *appCastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appCastUrl]];
        
        if (appCastData)
        {
            comparator = [SUStandardVersionComparator defaultComparator];
            
            NSError * __autoreleasing error = nil;
            jsonDic = [NSJSONSerialization
                       JSONObjectWithData:appCastData
                       options:NSJSONReadingMutableContainers
                       error:&error];
            
            if (error)
            {
                MHLog(@"RWH JSON parsing error for new version availabilty check. Failure Reason [%@]", [error localizedDescription]);
                jsonDic = nil;
            }
        }
        else
        {
            MHLog(@"RWH new version availabilty check failed. May be internet connection unavailable.");
        }
    }
    
    return self;
}

@end
