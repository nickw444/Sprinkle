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
@property (nonatomic, retain) NSTimer *countdownTimer;
@end

@implementation ZoneCollectionViewCell
@synthesize zone = _zone;

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (void) awakeFromNib {
    UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disclosurePressed:)];
    recogniser.numberOfTapsRequired = 2;
    [self.zoneLabel setUserInteractionEnabled:YES];
    [self.zoneLabel addGestureRecognizer:recogniser];
}

- (void) setZone:(Zone *)zone {
    _zone = zone;
    [self updateState];
}

- (void) updateState {
    self.zoneLabel.text = _zone.label;
    self.segmentController.selectedSegmentIndex = _zone.mode;
    [self updateCountdown];
    
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    if (self.zone.offDate) {
        self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
    }
}


- (IBAction)zoneModeChanged:(id)sender {
    [self.zone setMode:self.segmentController.selectedSegmentIndex WithCompletion:^{
        [self updateState];
    }];
}


- (void) updateCountdown {
    if (self.zone.offDate) {
        self.countdownLabel.text = [self countdownStringUntil:self.zone.offDate];
    }
    else {
        // Timer Expired.
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        self.countdownLabel.text = @"No timer set";
    }
}


- (IBAction)disclosurePressed:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Zone Title" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.zoneLabel.text;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.zone setLabel:alertController.textFields[0].text WithCompletion:^{
            [self updateState];
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Date

- (NSString *) countdownStringUntil:(NSDate *)date {
    NSUInteger timeUntil = (NSUInteger)[date timeIntervalSinceNow];
    NSUInteger seconds = timeUntil % 60;
    NSUInteger minutes = (timeUntil / 60) % 60;
    NSUInteger hours = (timeUntil / 3600);
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (unsigned long)hours, (unsigned long)minutes, (unsigned long)seconds];
}

@end
