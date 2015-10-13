//
//  ZoneCollectionViewCell.h
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import <UIKit/UIKit.h>
@protocol ZoneControllerDelegate <NSObject>
-(void) cell:(id)cell zone:(NSUInteger)zone changedWithValue:(NSUInteger)value;
@end

@interface ZoneCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (nonatomic, weak) id<ZoneControllerDelegate> zoneDelegate;
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic) NSUInteger zoneID;
@property (nonatomic, retain) NSDictionary *state;
- (IBAction)disclosurePressed:(id)sender;


@end
