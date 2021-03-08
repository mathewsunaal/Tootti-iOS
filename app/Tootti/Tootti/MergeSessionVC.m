//
//  MergeSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "MergeSessionVC.h"
#import "ToottiDefinitions.h"
#import <AVFoundation/AVFoundation.h>

@interface MergeSessionVC () <AVAudioPlayerDelegate>

@property(nonatomic,retain) NSMutableArray *players;

@end

@implementation MergeSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.players == nil) {
        self.players = [[NSMutableArray alloc] init];
    }
    [self setupViews];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
}

- (void) addPlayerForPath: (NSString *) path {
    NSError *error;
    NSURL *url= [NSURL fileURLWithPath:path];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error) {
        NSLog(@"Error detected for setting up AVPlayer: %@",error.localizedDescription);
    }
    
    [player setDelegate:self];
    [self.players addObject:player];
    
}
- (IBAction)resetPlayers:(UIButton *)sender {
    [self.players removeAllObjects];
}

- (IBAction)stopAllPlayers:(UIButton *)sender {
    
    for( AVAudioPlayer *player in self.players) {
        [player stop];
    }
    
}

- (IBAction)playTrack1:(UIButton *)sender {
    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-1" ofType:@".wav"]];
    
    AVAudioPlayer *lastPlayer = self.players.lastObject;
    [lastPlayer play];
}

- (IBAction)playTrack2:(UIButton *)sender {
    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-2" ofType:@".wav"]];
    
    AVAudioPlayer *lastPlayer = self.players.lastObject;
    [lastPlayer play];
}

- (IBAction)playMergedTracks:(UIButton *)sender {
    [self.players removeAllObjects];
    
    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"click-track" ofType:@".wav"]];
    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-1" ofType:@".wav"]];
    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-2" ofType:@".wav"]];
    
    AVAudioPlayer *lastPlayer = self.players.lastObject;
    NSTimeInterval timeOffset = lastPlayer.deviceCurrentTime + 0.01;
    for( AVAudioPlayer *player in self.players) {
        [player playAtTime:timeOffset];
    }
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
