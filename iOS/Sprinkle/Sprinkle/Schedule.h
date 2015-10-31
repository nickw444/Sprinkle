//
//  Schedule.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <Foundation/Foundation.h>
#import "Zone.h"


typedef NS_OPTIONS(NSUInteger, ScheduleDays) {
    Monday = 1 << 0,
    Tuesday = 1 << 1,
    Wednesday = 1 << 2,
    Thursday = 1 << 3,
    Friday = 1 << 4,
    Saturday = 1 << 5,
    Sunday = 1 << 6,
};

@interface Schedule : NSObject

-(id) initWithScheduleDict:(NSDictionary *)dict inZone:(Zone *)zone;
-(id) initWithZone:(Zone *)zone;

@property (nonatomic, weak) Zone *zone;
@property (nonatomic, retain) NSNumber *circuit;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSString *remoteID;
@property (nonatomic) ScheduleDays dayOfWeek;
@property (nonatomic, retain) NSNumber *hour;
@property (nonatomic, retain) NSNumber *minute;

+(NSString *) dayOfWeekStringFromInt:(ScheduleDays)days;
+(NSString *) dayOfWeekStringFromInt:(ScheduleDays)days withSpace:(BOOL)withSpace;
+(ScheduleDays) scheduleDaysFromString:(NSString *)string;
- (void) save;

@end
