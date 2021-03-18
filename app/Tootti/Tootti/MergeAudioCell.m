//
//  MergeAudioCell.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-18.
//

#import "MergeAudioCell.h"
#import "Audio.h"

@implementation MergeAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)playAudio:(UIButton *)sender {
    if(self.audio.player.isPlaying) {
        [self.audio stopAudio];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"play.circle"] forState:UIControlStateNormal];
    } else {
        [self.audio playAudio];
        [sender setBackgroundImage:[UIImage systemImageNamed:@"stop.circle"] forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
