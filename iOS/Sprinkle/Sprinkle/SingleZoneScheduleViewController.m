//
//  SingleZoneScheduleViewController.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import "SingleZoneScheduleViewController.h"
#import "ScheduleCell.h"
#import "EditScheduleTableViewController.h"
@interface SingleZoneScheduleViewController ()

@end

@implementation SingleZoneScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Schedule", self.zone.label];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    
    [self.zone reloadScheduleWithCompletion:^{
        NSLog(@"Loaded!");
        [self.tableView reloadData];
    }];
    // Do any additional setup after loading the view.
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)addButtonPressed:(id)sender {
    Schedule *new = [[Schedule alloc] initWithZone:self.zone];
    [self openEditViewWithSchedule:new];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.zone.schedule count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCell *cell = (ScheduleCell *)[tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
    cell.zone = self.zone;
    cell.schedule = [self.zone.schedule objectAtIndex:[indexPath row]];
    return cell;
}
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Do soemthing commit");
    Schedule *schedule = [self.zone.schedule objectAtIndex:[indexPath row]];
    [self.zone deleteSchedule:schedule WithCompletion:nil];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Schedule *schedule = [self.zone.schedule objectAtIndex:[indexPath row]];
    [self openEditViewWithSchedule:schedule];
}


- (void) openEditViewWithSchedule:(Schedule *)schedule {
    EditScheduleTableViewController *edit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditScheduleTableViewController"];
    
    edit.schedule = schedule;
    edit.zone = self.zone;
    
    UINavigationController *next = [[UINavigationController alloc] initWithRootViewController:edit];
    [self presentViewController:next animated:YES completion:nil];
}

@end
