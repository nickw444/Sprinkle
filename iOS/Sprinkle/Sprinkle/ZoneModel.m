//
//  ZoneModel.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "ZoneModel.h"
#import "SprinkleRPCClient.h"
#import "Zone.h"
@implementation ZoneModel


+ (ZoneModel *) sharedModel {
    static ZoneModel *sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc]init];
    });
    return sharedModel;
}

-(id) init {
    if (self = [super init]) {
        self.zones = [NSArray array];
    }
    return self;
}

-(void)reloadZones {
    [[SprinkleRPCClient sharedClient]invokeMethod:@"get_zones" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        self.zones = [self processZonesArray:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZoneModel-Updated" object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED TO GET ZONES");
    }];
}

-(NSArray *) processZonesArray:(NSArray *)array {
    NSMutableArray *zones = [NSMutableArray array];
    for(NSDictionary *z in array) {
        Zone *zone = [[Zone alloc] initWithZoneDict:z inModel:self];
        [zones addObject:zone];
    }
    return [NSArray arrayWithArray:zones];
}

-(void)reloadSchedule {
    
}


#pragma mark - Duration 
- (NSArray *)durationMap {
    static NSArray *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @[@(2  * 60),
                   @(5  * 60),
                   @(10 * 60),
                   @(15 * 60),
                   @(30 * 60)];
    });
    return states;
}

#define NSUD_LAST_DURATION @"LAST_DURATION_INDEX"
- (NSUInteger) currentDurationIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:NSUD_LAST_DURATION];
}
- (void) setCurrentDurationIndex:(NSUInteger)index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:NSUD_LAST_DURATION];
}

- (NSNumber *)currentDuration {
    return [[self durationMap] objectAtIndex:self.currentDurationIndex];
}



@end
