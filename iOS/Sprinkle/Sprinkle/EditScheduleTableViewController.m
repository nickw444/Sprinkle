//
//  EditScheduleTableViewController.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "EditScheduleTableViewController.h"

@interface EditScheduleTableViewController ()

@end

@implementation EditScheduleTableViewController
@synthesize schedule = _schedule;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.switches = @[
                      _mondaySwitch,
                      _tuesdaySwitch,
                      _wednesdaySwitch,
                      _thursdaySwitch,
                      _fridaySwitch,
                      _saturdaySwitch,
                      _sundaySwitch,
                      ];
    [self render];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPressed)];
}

-(void) cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) saveButtonPressed {
    if (_schedule.dayOfWeek == 0) {
        UIAlertController *alrt = [UIAlertController alertControllerWithTitle:@"No days selected" message:@"You must choose at least 1 day for this job" preferredStyle:UIAlertControllerStyleAlert];
        [alrt addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alrt animated:YES completion:nil];

    }
    else {
        [_schedule save];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSchedule:(Schedule *)schedule {
    // Setup the View State using this
    _schedule = schedule;
    [self render];
}

- (void) render {
    self.startLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", _schedule.hour.integerValue, _schedule.minute.integerValue];
    self.minuteStepper.value = _schedule.minute.doubleValue;
    self.hourStepper.value = _schedule.hour.doubleValue;
    
    NSInteger duration = _schedule.duration.integerValue;
    NSInteger hours = (duration / 60 / 60);
    NSInteger minutes = (duration / 60) % 60;
    self.durationHoursField.text = [NSString stringWithFormat:@"%01ld", hours];
    self.durationMinutesField.text = [NSString stringWithFormat:@"%01ld", minutes];
    self.durationHoursStepper.value = (double)hours;
    self.durationMinutesStepper.value = (double)minutes;
    
    ScheduleDays days = _schedule.dayOfWeek;
    for (UISwitch *sw in self.switches) {
        if (days & 0x01) {
            [sw setOn:YES animated:NO];
        }
        else {
            [sw setOn:NO animated:NO];
        }
        days = (days >> 1);
    }
}

- (IBAction)startStepperPressed:(id)sender {
    _schedule.minute = [NSNumber numberWithDouble:self.minuteStepper.value];
    _schedule.hour = [NSNumber numberWithDouble:self.hourStepper.value];
    [self render];
}

- (IBAction)durationStepperPressed:(id)sender {
    double hours = self.durationHoursStepper.value;
    double minutes = self.durationMinutesStepper.value;
    
    _schedule.duration = [NSNumber numberWithDouble:(hours * 60 * 60) + (minutes * 60)];
    [self render];
}

- (IBAction)switchChanged:(id)sender {
    ScheduleDays days = 0;
    int i = 0;
    for (UISwitch *sw in self.switches) {
        if (sw.on) {
            days |= (1 << i);
        }
        i ++;
    }
    _schedule.dayOfWeek = days;
}
@end
