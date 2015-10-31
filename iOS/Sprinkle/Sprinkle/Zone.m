//
//  Zone.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "Zone.h"
#import "SprinkleRPCClient.h"
#import "Schedule.h"
@implementation Zone
@synthesize mode = _mode;
@synthesize label = _label;
@synthesize offDate = _offDate;

-(id) initWithZoneDict:(NSDictionary*)dict inModel:(ZoneModel*)model {
    if (self = [super init]) {
        _zoneModel = model;
        _zoneID = dict[@"circuit"];
        [self fromDict:dict];
    }
    return self;
}

- (void) fromDict:(NSDictionary *)dict {
    _label = dict[@"name"];
    _mode = [self zoneModeFromString:dict[@"mode"]];
    _offDate = nil;
    NSString *offAt = dict[@"off_at"];
    if (![offAt isEqual:[NSNull null]]) {
        _offDate = [self dateFromIsoString:dict[@"off_at"]];
    }
}

- (void) setMode:(ZoneMode)mode {
    [self setMode:mode WithCompletion:nil];
}

-(void) setMode:(ZoneMode)mode WithCompletion:(void (^)())completion {
    _mode = mode;
    NSDictionary *params = @{
         @"mode": [self stringModeFromMode:mode],
         @"circuit": self.zoneID,
         @"duration": self.zoneModel.currentDuration,
         };
    
    [[SprinkleRPCClient sharedClient] invokeMethod:@"set_mode" withParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success whilst setting a circuit %@'s mode", self.zoneID);
        NSLog(@"%@", responseObject);
        [self fromDict:responseObject];
        if (completion)
            completion();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
        if (completion)
            completion();
    }];
    
}

- (NSDate *) offDate {
    if (_offDate) {
        NSTimeInterval difference = [_offDate timeIntervalSinceNow];
        if (difference < 0) {
            _offDate = nil;
        }
    }
    return _offDate;
}

-(void) setLabel:(NSString *)label {
    [self setLabel:label WithCompletion:nil];
}

-(void) setLabel:(NSString *)label WithCompletion:(void (^)())completion {
    _label = label;
    
    [[SprinkleRPCClient sharedClient] invokeMethod:@"set_zone"
                                    withParameters:@{
                                                     @"circuit": self.zoneID,
                                                     @"name": _label
                                                     }
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                               [self setState:responseObject];
                                               NSLog(@"Success whilst setting a label");
                                               if (completion)
                                                   completion();
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Failure whilst setting label");
                                               if (completion)
                                                   completion();
                                           }];
}

-(NSString *) stringModeFromMode:(ZoneMode)mode {
    switch (mode) {
        case ZoneModeAuto:
            return @"AUTO";
            break;
        case ZoneModeOff:
            return @"OFF";
            break;
        case ZoneModeOn:
            return @"ON";
            break;
        default:
            return nil;
    }
}

- (ZoneMode) zoneModeFromString:(NSString *)string {
    if ([string isEqualToString:@"AUTO"]) {
        return ZoneModeAuto;
    }
    else if ([string isEqualToString:@"ON"]) {
        return ZoneModeOn;
    }
    else {
        return ZoneModeOff;
    }
}


- (NSDate *) dateFromIsoString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

#pragma mark - Schedule

- (NSMutableArray *) processSchedule:(NSArray *)objects {
    NSMutableArray *schedule = [NSMutableArray array];
    for (NSDictionary *obj in objects) {
        [schedule addObject:[[Schedule alloc] initWithScheduleDict:obj inZone:self]];
    }
    return schedule;
}

-(void) reloadScheduleWithCompletion:(void (^)())completion {
    [[SprinkleRPCClient sharedClient] invokeMethod:@"get_schedule"
                                    withParameters:@{
                                                     @"circuit": self.zoneID,
                                                     }
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               NSLog(@"Success whilst getting a schedule %@", responseObject);
                                               self.schedule = [self processSchedule:responseObject];
                                               if (completion)
                                                   completion();

                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Failure whilst getting a schedule");
                                               if (completion)
                                                   completion();
                                           }];
}

- (void) deleteSchedule:(Schedule *)scheduleObject WithCompletion:(void (^)())completion {

    [self.schedule removeObject:scheduleObject];
    [[SprinkleRPCClient sharedClient] invokeMethod:@"rm_schedule"
                                    withParameters:@{
                                                     @"job_id": scheduleObject.remoteID,
                                                     }
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               
                                               if (completion)
                                                   completion();
                                               
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               if (completion)
                                                   completion();
                                           }];
}

@end
