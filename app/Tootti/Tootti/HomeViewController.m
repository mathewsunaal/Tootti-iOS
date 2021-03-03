//
//  ViewController.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-11.
//

#import "HomeViewController.h"
#import "ToottiDefinitions.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set delegates
    self.emailTextField.delegate = self;
    self.passTextField.delegate = self;
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void) setupViews {
    
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Setup home logo
    self.logoImageView.image = [UIImage imageNamed:@"home-logo"];
    
    // Setup buttons
    self.loginButton.backgroundColor = BUTTON_DARK_TEAL;
    self.loginButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.loginButton.clipsToBounds = YES;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
    self.signupButton.backgroundColor = BUTTON_DARK_TEAL;
    self.signupButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.signupButton.clipsToBounds = YES;
    [self.signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signupButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

- (IBAction)login:(UIButton *)sender {
    
    // Update the string properties
    self.email = self.emailTextField.text;
    self.pass = self.passTextField.text;
    
    NSLog(@"Logging In for: %@",self.email);
    
    // Firebase function to login user.. (move seague to success block)
    [self performSegueWithIdentifier:@"loginUser" sender:self];
}

- (IBAction)singup:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
}

//- (IBAction)openSettings:(id)sender {
//
//    [self performSegueWithIdentifier:@"showSettings" sender:self];
//}

// Textfield delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}
@end
