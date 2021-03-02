//
//  SignupViewController.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *instrumentTextField;
@end

NS_ASSUME_NONNULL_END
