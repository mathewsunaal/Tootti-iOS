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
#import "ApplicationState.h"

@interface HomeSessionVC ()
@property (nonatomic, readwrite) FIRFirestore *db;
@property (nonatomic, retain) Session *cachedSessionHomeVC;
//@property(nonatomic,retain) User *user;
@end

@implementation HomeSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    self.db =  [FIRFirestore firestore];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:TRUE];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupSessionStatus];
    self.pageIndex = 0;
    [self.tabBarController setSelectedIndex:self.pageIndex];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSessionInfoFromNotification:) name:@"sessionNotification" object:nil];

    //LISTENING ON FIREBASE
    //Check the Session click trac
    NSString *sessionId = self.cachedSessionHomeVC.uid;
    NSLog(@"SessionID: %@", sessionId );
    if (sessionId != 0){
        [self updateTabStatus:YES];
        [[[self.db collectionWithPath:@"session"] documentWithPath: sessionId]
            addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
              if (snapshot == nil) {
                NSLog(@"Error fetching document: %@", error);
                return;
              }
              //ADD any upadates to HomeSessionVC for a specific Firebase Session update
        }];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }
    // test ends
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
    
    [self.tabBarController.navigationItem setHidesBackButton:YES];
    
}

// Enable or disable tabbar items depending on session status
- (void)updateTabStatus:(BOOL)enabledStatus {
    if(!enabledStatus){
        [self.tabBarController setSelectedIndex:0];// Set tabbar selection to HomeSessionVC
    }
    for(UITabBarItem *tabBarItem in [[self.tabBarController tabBar]items]) {
        if(![tabBarItem.title isEqual:@"Home"]) {
            [tabBarItem setEnabled:enabledStatus];
        }
    }
}

- (void) setupSessionStatus {
    self.cachedSessionHomeVC = [[ApplicationState sharedInstance] currentSession];
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 500, 40)];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    //[[self view] addSubview:statusLabel];
    NSString *message= [NSString stringWithFormat:@"Not in any sessions"];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionHomeVC.hostUid);
    if (self.cachedSessionHomeVC != 0){
        if ([currentUserId isEqual:self.cachedSessionHomeVC.hostUid]){
            message = [NSString stringWithFormat:@"Session: %@. UserType: HOST", self.cachedSessionHomeVC.sessionName];
        }
        else{
            message = [NSString stringWithFormat:@"Session: %@. UserType: GUEST", self.cachedSessionHomeVC.sessionName];
        }
    }
    [statusLabel setText: message];
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
    NSLog(@"Settings tapped");
    [self.cachedSessionHomeVC updateCurrentPlayerListWithActivity:NO
                                             username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                                  uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                                      completionBlock:nil];
        
    //destroy all global instances
    self.user = nil;
    self.cachedSessionHomeVC = nil;
    [ApplicationState close];
    [ApplicationState logout];
    [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    
    //TODO: Exit session and save stuff
    
}
/*
- (void)receiveSessionInfoFromNotification:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    cachedSessionHomeVC= [dict valueForKey:@"currentSession"];
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
