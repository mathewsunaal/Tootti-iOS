//
//  MergeAudioCell.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-18.
//

#import "MergeAudioCell.h"
#import "Audio.h"

@interface MergeAudioCell () <AVAudioPlayerDelegate>

@end

@implementation MergeAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)playAudio:(UIButton *)sender {
    if(self.cellPlayer.isPlaying) {
        [self.cellPlayer stop];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"play.circle"] forState:UIControlStateNormal];
    } else {
        [self.cellPlayer play];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
    }    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.playButton setBackgroundImage:[UIImage systemImageNamed:@"play.circle"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
