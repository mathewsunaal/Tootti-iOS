//
//  HomeSessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import "HomeSessionVC.h"
#import "ToottiDefinitions.h"
#import "HomeViewController.h"
#import "User.h"
@import Firebase;
#import "Session.h"

@interface HomeSessionVC ()
@property(nonatomic,retain) Session *session;
//@property(nonatomic,retain) User *user;

@end


@implementation HomeSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.pageIndex = 0;
    [self.tabBarController setSelectedIndex:self.pageIndex];
    
}

- (void) setupViews {
    
    
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Set up logo image
    self.logoImageView.image = [UIImage imageNamed:@"app-logo"];
    
    // Setup buttons
    [self setupButton:self.createSessionButton];
    [self setupButton:self.joinSessionButton];
    [self setupButton:self.viewSessionsButton];
    
}

-(void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

#pragma mark - Button Action Methods
- (IBAction)createSession:(UIButton *)sender {
    [self performSegueWithIdentifier:@"createSession" sender:self];
}

- (IBAction)joinSession:(UIButton *)sender {
    [self performSegueWithIdentifier:@"joinSession" sender:self];
}

- (IBAction)viewPastSessions:(UIButton *)sender {
    NSLog(@"View Past Sessions button pressed");
}

- (IBAction)logOutTapped:(id)sender {
    //[[FIRAuth auth] removeAuthStateDidChangeListener: userHandle];
    NSLog(@"tapppppppppped");
    self.user = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    
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
