//
//  EditScheduleTableViewController.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
@interface EditScheduleTableViewController : UITableViewController
@property (nonatomic, strong) Schedule *schedule;
@property (nonatomic, weak) Zone *zone;

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (nonatomic, strong) NSArray *switches;

- (IBAction)startStepperPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIStepper *hourStepper;
@property (weak, nonatomic) IBOutlet UIStepper *minuteStepper;

- (IBAction)durationStepperPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *durationHoursField;
@property (weak, nonatomic) IBOutlet UIStepper *durationHoursStepper;
@property (weak, nonatomic) IBOutlet UITextField *durationMinutesField;
@property (weak, nonatomic) IBOutlet UIStepper *durationMinutesStepper;


@property (weak, nonatomic) IBOutlet UISwitch *mondaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tuesdaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *wednesdaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *thursdaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *fridaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saturdaySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sundaySwitch;
- (IBAction)switchChanged:(id)sender;

@end
