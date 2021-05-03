//
//  AudioCell.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-18.
//

#import "AudioCell.h"

@interface AudioCell () <AVAudioPlayerDelegate>

@end

@implementation AudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)playAudio:(UIButton *)sender {
    if(self.cellPlayer.isPlaying) {
        [self.cellPlayer stop];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"play.circle"] forState:UIControlStateNormal];
    } else {
        //This ensures playback on silent mode too (music track playback)
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker
                                               error:nil];
        self.cellPlayer.currentTime = 0;
        [self.cellPlayer play];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
    }
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.cellPlayer.currentTime = 0;
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.circle"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
