//
//  NSArray+JSON.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>

// http://stackoverflow.com/questions/6368867/generate-json-string-from-nsdictionary

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@interface NSArray (BVJSONString)
- (NSString *)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint;
@end

@interface NSData (JSON)
- (NSDictionary *)json;
- (NSString *)stringWithUTF8Encoding;
@end