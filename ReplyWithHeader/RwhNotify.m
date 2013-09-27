/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
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
//  RwhNotify.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/27/13.
//
//

#import "RwhNotify.h"
#import "RwhMailBundle.h"
#import "RwhMailConstants.h"

@implementation RwhNotify

- (void)performVersionAvailabilty:(NSDictionary *)jsonDic {
    NSDictionary *latest = [[jsonDic objectForKey:@"releases"] objectForKey:@"latest"];
    NSString *currentVersion = [RwhMailBundle bundleVersionString];
    NSString *serverVersion = [latest objectForKey:@"shortVersion"];
    
    NSComparisonResult result = [comparator compareVersion:currentVersion toVersion:serverVersion];
    RWH_LOG(@"Current Version is %@, Latest version is %@ and comparison result %ld", currentVersion, serverVersion, result);
    
    if (result == NSOrderedAscending) {
        NSString *message = [NSString stringWithFormat:@"%@ %@ new version available!", [RwhMailBundle bundleName], [latest objectForKey:@"version"]];
        
        NSString *infoText = [NSString stringWithFormat:@"%@; published on %@.", [latest objectForKey:@"title"], [latest objectForKey:@"pubDate"]];
        
        NSAlert *alert = [[NSAlert alloc] init];
        
        [alert setIcon:[RwhMailBundle bundleLogo]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:message];
        [alert setInformativeText:infoText];
        
        [alert addButtonWithTitle:@"Download"];
        [alert addButtonWithTitle:@"Release Notes"];
        [alert addButtonWithTitle:@"Later"];
        
        [[[alert buttons] objectAtIndex:0] setKeyEquivalent:@"\r"];
        
        int response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [[NSWorkspace sharedWorkspace]
             openURL:[NSURL URLWithString:[latest objectForKey:@"downloadLink"]]];
        }
        else if (response == NSAlertSecondButtonReturn) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myjeeva.com/replywithheader#release-notes"]];
        }
        else if (response == NSAlertThirdButtonReturn) {
            RWH_LOG(@"Later button is pressed, nothing to do!");
        }
        
        [alert release];
    }
    else {
        RWH_LOG(@"Same/Higher version present, just ignore it.");
    }
}

- (void)checkNewVersion {
    NSData *changeLogData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:appCastUrl]];
    
    if (changeLogData == nil) {
        NSLog(@"RWH new version availabilty check failed. May be internet connection unavailable.");
    }
    else {
        NSError *error = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:changeLogData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"RWH JSON parsing error for new version availabilty check. Description [%@] and Failure Reason [%@]", [error localizedDescription], [error localizedFailureReason]);
        }
        else {
            [self performVersionAvailabilty:jsonDic];        
        }
    }
    
    [changeLogData release];
}


- (id)init {    
    if (self = [super init]) {
        appCastUrl = [[[RwhMailBundle bundle] infoDictionary] objectForKey:RwhMailAppCastURLKey];
        
        comparator = [SUStandardVersionComparator defaultComparator];
    }
    else {
        RWH_LOG(@"RwhNotify initialize failed");
    }    
    return self;
}

@end
