//
//  SingleZoneScheduleViewController.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "Zone.h"

@interface SingleZoneScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) Zone *zone;
@end
