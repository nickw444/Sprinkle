//
//  ZoneCollectionViewCell.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "Zone.h"

@interface ZoneCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, weak) Zone* zone;

- (IBAction)disclosurePressed:(id)sender;


@end
