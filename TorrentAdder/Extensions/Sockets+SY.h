//
//  Sockets+SY.h
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 02/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <netinet/in.h>

FOUNDATION_EXPORT struct sockaddr_in* sockaddr_in_from_sockaddr(struct sockaddr *value);

FOUNDATION_EXPORT struct sockaddr_in6* sockaddr_in6_from_sockaddr(struct sockaddr *value);

