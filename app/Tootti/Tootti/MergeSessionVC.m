//
//  MergeSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "MergeSessionVC.h"
#import "ToottiDefinitions.h"
#import <AVFoundation/AVFoundation.h>
#import "MOAudioSliderView.h"
#import "Audio.h"
#import "MergeAudioCell.h"
#import "ApplicationState.h"
#import "AppDelegate.h"
#import "Merge.h"
#import "ActivityIndicator.h"

@interface MergeSessionVC () <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,retain) NSMutableArray *players;
@property (nonatomic, retain) Session *cachedSessionMerged;
@property (nonatomic, readwrite) FIRFirestore *db;
@property (nonatomic, retain) NSTimer *playbackTimer;

@end
@implementation MergeSessionVC
//Objects
MOAudioSliderView *_sliderView;
Audio *_audio;

- (void)viewDidLoad {
    self.db =  [FIRFirestore firestore];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.players == nil) {
        self.players = [[NSMutableArray alloc] init];
    }
    if(self.audioTracks == nil) {
        self.audioTracks = [[NSMutableArray alloc] init];
    }
    if(self.selectedTracks == nil) {
        self.selectedTracks = [[NSMutableArray alloc] init];
    }
    
    [self setupViews];
    [self setupSessionStatus];
    NSString *sessionId = self.cachedSessionMerged.uid;
    NSLog(@"SessionID: %@", sessionId );
    if (sessionId != 0){
        [self updateTabStatus:YES];
        //TODO: Need to add auto reload based on new tracks in session
        [[[self.db collectionWithPath:@"session"] documentWithPath: sessionId]
            addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
              if (snapshot == nil) {
                NSLog(@"Error fetching document: %@", error);
                return;
              }
              NSLog(@"Current data: %@", snapshot.data);
              NSLog(@"Updated data!!!!!!!!!!!!!!!!!!!!!!");
            }];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setupSessionStatus];
    [self.mergeTableView reloadData];
    if (self.cachedSessionMerged.uid != 0){
        [self updateTabStatus:YES];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }

}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.mergeButton];
    [self setupButton:self.doneButton];
    // Setup table
    self.mergeTableView.delegate = self;
    self.mergeTableView.dataSource = self;
    self.mergeTableView.layer.cornerRadius = NORMAL_TABLE_CORNER_RADIUS;
    
    [self.tabBarController.navigationItem setHidesBackButton:YES];
}

// Enable or disable tabbar items depending on session status
- (void)updateTabStatus:(BOOL)enabledStatus {
    if(!enabledStatus){
        [self.tabBarController setSelectedIndex:0];// Set tabbar selection to HomeSessionVC
    }
    for(UITabBarItem *tabBarItem in [[self.tabBarController tabBar]items]) {
        if(![tabBarItem.title isEqual:@"Home"]) {
            [tabBarItem setEnabled:enabledStatus];
        }
    }
}

-(void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

- (void)setupSessionStatus {
    self.cachedSessionMerged = [[ApplicationState sharedInstance] currentSession];
    NSString *session_title= [NSString stringWithFormat:@"No session active"];
    NSString *user_type = [NSString stringWithFormat:@""];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionMerged.hostUid);
    if (self.cachedSessionMerged != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionMerged.sessionName];
        if ([currentUserId isEqual:self.cachedSessionMerged.hostUid]){
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

#pragma mark - Audio Players

//- (void) addPlayerForPath: (NSString *) path {
//    NSError *error;
//    NSURL *url= [NSURL fileURLWithPath:path];
//    if(self.players == nil){
//        self.players = [[NSMutableArray alloc] init];
//    }
//    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//    if(error) {
//        NSLog(@"Error detected for setting up AVPlayer: %@",error.localizedDescription);
//    }
//    
//    [player setDelegate:self];
//    [self.players addObject:player];
//}

//- (void)updatePlayers {
//    [self resetPlayers]; // remove all players
//    for(Audio *track in self.audioTracks) {
//        [self addPlayerForPath:track.audioURL]; // add players based on tableview datasource
//    }
//}

//- (void)resetPlayers {
//    [self.players removeAllObjects];
//}

//- (void)pauseAllPlayers {
//    for(Audio *track in self.players) {
//        [track pauseAudio];
//    }
////    for( AVAudioPlayer *player in self.players) {
////        [player stop];
////    }
//}

//- (IBAction)playTrack1:(UIButton *)sender {
//    //[self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-1" ofType:@".wav"]];
//    //AVAudioPlayer *lastPlayer = self.players.lastObject;
//    //[lastPlayer play];
//    //Get the waveform
//    NSString *urlStr =@"https://firebasestorage.googleapis.com/v0/b/ece1778tooti.appspot.com/o/Flute-1.wav?alt=media&token=8a961143-ea85-42ad-bb78-65768e1907e8";
//    [self drawWaveForm: urlStr];
//}
//
//- (IBAction)playTrack2:(UIButton *)sender {
//    //[self addPlayerForPath: [[NSBundle mainBundle] pathForResource:@"Flute-2" ofType:@".wav"]];
//    //AVAudioPlayer *lastPlayer = self.players.lastObject;
//    //[lastPlayer play];
//    NSString *urlStr =@"https://firebasestorage.googleapis.com/v0/b/ece1778tooti.appspot.com/o/Flute-2.wav?alt=media&token=d32be550-1e8a-4a31-871e-b2abb6469d53";
//    [self drawWaveForm: urlStr];
//}


- (void) drawWaveForm:(NSString *) audioURL{
    NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    _audio = [[Audio alloc] initWithAudioName:@"THISSONG" performerUid: performerUid performer:performer audioURL:audioURL];
    NSArray *samplePoints = [_audio convertAVToArr];
    NSURL *playUrl = [NSURL URLWithString:audioURL];
    _sliderView = [[MOAudioSliderView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 85)
                                                    playUrl:playUrl
                                                      points:samplePoints];
    _sliderView.frame = CGRectMake(0, 100, self.view.frame.size.width, 85);
    [self.view addSubview:_sliderView];
}


- (void)playAllTracks {
    if([self.selectedTracks count] == 0){
        NSLog(@"No tracks selected to play!");
        [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        self.isMergePlaying = NO;
        return;
    }
    Audio *lastTrack = [self.selectedTracks lastObject];
    AVAudioPlayer *lastPlayer = lastTrack.player; // get last player added
    NSTimeInterval timeOffset = lastPlayer.deviceCurrentTime + MERGE_PLAYBACK_TIME_BUFFER; // get current device time from lastPlayer
    for(Audio *track in self.selectedTracks) {
        [track stopAudio];
        track.player.currentTime = 0;
        [track playAudioAtTime:timeOffset]; // for playback synchronization
    }
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                          target: self
                                                        selector:@selector(checkPlayback)
                                                        userInfo: nil repeats:YES];
}

- (void)checkPlayback {
    NSLog(@"Playback merge timer fired");
    for (Audio *audio in self.selectedTracks) {
        if(audio.player.isPlaying) {
            return;
        }
    }
    // NO players are playing
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    [self.playbackTimer invalidate];
    self.isMergePlaying = NO;
}

- (void)pauseAllTracks {
    for(Audio *track in self.selectedTracks) {
        [track pauseAudio];
    }
    self.isMergePlaying = NO;
    [self.playbackTimer invalidate];
}

- (void)adjustAllTracks:(float)delta {
    for(Audio *track in self.selectedTracks) {
        [track pauseAudio];
        track.player.currentTime += delta;
    }
}

#pragma mark - IBAction methods

- (IBAction)refresh:(UIButton *)sender {
    NSLog(@"Reresh merge tracks");
    NSLog(@"%@",self.cachedSessionMerged.uid );
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    //TODO: for now, we are clearing all audio tracks in merge
    [self.audioTracks removeAllObjects];
    [self.selectedTracks removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        FIRDocumentReference *docRef = [[self.db collectionWithPath:@"session"] documentWithPath:self.cachedSessionMerged.uid];
        [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
            NSLog(@"%@", snapshot);
          if (snapshot.exists) {
            // Document data may be nil if the document exists but has no keys or values.
            NSLog(@"Document data: %@", snapshot.data);
            // updates the guestpplayerlist
              Session *sn = [[Session alloc] initWithUid: self.cachedSessionMerged.uid sessionName:snapshot.data[@"sessionName"] hostUid:snapshot.data[@"hostUid"] guestPlayerList:snapshot.data[@"guestPlayerList"] clickTrack: snapshot.data[@"clickTrack"] recordedAudioDict:snapshot.data[@"recordedAudioDict"] finalMergedResult: snapshot.data[@"finalMergedResult"] hostStartRecording: snapshot.data[@"hostStartRecording"] currentPlayerList:snapshot.data[@"currentPlayerList"]];
              self.cachedSessionMerged = sn ;
              [[ApplicationState sharedInstance] setCurrentSession:sn] ;
              for (int i=0; i < [ sn.guestPlayerList count]; i++){
                  NSString *fireRefURL = [(NSDictionary *) sn.guestPlayerList[i] objectForKey:@"url"];
                  NSLog(@"fireRefURL: %@", fireRefURL);
                  NSString *currAudioName = [(NSDictionary *) sn.guestPlayerList[i] objectForKey:@"audioName"];
                  NSString *performerUid = [(NSDictionary *) sn.guestPlayerList[i] objectForKey:@"uid"];
                  NSString *performer = [(NSDictionary *) sn.guestPlayerList[i] objectForKey:@"username"];
                  NSURL *url = [NSURL URLWithString:fireRefURL];
                  NSLog(@"The audio name is %@ . URL is %@", currAudioName, fireRefURL) ;
                  Audio *newAudioObj = [[Audio alloc] initWithRemoteAudioName:currAudioName performerUid:performerUid performer:performer audioURL: url];
                    // Update tableview data source
                    [self.audioTracks addObject:newAudioObj];
                    if ([self.audioTracks count] == [sn.guestPlayerList count]){
                        [self.mergeTableView reloadData];
                        [[ActivityIndicator sharedInstance] stop];
                    }
                }
              // Stop spinner if there are no guest tracks in session
              if([sn.guestPlayerList count] == 0) {
                  [[ActivityIndicator sharedInstance] stop];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"No session tracks found"
                                                                                          message:@"Please confirm tracks from the Library page to upload in a session."
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                      UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action) {
                          [self.mergeTableView reloadData];           
                      }];
                      [alertVC addAction:okButton];
                      [self presentViewController:alertVC animated:YES completion:nil];
                  });
              }
              
            } else {
                NSLog(@"Document does not exist");
                [[ActivityIndicator sharedInstance] stop];
            }
        }];
    });
    
}

- (IBAction)mergeTracks:(UIButton *)sender {
    NSLog(@"Merge and render all tracks");
    
//    Audio *s1 = [[Audio alloc] initWithAudioName:@"Flute-1" audioURL:[[NSBundle mainBundle] pathForResource:@"Flute-1" ofType:@".wav"]];
//    Audio *s2 = [[Audio alloc] initWithAudioName:@"Flute-2" audioURL:[[NSBundle mainBundle] pathForResource:@"Flute-2" ofType:@".wav"]];
    if([self.selectedTracks count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"No tracks selected for merge!"
                                                                                message:@"Please select the tracks to merge.\nThe yellow highlight indicates that a track is selected."
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                [self.mergeTableView reloadData];
                                    
            }];
            [alertVC addAction:okButton];
            [self presentViewController:alertVC animated:YES completion:nil];
        });
    }
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.merge = [[Merge alloc] init];
        for(Audio *selectedTrack in self.selectedTracks) {
            [self.merge addAudio:selectedTrack];
        }
        NSString *hostUid = self.cachedSessionMerged.hostUid;
        NSString *hostUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        [self.merge performMerge: ^(BOOL success) {
            if (success){
                NSString *sessionId =  self.cachedSessionMerged.uid;
                NSString *hostId = self.cachedSessionMerged.hostUid;
                [self.merge.mergedTrack uploadTypedAudioSound:hostId sessionUid:sessionId audioType:@"finalMergedResultRef" completionBlock: ^(BOOL success, NSURL *finalDownloadURL) {
                    NSLog(@"!!!!!!!!!!!!!!!");
                    if (success){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Final merged track ready!"
                                                                                                message:@"The final merged track is uploaded and ready to share.\nTap Share to copy the download link!"
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* shareButton = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                // Copy link to clipboard
                                NSLog(@"Share this final merged track at: %@",finalDownloadURL.absoluteString);
                                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                                pasteBoard.string = finalDownloadURL.absoluteString;
                                                    
                            }];
                            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction * action) {
                                //Perform any clear or reset operations for session
                                [self.mergeTableView reloadData];
                            }];
                            [alertVC addAction:shareButton];
                            [alertVC addAction:cancelButton];
                            [self presentViewController:alertVC animated:YES completion:nil];
                        });
                        [[ActivityIndicator sharedInstance] stop];
                    }
                }];
            }
        } hostUid:hostUid hostUsername:hostUsername];
    });
      // Move to confirmation share screen
//    [self performSegueWithIdentifier:@"showShareLink" sender:self];
}

- (IBAction)completeSession:(UIButton *)sender {
    NSLog(@"Session completed");
}

- (IBAction)play:(UIButton *)sender {
    if(!self.isMergePlaying) {
        NSLog(@"Play merged tracks");
        self.isMergePlaying = YES;
        [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
        [self playAllTracks];
    } else {
        NSLog(@"Pause merged tracks");
        self.isMergePlaying = NO;
        [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
        [self pauseAllTracks];
    }
}

- (IBAction)rewind:(UIButton *)sender {
    [self adjustAllTracks:-10];
    [self playAllTracks];
}

- (IBAction)forward:(UIButton *)sender {
    [self adjustAllTracks:+10];
    [self playAllTracks];
}

#pragma mark - TableView methods

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.audioTracks.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MergeAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mergeAudioCell" forIndexPath:indexPath];
    
    Audio* audio = self.audioTracks[indexPath.row];
    cell.audio = audio;
    cell.audioNameLabel.text = audio.audioName;
    cell.cellPlayer = audio.player;
    [cell.cellPlayer setDelegate:cell];
    
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = LOGO_GOLDEN_YELLOW;
    [cell setSelectedBackgroundView:backgroundColorView];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Audio *selectedTrack = self.audioRecordings[indexPath.row];
    //NSLog(@"Selected track:%@",selectedTrack.audioName);
    [self.selectedTracks addObject:self.audioTracks[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Audio *deSelectedTrack = self.audioRecordings[indexPath.row];
    //NSLog(@"deSelected track:%@",deSelectedTrack.audioName);
    [self.selectedTracks removeObject:self.audioTracks[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        Audio *trackToDelete = [self.audioTracks objectAtIndex:indexPath.row];
        if([self.selectedTracks containsObject:trackToDelete]) {
            [self.selectedTracks removeObject:trackToDelete];
        }
        //remove the track
        NSMutableArray *guestPlayerList =[self.cachedSessionMerged.guestPlayerList mutableCopy];
        NSString *sessionId =  self.cachedSessionMerged.uid;
        //NSString *audioFilePath = [NSString stringWithFormat:@"gs://ece1778tooti.appspot.com/%@/%@/%@", performerId, sessionId, trackToDelete.audioName];
        NSMutableDictionary *playerDict = [NSMutableDictionary new];
        playerDict[@"audioName"] = trackToDelete.audioName;
        playerDict[@"uid"] = trackToDelete.performerUid;
        playerDict[@"username"] = trackToDelete.performer;
        playerDict[@"url"] = trackToDelete.audioURL;
        NSString *performerId = trackToDelete.performerUid;
        //TODO: Guestplayerlist here has zero elements, must be an issue with how we update guestplayerlist in cachedsession
        if ([guestPlayerList containsObject:playerDict]){
                [guestPlayerList removeObject:playerDict];
        }
        self.cachedSessionMerged.guestPlayerList = guestPlayerList;
        [[ApplicationState sharedInstance] setCurrentSession:self.cachedSessionMerged];
        [trackToDelete deleteAudioTrack:performerId sessionUid:sessionId guestPlayerList:guestPlayerList completionBlock: ^(BOOL success){
            if (success){
                [self.audioTracks removeObjectAtIndex:indexPath.row];
                //TODO: FIREBASE DELETE function call here
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView reloadData]; // tell table to refresh now
            }
            
        }];
        //[self.audioTracks removeObjectAtIndex:indexPath.row];
        //TODO: FIREBASE DELETE function call here
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadData]; // tell table to refresh now
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
