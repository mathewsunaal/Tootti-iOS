//
//  MergeSessionVC.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import <UIKit/UIKit.h>
#import "Merge.h"

NS_ASSUME_NONNULL_BEGIN

@interface MergeSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mergeTableView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *sessionCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *mergeShareButton;
@property (weak, nonatomic) IBOutlet UIButton *clickTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@property (nonatomic, retain) NSMutableArray *audioTracks;
@property (nonatomic, retain) NSMutableArray *selectedTracks;
@property (nonatomic)   BOOL isMergePlaying;

@property (retain, nonatomic) Merge *merge;

@end

NS_ASSUME_NONNULL_END
