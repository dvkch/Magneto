//
//  SYAdder.h
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYComputerModel;

@protocol SYAdderDelegate <NSObject>

@required
- (void)request:(NSURLRequest*)request
    forComputer:(SYComputerModel*)computer
finishedWithResponse:(NSURLResponse*)response
 andContentData:(NSData*)contentData;

- (void)request:(NSURLRequest*)request
    forComputer:(SYComputerModel*)computer
failedWithError:(NSError*)error;

@end

@interface SYAdder : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableArray *_connections;
    NSMutableDictionary *_connectionsData;
    NSMutableDictionary *_connectionsComputers;
    NSMutableDictionary *_connectionsResponses;
}

@property (weak, atomic) id<SYAdderDelegate> delegate;


+(SYAdder*)shared;

-(NSString*)keyForConnection:(NSURLConnection*)connection;
-(NSMutableData*)dataForConnection:(NSURLConnection*)connection;
-(SYComputerModel*)computerForConnection:(NSURLConnection*)connection;
-(NSURLResponse*)responseForConnection:(NSURLConnection*)connection;

-(void)setData:(NSMutableData*)data forConnection:(NSURLConnection*)connection;
-(void)setComputer:(SYComputerModel*)computer forConnection:(NSURLConnection*)connection;
-(void)setResponse:(NSURLResponse*)response forConnection:(NSURLConnection*)connection;

-(void)resetItemsForConnection:(NSURLConnection*)connection;

-(void)startRequest:(NSURLRequest*)request forComputer:(SYComputerModel*)computer;

@end
