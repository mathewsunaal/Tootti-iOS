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
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ApplicationState.h"

@interface ClickTrackSessionVC () <MPMediaPickerControllerDelegate>
@property (nonatomic,retain) MPMediaPickerController *pickerVC;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;
@property (nonatomic,retain) NSURL *clickTrackURL; // need to connect this to utilities at some point, or leave as URL for optimization
@property (nonatomic, retain) Session *cachedSessionClickTrackVC;

@end

@implementation ClickTrackSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"from here %@", self.cachedSession);
    // Do any additional setup after loading the view.
    self.pickerVC = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [self setupViews];
    [self setupSessionStatus];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.uploadTrackButton];
    [self setupButton:self.playTrackButton];
    [self setupButton:self.confirmTrackButton];
}

- (void)setupSessionStatus {
    self.cachedSessionClickTrackVC = [[ApplicationState sharedInstance] currentSession];
    NSString *session_title= [NSString stringWithFormat:@"No session active"];
    NSString *user_type = [NSString stringWithFormat:@""];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionClickTrackVC.hostUid);
    if (self.cachedSessionClickTrackVC != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionClickTrackVC.sessionName];
        if ([currentUserId isEqual:self.cachedSessionClickTrackVC.hostUid]){
            user_type = [NSString stringWithFormat:@"Host user"];
        } else {
            user_type = [NSString stringWithFormat:@"Guest user"];
        }
    }
    // Update labels
    [self.sessionCodeLabel setText:session_title];
    [self.userTypeLabel setText:user_type];
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
    
    // Test player
    NSLog(@"url of click trac: %@",url.absoluteString);
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.clickTrackAudio = [[Audio alloc] initWithAudioName:@"click-trac-test" audioURL:url.absoluteString];

}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
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
    RecordingSessionVC *recordingVC = self.tabBarController.viewControllers[2];
    recordingVC.clickTrack = self.clickTrackAudio;
    NSLog(@"Click track stored as %@",recordingVC.clickTrack);
    [self.tabBarController setSelectedIndex:2]; // move to record page
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end
