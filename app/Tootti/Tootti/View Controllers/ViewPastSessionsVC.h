//
//  ViewPastSessionsVC.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-05-15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewPastSessionsVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *pastSessionsTableView;
@property (weak, nonatomic) IBOutlet UIButton *joinSessionButton;
@end

NS_ASSUME_NONNULL_END
