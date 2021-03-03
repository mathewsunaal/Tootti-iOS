//
//  CreateSessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import "CreateSessionDetailVC.h"
#import "ToottiDefinitions.h"

@interface CreateSessionDetailVC ()

@end

@implementation CreateSessionDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Set up logo image
    self.logoImageView.image = [UIImage imageNamed:@"app-logo"];
    
    // Setup buttons
    self.createSessionButton.backgroundColor = BUTTON_DARK_TEAL;
    self.createSessionButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.createSessionButton.clipsToBounds = YES;
    [self.createSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createSessionButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

- (IBAction)createNewSession:(UIButton *)sender {
    [self performSegueWithIdentifier:@"createSessionRecording" sender:self];
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
