//
//  ScheduleCell.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "ScheduleCell.h"

@implementation ScheduleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setSchedule:(Schedule *)schedule {
    _schedule = schedule;
    [self render];
}

- (void) render {
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)[self.schedule.hour integerValue], (long)[self.schedule.minute integerValue]];
    
    // Calculate duration label.
    
    self.durationLabel.text = [self calculateDurationLabel];
    self.daysLabel.text = [Schedule dayOfWeekStringFromInt:self.schedule.dayOfWeek withSpace:YES];
}

- (NSString *)calculateDurationLabel {
    NSUInteger durationSeconds = [self.schedule.duration unsignedIntegerValue];
    NSMutableArray *components = [NSMutableArray array];
    NSUInteger seconds = durationSeconds % 60;
    NSUInteger minutes = (durationSeconds / 60) % 60;
    NSUInteger hours = (durationSeconds / 3600);
    
    if (hours) {
        [components addObject:[NSString stringWithFormat:@"%ld hour%@",hours, (hours == 1)? @"" : @"s"]];
    }
    if (minutes) {
        [components addObject:[NSString stringWithFormat:@"%ld minute%@",minutes, (minutes == 1)? @"" : @"s"]];
    }
    if (seconds) {
        [components addObject:[NSString stringWithFormat:@"%ld second%@",seconds, (seconds == 1)? @"" : @"s"]];
    }
    
    return [components componentsJoinedByString:@", "];
}




@end
