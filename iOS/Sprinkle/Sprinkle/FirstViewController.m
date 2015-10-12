//
//  FirstViewController.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "FirstViewController.h"
#import "SprinkleRPCClient.h"
#import "ZoneCollectionViewCell.h"
@interface FirstViewController ()
@property (nonatomic, retain) NSArray *fetchedResults;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fetchedResults = [NSArray array];
    [self refetchStates];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentChanged:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSLog(@"Segment Changed!");
    
    NSString *mode;
    NSNumber *duration;
    NSLog(@"%ld", control.selectedSegmentIndex);
    switch (control.selectedSegmentIndex) {
        case 0:
            mode = @"OFF";
            break;
        case 1:
            mode = @"ON";
            duration = @10;
            break;
        default:
            mode = @"AUTO";
            break;
    }
    NSLog(@"Mode: %@", mode);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"mode": mode, @"circuit": @0}];
    if (duration) {
        [params setValue:duration forKey:@"duration"];
    }

}

#pragma mark - UICollectionView 
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0){
        return [self.fetchedResults count];
    }
    return 0;
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"zoneCell";
    ZoneCollectionViewCell *cell = (ZoneCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.zoneDelegate = self;
    [cell setData:[self.fetchedResults objectAtIndex:[indexPath row]]];
    return cell;
}

#pragma mark - Fetched Results
- (void) refetchStates {
    [[SprinkleRPCClient sharedClient]invokeMethod:@"get_zones" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        self.fetchedResults = [NSArray arrayWithArray:responseObject];
        [self.collectionView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED TO GET ZONES");
    }];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self refetchStates];
}

#pragma mark - Zone Delegate
- (NSArray *)stateMap {
    static NSArray *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @[@"OFF",
                    @"ON",
                    @"AUTO"];
    });
    return states;
}

- (NSArray *)durationMap {
    static NSArray *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @[@(2  * 60),
                   @(5  * 60),
                   @(10 * 60),
                   @(15 * 60),
                   @(30 * 60)];
    });
    return states;
}

- (void) cell:(id)_cell zone:(NSUInteger)zone changedWithValue:(NSUInteger)value {
    ZoneCollectionViewCell *cell = (ZoneCollectionViewCell *)_cell;
    NSLog(@"Zone: %ld changed to %ld", (long)zone, (long)value);
    // Handle telling the Scheduler that this zone turned on.
    // We need to map value to an NSString
    
    NSString *mode = [[self stateMap] objectAtIndex:value];
    NSNumber *duration = [[self durationMap] objectAtIndex:[self.durationPicker selectedSegmentIndex]];
    NSLog(@"Setting zone: %ld to %@ for duration: %@", zone, mode, duration);
    
    // Tell the server
    NSDictionary *params = @{
                            @"mode": mode,
                            @"circuit": [NSNumber numberWithInteger:zone],
                            @"duration": duration,
                            };
    
    [[SprinkleRPCClient sharedClient] invokeMethod:@"set_mode" withParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success");
        [cell setData:responseObject];
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
        [self refetchStates];
    }];
    
}


@end
