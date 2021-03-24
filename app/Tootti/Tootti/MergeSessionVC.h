//
//  MergeSessionVC.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MergeSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mergeTableView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *sessionCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *mergeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@property (nonatomic, retain) NSMutableArray *audioTracks;
@property (nonatomic, retain) NSMutableArray *selectedTracks;
@property (nonatomic)   BOOL isMergePlaying;

@end

NS_ASSUME_NONNULL_END
