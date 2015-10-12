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
//    [client invokeMethod:@"get_schedule" success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success!");
//        NSLog(@"%@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Fail :(");
//    }];
//
//    [[SprinkleRPCClient sharedClient] invokeMethod:@"get_mode" withParameters:@{@"circuit": @0} requestId:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", [responseObject objectForKey:@"state"]);
//        NSString *state = [responseObject objectForKey:@"state"];
//        if ([state isEqualToString:@"OFF"]) {
//            self.zone0segment.selectedSegmentIndex = 0;
//        }
//        else if ([state isEqualToString:@"ON"]) {
//            self.zone0segment.selectedSegmentIndex = 1;
//        }
//        else {
//            self.zone0segment.selectedSegmentIndex = 2;
//        }
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Fail");
//    }];
//    
    // Do any additional setup after loading the view, typically from a nib.
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
    
//    [client invokeMethod:@"set_mode" withParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Success");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Failure");
//    }];
    
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
    [cell setData:[self.fetchedResults objectAtIndex:[indexPath row]]];
    return cell;
}

#pragma mark - Fetched Results
- (void) refetchStates {
    [[SprinkleRPCClient sharedClient]invokeMethod:@"get_zones" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.fetchedResults = [NSArray arrayWithArray:responseObject];
        [self.collectionView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED TO GET ZONES");
    }];
}



@end
