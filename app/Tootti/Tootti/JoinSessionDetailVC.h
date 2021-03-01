//
//  JoinSessionViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoinSessionDetailVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UITextField *sessionCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinSessionButton;

@end

NS_ASSUME_NONNULL_END
