//
//  SessionViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import <UIKit/UIKit.h>
#import "Audio.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordingSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *recordTimerLabel;

#pragma mark - refactor
@property (nonatomic, retain) Audio *clickTrack;
@end

NS_ASSUME_NONNULL_END
