//
//  SignupViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-23.
//

#import "SignupViewController.h"
#import "ToottiDefinitions.h"

@interface SignupViewController () <UITextFieldDelegate>

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *pass;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *bio;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set delegates
    self.emailTextField.delegate = self;
    self.passTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.instrumentTextField.delegate = self;
    
    [self setupViews];
}

- (void) setupViews {
    
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Set up logo image
    self.logoImageView.image = [UIImage imageNamed:@"app-logo"];
    
    // Setup buttons
    self.createAccountButton.backgroundColor = BUTTON_DARK_TEAL;
    self.createAccountButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.createAccountButton.clipsToBounds = YES;
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAccountButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
}


- (IBAction)createAccount:(UIButton *)sender {
    
    self.email = self.emailTextField.text;
    self.pass = self.passTextField.text;
    self.username = self.usernameTextField.text;
    self.bio = self.instrumentTextField.text;
    
    NSLog(@"Create Account Request");
    
    // Firebase call to create new user ...
    
}

// Textfield delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
