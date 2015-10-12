//
//  SprinkleRPCClient.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import <Foundation/Foundation.h>
#import <AFJSONRPCClient/AFJSONRPCClient.h>
@interface SprinkleRPCClient : NSObject
+ (AFJSONRPCClient *) sharedClient;

@end
