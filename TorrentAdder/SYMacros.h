//
//  SYMacros.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block)    \
static dispatch_once_t pred = 0;                \
__strong static id _sharedObject = nil;            \
dispatch_once(&pred, ^{                            \
_sharedObject = block();                    \
});                                                \
return _sharedObject;

#define IOS_VER_GREATER_OR_EQUAL(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
