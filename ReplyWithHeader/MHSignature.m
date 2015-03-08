/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Jeevanandam M.
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
//  MHSignature.m
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 5/25/14.
//
//

#import "MHSignature.h"

static NSString* const kName = @"name";
static NSString* const kUniqueId = @"uniqueId";
static NSString* const kValues = @"values";

@implementation MHSignature

- (id)initWithName:(NSString*)name uniqueId:(NSString*)uniqueId values:(NSMutableDictionary*) values
{
    self = [super init];
    if(self) {
        _name = [name copy];
        _uniqueId = [uniqueId copy];
        _values = [values copy];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:kName];
        _uniqueId = [aDecoder decodeObjectForKey:kUniqueId];
        _values = [aDecoder decodeObjectForKey:kValues];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:_name forKey:kName];
    [aCoder encodeObject:_uniqueId forKey:kUniqueId];
    [aCoder encodeObject:_values forKey:kValues];
}

@end
