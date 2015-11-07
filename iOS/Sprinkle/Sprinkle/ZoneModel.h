//
//  ZoneModel.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <Foundation/Foundation.h>

@protocol ZoneModelDelegate <NSObject>

-(void)zoneDataChanged;

@end

@interface ZoneModel : NSObject
+ (ZoneModel *) sharedModel;

@property (nonatomic, retain) NSArray *zones;

-(void)reloadZones;
-(void)reloadSchedule;

@property (nonatomic, retain, readonly) NSNumber* currentDuration;
@property (nonatomic) NSUInteger currentDurationIndex;

@end
