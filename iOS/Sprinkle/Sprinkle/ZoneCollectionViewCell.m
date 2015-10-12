//
//  ZoneCollectionViewCell.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "ZoneCollectionViewCell.h"

@interface ZoneCollectionViewCell ()
@property (nonatomic, retain) NSDate *offDate;
@property (nonatomic, retain) NSTimer *countdownTimer;
@end

@implementation ZoneCollectionViewCell

- (NSDictionary *)stateIndexMap {
    static NSDictionary *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @{@"OFF": @0,
                   @"ON": @1,
                   @"AUTO": @2};
    });
    return states;
}

- (void) setData:(NSDictionary *)data {
    self.zoneLabel.text = data[@"name"];
    NSLog(@"%@", data);
    self.zoneID = [data[@"circuit"] integerValue];
    self.segmentController.selectedSegmentIndex = [[[self stateIndexMap] objectForKey:data[@"mode"]] integerValue];
    
    NSString *offAt = data[@"off_at"];
    
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    if (![offAt isEqual:[NSNull null]]) {
        self.offDate = [self dateFromIsoString:data[@"off_at"]];
        self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdownLabel) userInfo:nil repeats:YES];
        [self updateCountdownLabel];
    }
    else {
        // Disable the countdown timer if it is active
        self.countdownLabel.text = @"";
    }
}
- (IBAction)zoneModeChanged:(id)sender {
    // Tell the server the mode changed. If the mode is ON
    [self.zoneDelegate cell:self zone:self.zoneID changedWithValue:self.segmentController.selectedSegmentIndex];
}

- (void) updateCountdownLabel {
    self.countdownLabel.text = [self countdownStringUntil:self.offDate];
    
    if ([self.offDate timeIntervalSinceNow] <= 0) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    
}

#pragma mark - Date

- (NSDate *) dateFromIsoString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (NSString *) countdownStringUntil:(NSDate *)date {
    NSUInteger timeUntil = (NSUInteger)[date timeIntervalSinceNow];
    NSUInteger seconds = timeUntil % 60;
    NSUInteger minutes = (timeUntil / 60) % 60;
    NSUInteger hours = (timeUntil / 3600);
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

@end
