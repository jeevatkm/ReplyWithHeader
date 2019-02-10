/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2019 Jeevanandam M.
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
//  MHUpdateAlert.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 10/6/13.
//
//

@class  WebView;

@interface MHUpdateAlert : NSWindowController {
    NSString *versionDesc;
    NSString *releaseNotes;
    NSString *downloadLink;
    
    IBOutlet WebView *_releaseNotesView;
    IBOutlet NSTextField *_subTitle;
    IBOutlet NSTextField *_versionDesc;
    IBOutlet NSButton *_downloadButton;
    IBOutlet NSButton *_laterButton;
}

- (id)initWithData:(NSString *)desc releaseNotes:(NSString *)notes donwloadLink:(NSString *)urlString;

@end
