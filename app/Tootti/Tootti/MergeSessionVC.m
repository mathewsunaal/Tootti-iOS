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

@interface MergeSessionVC () <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) BOOL mergeIsPlaying;
@property (nonatomic,retain) NSMutableArray *players;
@end
@implementation MergeSessionVC
//Objects
MOAudioSliderView *_sliderView;
Audio *_audio;

- (void)viewDidLoad {
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
    self.mergeTableView.delegate = self;
    self.mergeTableView.dataSource = self;
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];    
    [self.mergeTableView reloadData];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.mergeButton];
    [self setupButton:self.doneButton];
}

-(void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
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
    _audio = [[Audio alloc] initWithAudioName:@"THISSONG" audioURL:audioURL];
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
}

- (void)pauseAllTracks {
    for(Audio *track in self.selectedTracks) {
        [track pauseAudio];
    }
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
    [self.mergeTableView reloadData];
}

- (IBAction)mergeTracks:(UIButton *)sender {
    NSLog(@"Merge and render all tracks");
}

- (IBAction)completeSession:(UIButton *)sender {
    NSLog(@"Session completed");
}

- (IBAction)play:(UIButton *)sender {
    if(!self.mergeIsPlaying) {
        NSLog(@"Play merged tracks");
        self.mergeIsPlaying = YES;
        [self playAllTracks];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
    } else {
        NSLog(@"Pause merged tracks");
        self.mergeIsPlaying = NO;
        [self pauseAllTracks];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
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
        [self.audioTracks removeObjectAtIndex:indexPath.row];
        //TODO: FIREBASE DELETE function call here
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData]; // tell table to refresh now
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
