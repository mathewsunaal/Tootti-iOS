//
//  HomeSessionViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeSessionVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *createSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *joinSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

NS_ASSUME_NONNULL_END
