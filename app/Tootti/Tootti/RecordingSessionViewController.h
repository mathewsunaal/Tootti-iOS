//
//  SessionViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordingSessionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *recordTimerLabel;

@end

NS_ASSUME_NONNULL_END
