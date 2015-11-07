//
//  ScheduleViewController.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 31/10/2015.
//
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
