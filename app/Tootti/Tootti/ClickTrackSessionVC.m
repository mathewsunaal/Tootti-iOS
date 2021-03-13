//
//  ClickTrackSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "ClickTrackSessionVC.h"
#import "ToottiDefinitions.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ClickTrackSessionVC () <MPMediaPickerControllerDelegate>
@property (nonatomic,retain) MPMediaPickerController *pickerVC;
@property (nonatomic,retain) AVAudioPlayer *audioPlayer;

@property (nonatomic,retain) NSURL *clickTrackURL; // need to connect this to utilities at some point, or leave as URL for optimization
//@property (nonatomic,retain)
@end

@implementation ClickTrackSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    [self setupButton:self.uploadTrackButton];
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
   //[self.pickerVC setModalPresentationCapturesStatusBarAppearance:UIModalPresentationCurrentContext];
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
    [self.audioPlayer play];
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
