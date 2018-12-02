//
//  Sockets+SY.m
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 02/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sockets+SY.h"

struct sockaddr_in* sockaddr_in_from_sockaddr(struct sockaddr *value) {
    if (value == NULL)  {
        return NULL;
    }
    if (value->sa_family == AF_INET) {
        return (struct sockaddr_in *)value;
    }
    return NULL;
}

struct sockaddr_in6* sockaddr_in6_from_sockaddr(struct sockaddr *value) {
    if (value == NULL)  {
        return NULL;
    }
    if (value->sa_family == AF_INET6) {
        return (struct sockaddr_in6 *)value;
    }
    return NULL;
}
