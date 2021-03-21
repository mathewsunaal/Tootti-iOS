//
//  SessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import "RecordingSessionVC.h"
#import "AudioLibraryViewController.h"
#import "ToottiDefinitions.h"
#import "WaveView.h"
#import "Audio.h"
#import <AVFoundation/AVFoundation.h>
#import "Session.h"
@interface RecordingSessionVC () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) AVAudioPlayer *clickTrackPlayer;
@property (nonatomic, retain) NSTimer *recordTimer;
@property (nonatomic) int timerMinutes;
@property (nonatomic) int timerSeconds;
@property (nonatomic, retain) NSDictionary *recordingSettings;
//Waveform property
@property (nonatomic, retain) WaveView *wv;
@property (nonatomic, retain) NSTimer *waveformTimer;
@property (weak, nonatomic) IBOutlet UIView *waveFormView;
@property (weak, nonatomic) IBOutlet UILabel *sessionCodeLabel;
@property (nonatomic, readwrite) FIRFirestore *db;

@end
@implementation RecordingSessionVC

Session *cachedSessionRecordingVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.db =  [FIRFirestore firestore];
    // Do any additional setup after loading the view.
    [self setupViews];
    [self setupAVSessionwithSpeaker:NO];
    self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setupSessionStatus];
    [self updateSessionData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSessionInfoFromNotification:) name:@"sessionNotification" object:nil];
    //LISTENING ON FIREBASE
    //test start
    NSString *sessionId = cachedSessionRecordingVC.uid;
    NSLog(@"SessionID: %@", sessionId );
    if (sessionId != 0){
        [[[self.db collectionWithPath:@"session"] documentWithPath: sessionId]
            addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
              if (snapshot == nil) {
                NSLog(@"Error fetching document: %@", error);
                return;
              }
              NSLog(@"Current data: %@", snapshot.data);
            NSDictionary *ds = snapshot.data;
            NSLog(@"Updated data!!!!!!!!!!!!!!!!!!!!!!");
            NSLog(@"%@", [ds class]);
            NSLog(@"%@", [ds[@"hostStartRecording"] class]);
            if ([[ds objectForKey:@"hostStartRecording"]boolValue] == YES){
                // Start recording
                [self recordAudio: nil];
                NSLog(@"HEYYYYYYYY");
                //TODO: Update the recording for host and guest
            }
            }];
    }
    // test ends

}



-(void)updateSessionData {
    if (self.clickTrack != nil) {
        self.clickTrackPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.clickTrack.audioURL] error:nil];
        [self.clickTrackPlayer setDelegate:self];
    }
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Hide recording timestamp
    self.recordTimerLabel.hidden = YES;
    //Waveform Start
    //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

- (void) setupSessionStatus {
    // Notification receiver
    //Check if you are in the session
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 500, 40)];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:statusLabel];
    NSString *message= [NSString stringWithFormat:@"Not in any sessions"];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", cachedSessionRecordingVC.hostUid);
    if (cachedSessionRecordingVC != 0){
        if (currentUserId == cachedSessionRecordingVC.hostUid){
            message = [NSString stringWithFormat:@"Session: %@. UserType: HOST", cachedSessionRecordingVC.sessionName];
        }
        else{
            message = [NSString stringWithFormat:@"Session: %@. UserType: GUEST", cachedSessionRecordingVC.sessionName];
            }
    }
    [statusLabel setText: message];
}


-(BOOL) renameRecordedFile: (NSString *)newFileName {
    NSError * err = NULL;
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [self getAudioPathwithName:newFileName fileFormat:@".wav"],
                               nil];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:nil];
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer play];
    NSURL *newPathURL = [NSURL fileURLWithPathComponents:pathComponents];
    BOOL result;
    result = [[NSFileManager defaultManager] fileExistsAtPath:self.audioRecorder.url.absoluteString];
    NSLog(@"FIle exists at %@? %d",self.audioRecorder.url,result);
//    result = [[NSFileManager defaultManager] moveItemAtPath:self.audioRecorder.url.absoluteString
//                                                        toPath:newPathURL
//                                                         error:&err];
    if(!result) {
        NSLog(@"Error: %@", err);
    }
    
    return result;
}


// Get path for storage
-(NSString *) getAudioPathwithName:(NSString *)name fileFormat: (NSString *)audioFormat  {
    return [NSString stringWithFormat:@"%@%@", name,audioFormat];
}

// Setup AVAudioSession and properties
-(void) setupAVSessionwithSpeaker:(BOOL) speaker {
    BOOL success; NSError *error;
    
    // Setup AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) {
        NSLog(@"AVAudioSession error setting category:%@",error.description);
    }
    if (speaker) {
        // Set the audioSession override
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
        }
    }
    
    // Define AVAudioRecorder settings (PCM,44100,2xchannels)
    self.recordingSettings = [[NSMutableDictionary alloc] init];
    [self.recordingSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [self.recordingSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [self.recordingSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [self.recordingSettings setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [self.recordingSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [self.recordingSettings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    //waveform code
    self.wv = [[WaveView alloc] initWithFrame:CGRectMake(0,0, self.waveFormView.bounds.size.width, self.waveFormView.bounds.size.height/2)];
    [self.wv setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1]];
    [self.waveFormView addSubview: self.wv];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

- (IBAction)testButton:(UIButton *)sender {
    
    //TODO: remove after alertview implemented
    [self renameRecordedFile:@"test-track"];
}

-(void)prepareForNewRecording {
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [self getAudioPathwithName:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]
                                               fileFormat:@".wav"],
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Initiate and prepare the recorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:self.recordingSettings error:NULL];
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder prepareToRecord];
}

- (void)receiveSessionInfoFromNotification:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    cachedSessionRecordingVC = [dict valueForKey:@"currentSession"];
}

// Button action methods
- (IBAction)recordAudio:(UIButton *)sender {
    NSLog(@"Audio recording pressed");
    NSError *error;
    
    if(self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    }
    
    // Start Recording
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
        // Setup recording
        [self prepareForNewRecording];
        // Start recording
        BOOL result = [self.audioRecorder record];
        if(result) {
            NSLog(@"Audio recordring!");
            [self.clickTrackPlayer play];
        }
        // Update UI
        [sender setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
        [self startTimer];
        //Waveform Start
        //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
    }
    // Stop Recording
    else {
        [self.audioRecorder stop];
        [self.clickTrackPlayer stop];
        
        // Deactivate audio session
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL success = [audioSession setActive:NO error:&error];
        if (!success) {
            NSLog(@"AVAudioSession error deactivating: %@",error);
        } else {
             NSLog(@"AudioSession inactive");
        }
        
        // Update UI
        [sender setBackgroundImage:[UIImage systemImageNamed:@"record.circle"] forState:UIControlStateNormal];
        [self resetTimer];
        //Stop Waveform
        if ([self.waveformTimer isValid]){
            NSLog(@"###################################");
            [self.waveformTimer invalidate];
            self.waveformTimer = nil;
        }
        //Show alert to name recording or cancel
        [self showAlertForRecordingName];
    }
}

-(void) updateLocalRecordingsWith:(Audio *)newRecordingAudio {
    // Add new audio object to library VC
    AudioLibraryViewController *libraryVC = self.tabBarController.viewControllers[3];
    if(libraryVC.audioRecordings == nil){
        libraryVC.audioRecordings = [[NSMutableArray alloc] init];
    }
    NSLog(@"New audio recording added: Name = %@, \n URL = %@",newRecordingAudio.audioName,newRecordingAudio.audioURL);
    [libraryVC.audioRecordings addObject:newRecordingAudio];
   
}

-(void) clearRecording {
    
}

-(void) showAlertForRecordingName {
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Recording Done!"
                                                                    message:@"Please name this recording"
                                                             preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons
    UIAlertAction* saveButton = [UIAlertAction
                                actionWithTitle:@"Save"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Update name
                                    Audio *newRecordingAudio = [[Audio alloc] initWithAudioName:alertVC.textFields[0].text
                                                                                       audioURL:self.audioRecorder.url.absoluteString];
                                    [self updateLocalRecordingsWith:newRecordingAudio];
        NSLog(@"%@", cachedSessionRecordingVC.uid);
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]);
        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        NSString *sessionID = cachedSessionRecordingVC.uid;
        [newRecordingAudio uploadAudioSound: userID sessionUid: sessionID];
        
                               }];

    UIAlertAction* cancelButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                    //Clear recording
                                    [self clearRecording];
                               }];

    //Add textfield
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Recording name";
        
    }];

    //Add your buttons to alert controller
    [alertVC addAction:saveButton];
    [alertVC addAction:cancelButton];

    [self presentViewController:alertVC animated:YES completion:nil];
}

//- (void) addPlayerForPath: (NSString *) path {
//    NSError *error;
//    NSURL *url= [NSURL fileURLWithPath:path];
//    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    if(error) {
//        NSLog(@"Error detected for setting up AVPlayer: %@",error.localizedDescription);
//    }
//
//    [player setDelegate:self];
//    [self.players addObject:player];
//
//}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if(flag) {
//        [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
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
    //NSLog(@"average is %f peak %f", a, p);
    a = (fabsf(a)+XMAX)/XMAX;
    p = (fabsf(p)+XMAX)/XMAX;
    [self.wv addAveragePoint:a*50 andPeakPoint:p*50];
#else
    float aa = pow(10, (0.05 * [self.audioRecorder averagePowerForChannel:0]));
    float pp = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    //NSLog(@"average is %f peak %f", aa, pp);
    [self.wv addAveragePoint:aa andPeakPoint:pp];
#endif
}
@end
