//
//  SprinkleRPCClient.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "SprinkleRPCClient.h"

@implementation SprinkleRPCClient
+ (AFJSONRPCClient* ) sharedClient {
    static AFJSONRPCClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:@"http://192.168.8.6:8002"]];
    });
    return sharedClient;
}
@end
