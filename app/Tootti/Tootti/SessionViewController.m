//
//  SessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import "SessionViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SessionViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)recordAudio:(UIButton *)sender {
    NSLog(@"Audio recording initiated");
}

- (IBAction)endAudioRecord:(UIButton *)sender {
    NSLog(@"Audio recording ended");
}

- (IBAction)playAudio:(UIButton *)sender {
    NSLog(@"Audio playback initiated");
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
