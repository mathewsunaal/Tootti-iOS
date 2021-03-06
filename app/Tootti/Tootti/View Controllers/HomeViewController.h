//
//  ViewController.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-11.
//

#import <UIKit/UIKit.h>

@import Firebase;
@interface HomeViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *pass;

@end

