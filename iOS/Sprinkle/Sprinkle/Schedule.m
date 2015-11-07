//
//  Schedule.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "Schedule.h"
#import "SprinkleRPCClient.h"

@implementation Schedule

-(id) initWithZone:(Zone *)zone {
    if (self = [super init]) {
        _duration = @(60 * 15); // 15 minutes default
        _hour = @12;
        _minute = @00;
        _dayOfWeek = 0;
        _zone = zone;
    }
    return self;
}

-(id) initWithScheduleDict:(NSDictionary *)dict inZone:(Zone *)zone {
    if (self = [super init]) {
        _zone = zone;
        _circuit = dict[@"circuit"];
        _duration = dict[@"duration"];
        _remoteID = dict[@"id"];
        _hour = dict[@"schedule"][@"hour"];
        _minute = dict[@"schedule"][@"minute"];
        _dayOfWeek = [Schedule scheduleDaysFromString:dict[@"schedule"][@"day_of_week"]];
    }
    return self;
}

+(NSString *) dayOfWeekStringFromInt:(ScheduleDays)days {
    return [self dayOfWeekStringFromInt:days withSpace:NO];
}
+(NSString *) dayOfWeekStringFromInt:(ScheduleDays)days withSpace:(BOOL)withSpace {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *daySelect = @[@"mon", @"tue", @"wed", @"thu", @"fri", @"sat", @"sun"];
    for (NSString *day in daySelect) {
        if (days & 0x1) {
            [result addObject:day];
        }
        days = days >> 1;
    }
    if (withSpace) {
        return [result componentsJoinedByString:@", "];
    }
    else {
        return [result componentsJoinedByString:@","];
    }
}



+(ScheduleDays) scheduleDaysFromString:(NSString *)string {
    NSArray *days = [string componentsSeparatedByString:@","];
    ScheduleDays result = 0;
    for (NSString *day in days) {
        ScheduleDays d;
        if ([day isEqualToString:@"mon"])
            d = Monday;
        else if ([day isEqualToString:@"tue"])
            d = Tuesday;
        else if ([day isEqualToString:@"wed"])
            d = Wednesday;
        else if ([day isEqualToString:@"thu"])
            d = Thursday;
        else if ([day isEqualToString:@"fri"])
            d = Friday;
        else if ([day isEqualToString:@"sat"])
            d = Saturday;
        else if ([day isEqualToString:@"sun"])
            d = Sunday;
        result |= d;
    }
    return result;
}


- (void) save {
    // If it has an online ID, we rm it, then we will make it again...
    void (^createJob)() = ^void() {
        [[SprinkleRPCClient sharedClient] invokeMethod:@"add_schedule"
                                        withParameters:@{
                                                         @"circuit": self.zone.zoneID,
                                                         @"days": [Schedule dayOfWeekStringFromInt:self.dayOfWeek],
                                                         @"hour": self.hour,
                                                         @"minute": self.minute,
                                                         @"duration": self.duration,
                                                         }
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSLog(@"Successfully added entry to the schedule! with Job ID: %@", responseObject[@"job_id"]);
                                                   // Persist the job id
                                                   self.remoteID = responseObject[@"job_id"];
                                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   if (!self.remoteID) {
                                                       if ([self.zone.schedule containsObject:self]) {
                                                           [self.zone.schedule removeObject:self];
                                                       }
                                                   }
                                               }];
    };
    
    if (_remoteID) {
        [[SprinkleRPCClient sharedClient] invokeMethod:@"rm_schedule"
                                        withParameters:@{
                                                         @"job_id": self.remoteID,
                                                         }
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   self.remoteID = nil;
                                                   createJob();
                                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               }];
    }
    else {
        [self.zone.schedule addObject:self];
        createJob();
    }
}


@end
