//
//  ViewController.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-11.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Set delegates
    self.emailTextField.delegate = self;
    self.passTextField.delegate = self;
}

- (IBAction)login:(UIButton *)sender {
    
    // Update the string properties
    self.email = self.emailTextField.text;
    self.pass = self.passTextField.text;
    
    NSLog(@"Logging In for: %@",self.email);
    [self performSegueWithIdentifier:@"loginSession" sender:self];
}

- (IBAction)singup:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
}

- (IBAction)openSettings:(id)sender {
    
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

// Textfield delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return TRUE;
}
@end
