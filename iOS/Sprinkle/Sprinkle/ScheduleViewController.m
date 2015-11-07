//
//  ScheduleViewController.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "ScheduleViewController.h"
#import "ZoneModel.h"
#import "Zone.h"
#import "SingleZoneScheduleViewController.h"
@interface ScheduleViewController ()

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[[ZoneModel sharedModel]zones] count];
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ZoneCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Zone *zone = [[[ZoneModel sharedModel]zones] objectAtIndex:[indexPath row]];
    cell.textLabel.text = zone.label;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ scheduled job%@ configured", zone.numSchedules, (zone.numSchedules.integerValue == 1)? @"" : @"s"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Zone *zone = [[[ZoneModel sharedModel] zones]objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"ShowScheduleSegue" sender:zone];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowScheduleSegue"]) {
        Zone *zone = (Zone *)sender;
        SingleZoneScheduleViewController *next = (SingleZoneScheduleViewController *)segue.destinationViewController;
        next.zone = zone;
    }
}

@end
