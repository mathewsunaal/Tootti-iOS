//
//  ClickTrackSessionVC.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
#import "Session.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClickTrackSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *uploadTrackButton;
@property (nonatomic, retain) Audio *clickTrack;
@property (weak, nonatomic) IBOutlet UIButton *playTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmTrackButton;
@property (weak, nonatomic) IBOutlet UILabel *sessionCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (nonatomic, assign) Session *cachedSession;

@end
NS_ASSUME_NONNULL_END
