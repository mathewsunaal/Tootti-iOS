//
//  SessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import "RecordingSessionVC.h"
#import "ToottiDefinitions.h"
#import "WaveView.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordingSessionVC () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, retain) NSTimer *recordTimer;
@property (nonatomic) int timerMinutes;
@property (nonatomic) int timerSeconds;
//Waveform property
@property (nonatomic, retain) WaveView *wv;
@property (nonatomic, retain) NSTimer *waveformTimer;

@end

@implementation RecordingSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.players == nil) {
        self.players = [[NSMutableArray alloc] init];
    }
    [self setupViews];
    [self setupAVSessionwithSpeaker:NO];
    self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Hide recording timestamp
    self.recordTimerLabel.hidden = YES;
    //Waveform Start
    //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

// Get path for storage
-(NSString *) getAudioPathwithFormat: (NSString *)audioFormat  {
    // return a formatted string for a file name
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //formatter.dateFormat = @"ddMMMYY_hhmmssa";
    
    return [NSString stringWithFormat:@"%f%@", [[NSDate date] timeIntervalSince1970],audioFormat];
}

-(void) setupAVSessionwithSpeaker:(BOOL) speaker {
    BOOL success; NSError *error;
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [self getAudioPathwithFormat:@".m4a"],
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) {
        NSLog(@"AVAudioSession error setting category:%@",error);
    }
   

    if (speaker) {
        // Set the audioSession override
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
        }
    }

    // Define AVAudioRecorder settings (PCM,44100,2xchannels)
    NSDictionary * recordSettings;
    recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    // Initiate and prepare the recorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSettings error:NULL];
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder prepareToRecord];
    
    //waveform code
    self.wv = [[WaveView alloc] initWithFrame:CGRectMake(10.0f, 100.0f, 300.0f, 100.0f)];
    [self.wv setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1]];
    [self.view addSubview: self.wv];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}


// Button action methods
- (IBAction)recordAudio:(UIButton *)sender {
    NSLog(@"Audio recording pressed");
    NSError *error;
    
    if(self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (!self.audioRecorder.recording) {
        // Activate AVAudioSession
        AVAudioSession *session = [AVAudioSession sharedInstance];
        BOOL success = [session setActive:YES error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error activating: %@",error);
        }
        else {
             NSLog(@"AudioSession active");
        }
        // Start recording
        [self.audioRecorder record];
        // Update UI
        [sender setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
        [self startTimer];
        self.playButton.userInteractionEnabled = NO;
        self.playButton.alpha = 0.5;
        //Waveform Start
        
        //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
    }
    else {
            
        // Stop recording
        // NOTE: we can also implement pause here and stop separately
        [self.audioRecorder stop];
        // Deactivate audio session
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL success = [audioSession setActive:NO error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error deactivating: %@",error);
        }
        else {
             NSLog(@"AudioSession inactive");
        }
        // Update UI
        [sender setBackgroundImage:[UIImage systemImageNamed:@"record.circle"] forState:UIControlStateNormal];
        [self resetTimer];
        self.playButton.userInteractionEnabled = YES;
        self.playButton.alpha = 1.0;
        //Stop Waveform
        //Stop
        if ([self.waveformTimer isValid]){
            NSLog(@"###################################");
            [self.waveformTimer invalidate];
            self.waveformTimer = nil;
        }
    }
}


- (IBAction)playAudio:(UIButton *)sender {
    NSLog(@"Audio playback initiated");
    
//    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"click-track" ofType:@".wav"]];
//    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-1" ofType:@".wav"]];
//    [self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-2" ofType:@".wav"]];
//
//    AVAudioPlayer *lastPlayer = self.players.lastObject;
//    NSTimeInterval timeOffset = lastPlayer.deviceCurrentTime + 0.01;
//    for( AVAudioPlayer *player in self.players) {
//        [player playAtTime:timeOffset];
//    }

    if (!self.audioPlayer.isPlaying){
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:nil];
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer play];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];

    }
    else {
        [self.audioPlayer pause];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    }

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

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(flag) {
        //self.playButton.userInteractionEnabled = YES;
        [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        NSLog(@"Player did finish playing");
    }
}

- (void) startTimer {
    NSLog(@"Start record timer");
    self.recordTimerLabel.hidden = NO;
    self.timerSeconds=0; self.timerMinutes=0;
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(timerDidFire)
                                                      userInfo:nil
                                                       repeats:YES];
    //[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

- (void) resetTimer {
    NSLog(@"Reset record timer");
    [self.recordTimer invalidate];
    self.timerMinutes = 0; self.timerSeconds = 0;
    [self.recordTimerLabel setText:@"00:00"];
    self.recordTimerLabel.hidden = YES;
}

- (void) timerDidFire {
    self.timerSeconds += 1;
    self.timerMinutes = self.timerSeconds/60;
    
    //Format strings for timer
    NSString *formatMinutes,*formatSeconds;
    if(self.timerMinutes < 10) {
        formatMinutes = [NSString stringWithFormat:@"0%d",self.timerMinutes];
    } else {
        formatMinutes = [NSString stringWithFormat:@"%d",self.timerMinutes];
    }
    if(self.timerSeconds%60 < 10) {
        formatSeconds = [NSString stringWithFormat:@"0%d",self.timerSeconds%60];
    } else {
        formatSeconds = [NSString stringWithFormat:@"%d",self.timerSeconds%60];
    }
    //Update timer label
    [self.recordTimerLabel setText:[NSString stringWithFormat:@"%@:%@",formatMinutes,formatSeconds]];
}

#define XMAX    20.0f
- (void) refreshWaveView:(id) arg{
    [self.audioRecorder  updateMeters];
// different conditions
#if 0
    float a = [self.audioRecorder averagePowerForChannel:0];
    float p = [self.audioRecorder  peakPowerForChannel:0];
    NSLog(@"average is %f peak %f", a, p);
    a = (fabsf(a)+XMAX)/XMAX;
    p = (fabsf(p)+XMAX)/XMAX;
    [self.wv addAveragePoint:a*50 andPeakPoint:p*50];
#else
    float aa = pow(10, (0.05 * [self.audioRecorder averagePowerForChannel:0]));
    float pp = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    NSLog(@"average is %f peak %f", aa, pp);
    [self.wv addAveragePoint:aa andPeakPoint:pp];
#endif
}
@end
