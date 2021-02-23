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
}

- (IBAction)login:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"loginSession" sender:self];
}

- (IBAction)singup:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
}

- (IBAction)openSettings:(id)sender {
    
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

@end
