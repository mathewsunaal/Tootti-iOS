//
//  ClickTrackSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "ClickTrackSessionVC.h"
#import "RecordingSessionVC.h"
#import "Audio.h"
#import "ToottiDefinitions.h"
#import "ApplicationState.h"
#import "ActivityIndicator.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


@interface ClickTrackSessionVC () <MPMediaPickerControllerDelegate>
@property (nonatomic,retain) MPMediaPickerController *pickerVC;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (nonatomic,retain) NSURL *clickTrackURL; // need to connect this to utilities at some point, or leave as URL for optimization
@property (nonatomic, readwrite) FIRFirestore *db;
@property (nonatomic, retain) Session *cachedSessionClickTrackVC;

@end

@implementation ClickTrackSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];    
    NSLog(@"from here %@", self.cachedSession);
    // Do any additional setup after loading the view.
    self.pickerVC = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [self setupViews];
    self.db =  [FIRFirestore firestore];
    [self setupSessionStatus];
    NSString *sessionId = self.cachedSessionClickTrackVC.uid;
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSLog(@"SessionID: %@", sessionId );
    if (sessionId != 0){
        [self updateTabStatus:YES];
        self.audioPlayer = self.cachedSessionClickTrackVC.clickTrack.player;
        self.clickTrack = self.cachedSessionClickTrackVC.clickTrack;
        [[[self.db collectionWithPath:@"session"] documentWithPath: sessionId]
            addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
              if (snapshot == nil) {
                NSLog(@"Error fetching document: %@", error);
                return;
              }

            NSLog(@"Current data: %@", snapshot.data);
            NSLog(@"Updated data!!!!!!!!!!!!!!!!!!!!!!");
            NSLog(@"%@",snapshot.data[@"clickTrackRef"]);
            NSLog(@"%@", self.cachedSessionClickTrackVC.clickTrack.audioURL);
            if (![snapshot.data[@"clickTrackRef"] isEqualToString:self.cachedSessionClickTrackVC.clickTrack.audioURL]){
                UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:@"Information Updates"
                                                 message:@"A new click track is added"
                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    //update the session
                    NSURL *clURL = [ NSURL URLWithString:snapshot.data[@"clickTrackRef"]];
                    NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
                    NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                    Audio *newClickTrac = [[Audio alloc] initWithRemoteAudioName:@"click-track.wav" performerUid:performerUid performer:performer audioURL:clURL];
                    self.cachedSessionClickTrackVC.clickTrack = newClickTrac;
                    self.cachedSessionClickTrackVC.guestPlayerList = snapshot.data[@"guestPlayerList"];
                    [[ApplicationState sharedInstance] setCurrentSession:self.cachedSessionClickTrackVC] ;
                    //Update local player and clicktrack object
                    self.audioPlayer = self.cachedSessionClickTrackVC.clickTrack.player;
                    self.clickTrack = self.cachedSessionClickTrackVC.clickTrack;
                    // Pass clicktrack to recording session
                    RecordingSessionVC *recordingVC = self.tabBarController.viewControllers[2];
                    recordingVC.clickTrack = self.clickTrack;
                    NSLog(@"Click track stored as %@",recordingVC.clickTrack);
                    }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupSessionStatus];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.uploadTrackButton];
    [self setupButton:self.playTrackButton];
    [self setupButton:self.confirmTrackButton];
    
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

- (void)setupSessionStatus {
    self.cachedSessionClickTrackVC = [[ApplicationState sharedInstance] currentSession];
    NSString *session_title= [NSString stringWithFormat:@"No session active"];
    NSString *user_type = [NSString stringWithFormat:@""];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionClickTrackVC.hostUid);
    if (self.cachedSessionClickTrackVC != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionClickTrackVC.sessionName];
        if ([currentUserId isEqual:self.cachedSessionClickTrackVC.hostUid]){
            user_type = [NSString stringWithFormat:@"(Host)"];
            [self.uploadTrackButton setEnabled:YES];
            [self.uploadTrackButton setHidden:NO];
        } else {
            user_type = [NSString stringWithFormat:@"(Guest)"];
            [self.uploadTrackButton setEnabled:NO];
            [self.uploadTrackButton setHidden:YES];
            //TODO: Need to load clicktrack from session in Firebase, consult with Han
            //self.clickTrack = self.cachedSessionClickTrackVC.clickTrack;
        }
    }
    // Update labels
    [self.sessionCodeLabel setText:session_title];
    [self.userTypeLabel setText:[NSString stringWithFormat:@"%@ %@",username,user_type]];
    [self.sessionCodeLabel setTextColor:LOGO_GOLDEN_YELLOW];
    [self.userTypeLabel setTextColor:[UIColor whiteColor]];
}

-(void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

#pragma mark - Button Action methods

- (IBAction)uploadClickTrack:(UIButton *)sender {
    NSLog(@"Button Pressed");
   
   self.pickerVC.allowsPickingMultipleItems = NO;
   self.pickerVC.popoverPresentationController.sourceView = self.uploadTrackButton;
   self.pickerVC.delegate = self;
   [self presentViewController:self.pickerVC animated:YES completion:nil];
}

#pragma mark - MPMediaPickerControllerDelegate methods


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSLog(@"Did pick audio track: %@",mediaItemCollection);
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *url = [item  valueForProperty:MPMediaItemPropertyAssetURL];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
    //TODO: Update to have clicktrack from session
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSLog(@"url of click trac: %@",url.absoluteString);
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            if (mediaItemCollection) {
                if (! item) {
                    return;
                }
            AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
            NSLog (@"Core Audio %@ directly open library URL %@",
                   coreAudioCanOpenURL (url) ? @"can" : @"cannot",
                   url);
            
            NSLog (@"compatible presets for songAsset: %@",
                   [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);
            /* approach 1: export just the song itself
             */
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                              initWithAsset: songAsset
                                              presetName: AVAssetExportPresetAppleM4A];
            NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
            //exporter.outputFileType = @".m4a";
            [exporter setOutputFileType:@"com.apple.m4a-audio"];
            // exporter.outputFileType=@"com.apple.quicktime-movie";
            NSArray *docpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *tempPath = [docpaths objectAtIndex:0];
            NSString *exportFile = [tempPath stringByAppendingPathComponent: @"exported.m4a"];
            
            myDeleteFile(exportFile);
            NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
            exporter.outputURL = exportURL;
            // do the export
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                AVAssetExportSessionStatus exportStatus = exporter.status;
                switch (exportStatus) {
                    case AVAssetExportSessionStatusFailed: {
                        // log error to text view
                        NSError *exportError = exporter.error;
                        NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                        //errorView.text = exportError ? [exportError description] : @"Unknown failure";
                       // errorView.hidden = NO;
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted: {
                        NSLog (@"AVAssetExportSessionStatusCompleted");
                       // fileNameLabel.text = [exporter.outputURL lastPathComponent];
                        // set up AVPlayer
                        //[self setUpAVPlayerForURL: exporter.outputURL];
                       // [self enablePCMConversionIfCoreAudioCanOpenURL: exporter.outputURL];
                        break;
                    }
                    case AVAssetExportSessionStatusUnknown: { NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
                    case AVAssetExportSessionStatusExporting: { NSLog (@"AVAssetExportSessionStatusExporting"); break;}
                    case AVAssetExportSessionStatusCancelled: { NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
                    case AVAssetExportSessionStatusWaiting: { NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
                    default: { NSLog (@"didn't get export status"); break;}
                }
            }];
            NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
            NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
            self.clickTrack = [[Audio alloc] initWithAudioName:@"click-trac-test" performerUid:performerUid performer:performer  audioURL: [exportURL absoluteString]];
            }
        });
}


- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark core audio test

BOOL coreAudioCanOpenURL (NSURL* url){

    OSStatus openErr = noErr;
    AudioFileID audioFile = NULL;
    openErr = AudioFileOpenURL((__bridge CFURLRef) url,
                               kAudioFileReadPermission ,
                               0,
                               &audioFile);
    if (audioFile) {
        AudioFileClose (audioFile);
    }
    return openErr ? NO : YES;
}

void myDeleteFile (NSString* path){

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *deleteErr = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&deleteErr];
        if (deleteErr) {
            NSLog (@"Can't delete %@: %@", path, deleteErr);
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction)playTrack:(UIButton *)sender {
    if(self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        [self.playTrackButton setTitle:@"Play track" forState:UIControlStateNormal];
    } else {
        self.audioPlayer.currentTime = 0;
        [self.audioPlayer play];
        [self.playTrackButton setTitle:@"Stop playback" forState:UIControlStateNormal];
    }
}
    
- (IBAction)confirmTrack:(id)sender {
    //Start uploading the clickTrack
    //TODO: START PROGRESS VIEW HERE
    NSString *sessionId =  self.cachedSessionClickTrackVC.uid;
    NSString *hostId = self.cachedSessionClickTrackVC.hostUid;
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    // TODO: Host only allowed to share and upload click tracks now; this may change with "OFFLINE" mode
    if([currentUserId isEqual:hostId]) {
        [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.clickTrack uploadTypedAudioSound:hostId sessionUid:sessionId audioType:@"clickTrackRef" completionBlock: ^(BOOL success, NSURL *downloadURL) {
               NSLog(@"!!!!!!!!!!!!!!!");
               if (success){
                   NSLog(@"Successfully upload the clicktrack");
                   [[ActivityIndicator sharedInstance] stop];
                   [self.tabBarController setSelectedIndex:2]; // move to record page
               } else {
                   NSLog(@"Failed to upload the clicktrack");
                   [[ActivityIndicator sharedInstance] stop];
               }
            }];
        });
    } else {
        //TODO: Handle for guest
        [[ActivityIndicator sharedInstance] stop];
        [self.tabBarController setSelectedIndex:2]; // move to record page
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end
