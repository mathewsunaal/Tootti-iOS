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
@property (weak, nonatomic) IBOutlet UIButton *mergeButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (nonatomic, retain) NSMutableArray *mergeTracks;

@end

NS_ASSUME_NONNULL_END
