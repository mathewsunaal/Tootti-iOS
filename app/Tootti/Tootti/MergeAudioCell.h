//
//  MergeAudioCell.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-18.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
NS_ASSUME_NONNULL_BEGIN
@interface MergeAudioCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *audioNameLabel;
@property (nonatomic, retain) Audio *audio;
@property (nonatomic, retain) AVAudioPlayer *cellPlayer;
@end

NS_ASSUME_NONNULL_END
