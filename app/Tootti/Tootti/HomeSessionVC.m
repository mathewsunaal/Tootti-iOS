//
//  HomeSessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import "HomeSessionVC.h"
#import "ToottiDefinitions.h"

@interface HomeSessionVC ()

@end

@implementation HomeSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    // Setup buttons
    self.createSessionButton.backgroundColor = BUTTON_DARK_TEAL;
    self.createSessionButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.createSessionButton.clipsToBounds = YES;
    [self.createSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createSessionButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
    self.joinSessionButton.backgroundColor = BUTTON_DARK_TEAL;
    self.joinSessionButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.joinSessionButton.clipsToBounds = YES;
    [self.joinSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinSessionButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    
}

- (IBAction)createSession:(UIButton *)sender {
    [self performSegueWithIdentifier:@"createSession" sender:self];
}

- (IBAction)joinSession:(UIButton *)sender {
    [self performSegueWithIdentifier:@"joinSession" sender:self];
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
