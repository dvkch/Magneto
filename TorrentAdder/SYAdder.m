//
//  SYAdder.m
//  TorrentAdder
//
//  Created by rominet on 20/05/14.
//  Copyright (c) 2014 Syan. All rights reserved.
//

#import "SYAdder.h"
#import "NSArray+JSON.h"
#import "SYAppDelegate.h"
#import "SYComputerModel.h"

@implementation SYAdder

+(SYAdder *)shared {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

-(id)init {
    self = [super init];
    if(self) {
        self->_connections = [[NSMutableArray alloc] init];
        self->_connectionsData = [[NSMutableDictionary alloc] init];
        self->_connectionsResponses = [[NSMutableDictionary alloc] init];
        self->_connectionsComputers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)startRequest:(NSURLRequest *)request
        forComputer:(SYComputerModel *)computer
{
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:YES];
    [self setComputer:computer forConnection:connection];
    [self->_connections addObject:connection];
}

#pragma mark - NSDictionaries management

-(NSString*)keyForConnection:(NSURLConnection *)connection
{
//    return [[[connection originalRequest] URL] absoluteString];
    return [NSString stringWithFormat:@"%p", connection];
}

-(NSMutableData*)dataForConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    return [self->_connectionsData objectForKey:key];
}

-(SYComputerModel*)computerForConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    return [self->_connectionsComputers objectForKey:key];
}

-(NSURLResponse*)responseForConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    return [self->_connectionsResponses objectForKey:key];
}

-(void)setData:(NSMutableData*)data forConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    if(!data)
        [self->_connectionsData removeObjectForKey:key];
    else
        [self->_connectionsData setObject:data forKey:key];
}

-(void)setComputer:(SYComputerModel*)computer forConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    if(!computer)
        [self->_connectionsComputers removeObjectForKey:key];
    else
        [self->_connectionsComputers setObject:computer forKey:key];
}

-(void)setResponse:(NSURLResponse*)response forConnection:(NSURLConnection*)connection
{
    NSString *key = [self keyForConnection:connection];
    if(!response)
        [self->_connectionsResponses removeObjectForKey:connection];
    else
        [self->_connectionsResponses setObject:response forKey:key];
}

-(void)resetItemsForConnection:(NSURLConnection*)connection
{
    // If we use the connection's request URL as dictionary key
    // and don't reset items using this method when creating
    // a second request (in case of a 409 error code for instance)
    // then the data for the new connection will accumulate on
    // the data from the first connection.
    // To prevent this we need to add the following line before
    // starting the new connection :
    //
    // [self resetItemsForConnection:connection];
    
    
    [self->_connections removeObject:connection];
    [self setData:nil forConnection:connection];
    [self setComputer:nil forConnection:connection];
    [self setResponse:nil forConnection:connection];
}


#pragma mark - NSURLConnectionDelegates methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(self.delegate)
        [self.delegate request:[connection originalRequest]
                   forComputer:[self computerForConnection:connection]
               failedWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self setResponse:response forConnection:connection];
    
    int code = [(NSHTTPURLResponse*)response statusCode];
    if(code == 409) {
        NSMutableURLRequest *newRequest = [[connection originalRequest] mutableCopy];
        NSString *sessionID = [[(NSHTTPURLResponse*)response allHeaderFields]
                               objectForKey:@"X-Transmission-Session-Id"];
        
        [newRequest setValue:sessionID forHTTPHeaderField:@"X-Transmission-Session-Id"];
        
        SYComputerModel *computer = [self computerForConnection:connection];
        [self startRequest:newRequest forComputer:computer];
    }
    
    [self->_connections removeObject:connection];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableData *wholeData = [self dataForConnection:connection];
    if(!wholeData) wholeData = [[NSMutableData alloc] init];
    
    [wholeData appendData:data];
    
    [self setData:wholeData forConnection:connection];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // it is guaranteed to have a response before did finish loading
    // http://stackoverflow.com/questions/7360526/is-didreceiveresponse-guaranteed-to-preceed-connectiondidfinishloading
    
    NSURLResponse *response = [self responseForConnection:connection];
    if([(NSHTTPURLResponse*)response statusCode] == 409)
        return;

    if(self.delegate)
        [self.delegate request:[connection originalRequest]
                   forComputer:[self computerForConnection:connection]
          finishedWithResponse:[self responseForConnection:connection]
                andContentData:[self dataForConnection:connection]];
}

@end
