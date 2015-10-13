//
//  ZoneCollectionViewCell.m
//  Sprinkle
//
//  Created by Nicholas Whyte on 12/10/2015.
//
//

#import "ZoneCollectionViewCell.h"
#import "SprinkleRPCClient.h"
@interface ZoneCollectionViewCell ()
@property (nonatomic, retain) NSDate *offDate;
@property (nonatomic, retain) NSTimer *countdownTimer;
@end

@implementation ZoneCollectionViewCell
@synthesize state = _state;

- (NSDictionary *)stateIndexMap {
    static NSDictionary *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @{@"OFF": @0,
                   @"ON": @1,
                   @"AUTO": @2};
    });
    return states;
}

- (id) init {
    if (self = [super init]) {
        self.state = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) awakeFromNib {
    _state = [NSMutableDictionary dictionary];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:0 context:nil];
    
    UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosurePressed:)];
    recogniser.numberOfTapsRequired = 2;
    [self.zoneLabel setUserInteractionEnabled:YES];
    [self.zoneLabel addGestureRecognizer:recogniser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        [self stateChanged];
    }
    
}

- (void) setState:(NSDictionary *)state {
    NSLog(@"State was set for circuit: %@", state[@"circuit"]);
    _state = [NSMutableDictionary dictionaryWithDictionary:state];
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    
    NSString *offAt = _state[@"off_at"];
    if (![offAt isEqual:[NSNull null]]) {
        self.offDate = [self dateFromIsoString:offAt];
        self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    }
    else {
        self.offDate = nil;
    }
    [self updateCountdown];
    [self stateChanged];
}


- (void) stateChanged {
    self.zoneLabel.text = _state[@"name"];
    self.zoneID = [_state[@"circuit"] integerValue];
    self.segmentController.selectedSegmentIndex = [[[self stateIndexMap] objectForKey:_state[@"mode"]] integerValue];
    if ([_state objectForKey:@"countdownLabel"]) {
        self.countdownLabel.text = _state[@"countdownLabel"];
    }
}


- (IBAction)zoneModeChanged:(id)sender {
    // Tell the server the mode changed.
    [self.zoneDelegate cell:self zone:self.zoneID changedWithValue:self.segmentController.selectedSegmentIndex];
}

- (void) refetchZone {
    // Go and fetch info for this zone only.
    // Do FLUX model.
}

- (void) updateCountdown {
    if (self.offDate) {
        [self.state setValue:[self countdownStringUntil:self.offDate] forKey:@"countdownLabel"];
        
        if ([self.offDate timeIntervalSinceNow] <= 0) {
            [self.countdownTimer invalidate];
            self.countdownTimer = nil;
            self.offDate = nil;
            [self.state setValue:@"No Timer Set" forKey:@"countdownLabel"];
        }
    }
    else {
       [self.state setValue:@"No Timer Set" forKey:@"countdownLabel"];
    }
    [self stateChanged];
}


- (IBAction)disclosurePressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Zone Title" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.zoneLabel.text;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.state setValue:alertController.textFields[0].text forKey:@"name"];
        [self stateChanged];

        [[SprinkleRPCClient sharedClient] invokeMethod:@"set_zone"
                                        withParameters:@{
                                                         @"circuit": [NSNumber numberWithInteger:self.zoneID],
                                                         @"name": alertController.textFields[0].text
                                                        }
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   [self setState:responseObject];
                                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   NSLog(@"Failure");
                                               }];
        
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    
    [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Date

- (NSDate *) dateFromIsoString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (NSString *) countdownStringUntil:(NSDate *)date {
    NSUInteger timeUntil = (NSUInteger)[date timeIntervalSinceNow];
    NSUInteger seconds = timeUntil % 60;
    NSUInteger minutes = (timeUntil / 60) % 60;
    NSUInteger hours = (timeUntil / 3600);
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
}

@end
