//
//  UserStatusCell.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-04-01.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserStatusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) BOOL sessionStatus;
@end

NS_ASSUME_NONNULL_END
