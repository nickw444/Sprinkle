//
//  ZoneCollectionViewCell.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "ZoneCollectionViewCell.h"

@implementation ZoneCollectionViewCell
- (void) setData:(NSDictionary *)data {
    self.zoneLabel.text = data[@"name"];
}
@end
