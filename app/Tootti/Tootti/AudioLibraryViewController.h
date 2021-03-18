//
//  AudioLibraryViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioLibraryViewController : UIViewController
@property (nonatomic,retain) NSMutableArray *audioRecordings;
@property (weak, nonatomic) IBOutlet UITableView *audioLibTableView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@end

NS_ASSUME_NONNULL_END
