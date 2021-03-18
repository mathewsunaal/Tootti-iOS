//
//  ClickTrackSessionVC.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import <UIKit/UIKit.h>
#import "Audio.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClickTrackSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *uploadTrackButton;
@property (nonatomic, retain) Audio *clickTrackAudio;
@property (weak, nonatomic) IBOutlet UIButton *playTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmTrackButton;

@end

NS_ASSUME_NONNULL_END
