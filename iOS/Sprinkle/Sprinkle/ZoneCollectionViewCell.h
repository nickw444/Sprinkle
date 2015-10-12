//
//  ZoneCollectionViewCell.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import <UIKit/UIKit.h>

@interface ZoneCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

- (void) setData:(NSDictionary *)data;

@end
