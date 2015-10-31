//
//  Zone.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <Foundation/Foundation.h>
#import "ZoneModel.h"
@class Schedule;

typedef NS_ENUM(NSUInteger, ZoneMode) {
    ZoneModeOff,
    ZoneModeOn,
    ZoneModeAuto,
};

@interface Zone : NSObject
-(id) initWithZoneDict:(NSDictionary*)dict inModel:(ZoneModel*)model;

@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSDate *offDate;
@property (nonatomic, retain) NSNumber *zoneID;
@property (nonatomic) ZoneMode mode;
@property (nonatomic, weak) ZoneModel* zoneModel;
@property (nonatomic, retain) NSMutableArray *schedule;
@property (nonatomic, retain) Schedule *currentNewSchedule;

-(void) setLabel:(NSString *)label WithCompletion:(void (^)())completion;
-(void) setMode:(ZoneMode)mode WithCompletion:(void (^)())completion;

-(void) reloadScheduleWithCompletion:(void (^)())completion;
- (void) deleteSchedule:(Schedule *)scheduleObject WithCompletion:(void (^)())completion;

@end
