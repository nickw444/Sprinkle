//
//  ScheduleCell.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
#import "Zone.h"

@interface ScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) Zone *zone;
@property (nonatomic, weak) Schedule *schedule;
@end
