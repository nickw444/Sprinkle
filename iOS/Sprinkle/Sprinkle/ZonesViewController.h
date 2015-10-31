//
//  FirstViewController.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
#import "ZoneCollectionViewCell.h"

@interface ZonesViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)refreshButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *durationPicker;


@end

