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
#import "ApplicationState.h"
#import "UserStatusCell.h"
#import "Tootti-Swift.h"

@interface RecordingSessionVC () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *recordTimer;
@property (nonatomic) int timerMinutes;
@property (nonatomic) int timerSeconds;
@property (nonatomic, retain) NSDictionary *recordingSettings;
@property (nonatomic, retain) Session *cachedSessionRecordingVC;
//Waveform property
@property (nonatomic, retain) WaveView *wv;
@property (nonatomic, retain) NSTimer *waveformTimer;
@property (weak, nonatomic) IBOutlet UIView *waveFormView;
@property (weak, nonatomic) IBOutlet UILabel *sessionCodeLabel;
@property (nonatomic, readwrite) FIRFirestore *db;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end
@implementation RecordingSessionVC

//Session *cachedSessionRecordingVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.db =  [FIRFirestore firestore];
    // Do any additional setup after loading the view.
    [self setupViews];
    [self setupAVSessionwithSpeaker:NO];
    [self setupSessionStatus];
    //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
    
    //LISTENING ON FIREBASE
    NSString *sessionId = self.cachedSessionRecordingVC.uid;
    NSLog(@"SessionID: %@", sessionId );
    if (sessionId != 0){
        [self updateTabStatus:YES];
        [[[self.db collectionWithPath:@"session"] documentWithPath: sessionId]
            addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
              if (snapshot == nil) {
                NSLog(@"Error fetching document: %@", error);
                return;
              }
            NSLog(@"Current data: %@", snapshot.data);
            NSDictionary *ds = snapshot.data;
            NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
            // Step 1: Check if the recording started. Handle live recording for guest user
            if(![currentUserId isEqual:self.cachedSessionRecordingVC.hostUid]) {
                if ([[ds objectForKey:@"hostStartRecording"]boolValue] == YES) {
                    [self.tabBarController setSelectedIndex:2]; // Force guest user to the recording screen
                    [self startRecording: nil];
                    NSLog(@"Host started recording");
                } else {
                    [self endRecording:nil];
                }
            }
            // Step 2: Assign the player status list
            self.cachedSessionRecordingVC.currentPlayerList = snapshot.data[@"currentPlayerList"];
            [self.usersTableView reloadData];
            // Step 3: Check if the guest player list is updated. Update click track data if different from current cached session
            if (![snapshot.data[@"clickTrackRef"] isEqualToString:self.cachedSessionRecordingVC.clickTrack.audioURL] ){
            //    UIAlertController * alert = [UIAlertController
            //                    alertControllerWithTitle:@"Information Updates"
            //                                     message:@"A new click track is added"
            //                              preferredStyle:UIAlertControllerStyleAlert];
            //    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    NSURL *clURL = [ NSURL URLWithString:snapshot.data[@"clickTrackRef"]];
                    Audio *newClickTrac = [[Audio alloc] initWithRemoteAudioName:@"click-track.wav" performerUid: self.cachedSessionRecordingVC.hostUid performer: @"ClickTrack" audioURL:clURL ];
                    self.cachedSessionRecordingVC.clickTrack = newClickTrac;
                    self.cachedSessionRecordingVC.guestPlayerList = snapshot.data[@"guestPlayerList"];
                    //TODO: Already doing this in ClicktracVC. In the future, we should upate one single session instance for all VCs i the application
                    [[ApplicationState sharedInstance] setCurrentSession:self.cachedSessionRecordingVC];
                    // Update local variables
                    self.clickTrack = self.cachedSessionRecordingVC.clickTrack; // TODO: Handle the closing of AVAudiosession etc to avoid unexpected errors
             //   }];
             //   [alert addAction:okAction];
             //   [self presentViewController:alert animated:YES completion:nil];
            }
    }];
    } else {
        [self updateTabStatus:NO]; // Lock other tabBarItems and navigate to home
    }
    
    // Setup notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBackgroundStatus:)
                                                 name:UISceneWillDeactivateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleForegroundStatus:)
                                                 name:UISceneDidActivateNotification
                                               object:nil];


}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setupSessionStatus];
    if(![self.cachedSessionRecordingVC.clickTrack isEqual:self.clickTrack] && self.cachedSessionRecordingVC.clickTrack!=nil) {
        self.clickTrack = self.cachedSessionRecordingVC.clickTrack;
    }
    if (self.cachedSessionRecordingVC.uid != 0){
        [self updateTabStatus:YES];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Hide recording timestamp
    self.recordTimerLabel.hidden = YES;
    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    self.usersTableView.layer.cornerRadius = NORMAL_TABLE_CORNER_RADIUS;
    self.waveFormView.layer.cornerRadius = NORMAL_TABLE_CORNER_RADIUS;
    
    [self.tabBarController.navigationItem setHidesBackButton:YES];
    
    //Waveform Start
    //self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

// Enable or disable tabbar items depending on session status
- (void)updateTabStatus:(BOOL)enabled {
    if(!enabled){
        [self.tabBarController setSelectedIndex:0];// Set tabbar selection to HomeSessionVC
    }
    for(UITabBarItem *tabBarItem in [[self.tabBarController tabBar]items]) {
        if(![tabBarItem.title isEqual:@"Home"]) {
            [tabBarItem setEnabled:enabled];
        }
    }
}

- (void)setTabBarStatusEnabled:(BOOL) enabled {
    for(UITabBarItem *tabBarItem in [[self.tabBarController tabBar]items]) {
        [tabBarItem setEnabled:enabled];
    }
}

- (void)setupSessionStatus {
    self.cachedSessionRecordingVC = [[ApplicationState sharedInstance] currentSession];
    NSString *session_title= [NSString stringWithFormat:@"No session active"];
    NSString *user_type = [NSString stringWithFormat:@""];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionRecordingVC.hostUid);
    if (self.cachedSessionRecordingVC != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionRecordingVC.sessionName];
        if ([currentUserId isEqual:self.cachedSessionRecordingVC.hostUid]){
            user_type = [NSString stringWithFormat:@"(Host)"];
        } else {
            user_type = [NSString stringWithFormat:@"(Guest)"];
        }
    }
    // Update labels
    [self.sessionCodeLabel setText:session_title];
    [self.userTypeLabel setText:[NSString stringWithFormat:@"%@ %@",username,user_type]];
    [self.sessionCodeLabel setTextColor:LOGO_GOLDEN_YELLOW];
    [self.userTypeLabel setTextColor:[UIColor whiteColor]];
}

// Get path for storage
-(NSString *) getAudioPathwithName:(NSString *)name fileFormat: (NSString *)audioFormat  {
    return [NSString stringWithFormat:@"%@%@", name,audioFormat];
}

// Setup AVAudioSession and properties
-(void) setupAVSessionwithSpeaker:(BOOL) speaker {
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL categroySuccess = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionAllowBluetoothA2DP
                                           error:&error];
    if(!categroySuccess) {
        NSLog(@"AVAudioSession error setting category:%@",error.description);
    }
    
    // TODO: Assuming that the port[0] is always the built-in micrphone port, might need a smarter way to check this
    AVAudioSessionPortDescription *portPhoneMic = session.availableInputs[0]; // Grab audio port for built-in microphone
    [session setPreferredInput:portPhoneMic error:nil]; // set preffered audio input port
    
    // Set the dataSource for the phoneMicPort to be "Bottom" microhpone
    NSLog(@"Data sources for current port:%@",session.inputDataSources);
    for (AVAudioSessionDataSourceDescription *source in portPhoneMic.dataSources) {
        if ([source.dataSourceName isEqualToString:@"Bottom"]) {
            [session setInputDataSource:source error:nil];
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
    
    // Update audio latency
    [self.cachedSessionRecordingVC updateAudioLatency];
     
    //waveform initial image
    self.waveFormView.backgroundColor =  [UIColor grayColor];
}

- (void) startWaveform{
    //waveform code
    self.wv = [[WaveView alloc] initWithFrame:CGRectMake(0,0, (float)self.waveFormView.bounds.size.width, (float)self.waveFormView.bounds.size.height)];
    [self.waveFormView addSubview: self.wv];
    [self.waveFormView reloadInputViews];
    //TODO: attach this to waveform timer
    self.waveformTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(refreshWaveView:) userInfo:nil repeats:YES];
}

- (void) resetWaveform {
    [self.waveformTimer invalidate];
    self.waveformTimer = nil;
    [self.wv removeFromSuperview];
    [self.waveFormView reloadInputViews];
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

/*
- (void)receiveSessionInfoFromNotification:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    //cachedSessionRecordingVC = [dict valueForKey:@"currentSession"];
}
*/

#pragma  mark - Button methods
- (IBAction)recordAudio:(UIButton *)sender {
    NSLog(@"Audio recording pressed");
    
    // Stop current playback
    if(self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    }
    
    // Handle recording action
    if(!self.audioRecorder.recording) {
        [self startRecording:sender];
    } else { // Stop Recording
        [self endRecording:sender];
    }
}


- (IBAction)updateUsersStatus:(UISwitch *)sender {
    if(sender.on) {
        NSLog(@"User status changed to READY");
        [self.statusLabel setText:@"Ready"];
        // Update user status in Firebase
        [self.cachedSessionRecordingVC updateSessionActivityStatus:YES
                                                               uid:[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]
                                                   completionBlock:nil];
        
    } else {
        NSLog(@"User status changed to STANDBY");
        [self.statusLabel setText:@"Standby"];
        // Update user status in Firebase
        [self.cachedSessionRecordingVC updateSessionActivityStatus:NO
                                                               uid:[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]
                                                   completionBlock:nil];
        
    }
}

#pragma mark - Recording Methods
-(void)startRecording:(UIButton *)sender {
    NSError *error;
    [self startWaveform];
    // Activate AVAudioSession
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL categroySuccess = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                                     withOptions:AVAudioSessionCategoryOptionAllowBluetoothA2DP
                                           error:&error];
    if(!categroySuccess) {
        NSLog(@"AVAudioSession error setting category:%@",error.description);
    }
    // TODO: Assuming that the port[0] is always the built-in micrphone port, might need a smarter way to check this
    AVAudioSessionPortDescription *portPhoneMic = session.availableInputs[0]; // Grab audio port for built-in microphone
    [session setPreferredInput:portPhoneMic error:nil]; // set preffered audio input port
    
    // Set the dataSource for the phoneMicPort to be "Bottom" microhpone
    NSLog(@"Data sources for current port:%@",session.inputDataSources);
    for (AVAudioSessionDataSourceDescription *source in portPhoneMic.dataSources) {
        if ([source.dataSourceName isEqualToString:@"Bottom"]) {
            [session setInputDataSource:source error:nil];
        }
    }

    BOOL activationSucces = [session setActive:YES error:&error];
    if (!activationSucces) {
        NSLog(@"AVAudioSession error activating: %@",error);
        return;
    }
    

    // Start recording
    [self prepareForNewRecording];

    // Setup clictrack
    self.clickTrack.player.currentTime = 0;
    [self.clickTrack playAudio];
    NSLog(@"Starting recording");
    BOOL result = [self.audioRecorder record];
    if(result) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; // Disable idle timer so screen doesn't dim or lock when recording
        [self startTimer];
        //Update Firestore hostStartRecording field
        NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        if([currentUserId isEqual:self.cachedSessionRecordingVC.hostUid]){
            [self.cachedSessionRecordingVC sessionRecordingStatusUpdate:TRUE];
        }
        // Update UI
        [self.recordButton setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
        [self setTabBarStatusEnabled:NO];
        
        // Update audio latency
        [self.cachedSessionRecordingVC updateAudioLatency];
        //NSLog(@"%@", [session outputDataSource]);
        //NSLog(@"Input latency is = %f, Ouptut Latency = %f, IOBuffer = %f",[session inputLatency],[session outputLatency],[session IOBufferDuration]);
        
    } else {
        NSLog(@"Recording failed to start");
        [self.clickTrack stopAudio];
        return;
    }
    
    
}
-(void)endRecording:(UIButton *)sender {
    NSError *error;
    [self resetTimer];
    if(self.audioRecorder.isRecording == NO){
        NSLog(@"No recording detected!!");
        return;
    }
    [self.audioRecorder stop];
    [self.clickTrack stopAudio];
    // Deactivate audio session
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    // Disable the idletimer to allow screen to dim if needed
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    //Update Firestore hostStartRecording field
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    if([currentUserId isEqual:self.cachedSessionRecordingVC.hostUid]){
        [self.cachedSessionRecordingVC sessionRecordingStatusUpdate:FALSE];
    }
    // Update UI
    [self.recordButton setBackgroundImage:[UIImage systemImageNamed:@"record.circle"] forState:UIControlStateNormal];
    [self setTabBarStatusEnabled:YES];
    //Stop Waveform[self setTabBarStatusEnabled:NO];
//        if ([self.waveformTimer isValid]){
//            NSLog(@"###################################");
//            [self.waveformTimer invalidate];
//            self.waveformTimer = nil;
//        }
    [self resetWaveform];
    //Show alert to name recording or cancel
    [self showAlertForRecordingName];
}

-(void) updateLocalRecordingsWith:(Audio *)newRecordingAudio {
    // Add new audio object to library VC
    AudioLibraryViewController *libraryVC = self.tabBarController.viewControllers[3];
    if(libraryVC.audioRecordings == nil){
        libraryVC.audioRecordings = [[NSMutableArray alloc] init];
    }
    NSLog(@"New audio recording added: Name = %@, \n URL = %@",newRecordingAudio.audioName,newRecordingAudio.audioURL);
    [libraryVC.audioRecordings addObject:newRecordingAudio];
    // Crop audio file asynchronously
    [newRecordingAudio cropAudioWithStartTime:self.cachedSessionRecordingVC.audioLatency];
   
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
        NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                                    Audio *newRecordingAudio = [[Audio alloc] initWithAudioName:alertVC.textFields[0].text
                                                                performerUid:performerUid performer:performer
                                                                                       audioURL:self.audioRecorder.url.absoluteString];
                                    [self updateLocalRecordingsWith:newRecordingAudio];
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

#pragma mark - Timer Methods

- (void) startTimer {
    if(self.recordTimer)
        return;
    
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
    self.recordTimer = nil;
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

#pragma mark - waveview methods

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


#pragma mark - UITableView Delegate methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //TODO: Return username of all active users from local array that is updated from Firebase whenever there is a change of status
    
    UserStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userStatusCell" forIndexPath:indexPath];
    NSDictionary *userInSession = self.cachedSessionRecordingVC.currentPlayerList[indexPath.row];
    [cell.usernameLabel setText:[userInSession objectForKey:@"username"]];
    BOOL sessionStatus = [[userInSession objectForKey:@"status"] boolValue];
    NSLog(@"Session status:%d",sessionStatus);
    [cell toggleSessionStatus:sessionStatus];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //TODO: Return users where user status is "ACTIVE" from Firebase, maybe we store this locally and referesh whenever there is a change?
    return self.cachedSessionRecordingVC.currentPlayerList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - NSNotification Methods

-(void)handleBackgroundStatus:(NSNotification *)notification {
    NSLog(@"Recording Session: Scene will deactivate");
    [self.cachedSessionRecordingVC updateCurrentPlayerListWithActivity:NO
                                 username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                      uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                          completionBlock:^(BOOL success) {
                                if(success) {
                                    NSLog(@"User removed from session activity!");
                                } else {
                                    NSLog(@"Failed to update Firebase-currentPlayerList!");
                                }
                        }];
}

-(void)handleForegroundStatus:(NSNotification *)notification {
    NSLog(@"Recording Session: Scene did activate");
    [self.cachedSessionRecordingVC updateCurrentPlayerListWithActivity:YES
                                 username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                      uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                          completionBlock:^(BOOL success) {
                                if(success) {
                                    NSLog(@"User added back to session activity!");
                                } else {
                                    NSLog(@"Failed to update Firebase-currentPlayerList!");
                                }
                        }];
    
    [self updateUsersStatus:self.statusSwitch];
}


@end
