//
//  FirstViewController.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "ZonesViewController.h"
#import "SprinkleRPCClient.h"
#import "ZoneCollectionViewCell.h"
#import "ZoneModel.h"

@interface ZonesViewController ()
@property (nonatomic, retain) NSArray *fetchedResults;
@end

@implementation ZonesViewController

-(void) dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ZoneModel sharedModel] reloadZones];

//    self.fetchedResults = [NSArray array];
//    [self refetchStates];
    self.durationPicker.selectedSegmentIndex = [self lastDurationIndex];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataChanged) name:@"ZoneModel-Updated" object:nil];
    
}

-(void) dataChanged {
    NSLog(@"Data Changed");
    [self.collectionView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    UIEdgeInsets scrollInsets = self.collectionView.scrollIndicatorInsets;
    scrollInsets.bottom = 0;
    self.collectionView.scrollIndicatorInsets = scrollInsets;
    
    scrollInsets = self.collectionView.contentInset;
    scrollInsets.bottom = 0;
    self.collectionView.contentInset = scrollInsets;
    // Set Scroll insets for the picker view;
    
    
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
    NSLog(@"%ld", (unsigned long)control.selectedSegmentIndex);
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
        return [[[ZoneModel sharedModel]zones] count];
    }
    return 0;
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"zoneCell";
    ZoneCollectionViewCell *cell = (ZoneCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.presentingViewController = self;
    cell.zone =[[[ZoneModel sharedModel]zones]  objectAtIndex:[indexPath row]];
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

#pragma mark - Actions
- (IBAction)durationSelectionChanged:(id)sender {
    [self setLastDurationIndex:self.durationPicker.selectedSegmentIndex];
}


#pragma mark - NSUD
#define NSUD_LAST_DURATION @"LAST_DURATION_INDEX"
- (NSUInteger) lastDurationIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:NSUD_LAST_DURATION];
}
- (void) setLastDurationIndex:(NSUInteger)index {
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:NSUD_LAST_DURATION];
}




@end
