//
//  CreateSessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import "CreateSessionDetailVC.h"
#import "ToottiDefinitions.h"
#import "Session.h"
#import "ActivityIndicator.h"

@interface CreateSessionDetailVC () <UITextFieldDelegate>

@end

@implementation CreateSessionDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self setupViews];
    [self.nameTextField setDelegate:self];
    [self.instrumentsTextField setDelegate:self];
    [self.musiciansTextField setDelegate:self];
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
    //create the Session uid
    NSUUID *uuid = [NSUUID UUID];
    NSString *sessionUid = [uuid UUIDString];
    NSString *sessionName = self.nameTextField.text;
    NSString *hostUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSArray *emptyGuestPlayerList  = [[NSMutableArray alloc] init];
    NSMutableArray *currentPlayerList  = [[NSMutableArray alloc] init];
    NSMutableDictionary *p = [[ NSMutableDictionary alloc] init];
    [ p setObject:username forKey:@"username"];
    [ p setObject:hostUid forKey:@"uid"];
    [ p setObject: @NO forKey:@"status"];
    [ currentPlayerList addObject:p];
    
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    // TODO:Check if session name exists
    NSMutableDictionary *recordedAudioDict = [[NSMutableDictionary alloc] init];
    Session *sn = [[Session alloc] initWithUid:sessionUid sessionName: sessionName hostUid:hostUid guestPlayerList:emptyGuestPlayerList clickTrack:[[Audio alloc] init] recordedAudioDict:recordedAudioDict finalMergedResult:[[Audio alloc] init] hostStartRecording: NO currentPlayerList:currentPlayerList];
    [sn saveSessionToDatabase: ^(BOOL success) {
        if (success){
            FIRFirestore *db =  [FIRFirestore firestore];
            FIRDocumentReference *userRef = [[db collectionWithPath:@"user"] documentWithPath:hostUid];
            NSMutableArray *joinedSessionList = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"joinedSessions"]];
            [joinedSessionList addObject:sn.uid];
            [userRef updateData:@{
                @"joinedSessions": joinedSessionList
            } completion:^(NSError * _Nullable error) {
                //Save the audioFile to firestore
                if (error){
                    NSLog(@"%@",error);
                    [[ActivityIndicator sharedInstance] stop];
                }
                else{
                    NSLog(@"Audio file is saved successfully");
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"joinedSessions"];
                    [[NSUserDefaults standardUserDefaults] setObject: [[ NSArray alloc] initWithArray: joinedSessionList] forKey:@"joinedSessions"];
                    [[ActivityIndicator sharedInstance] stop];
                    [self performSegueWithIdentifier:@"createSessionRecording" sender:self];
                }
            }];
            //[self performSegueWithIdentifier:@"createSessionRecording" sender:self];
        } else {
            // ERROR saving session to database
            NSLog(@"Error saving new session to database");
            [[ActivityIndicator sharedInstance] stop];
        }
    }];
    //save the new session
    //[self performSegueWithIdentifier:@"createSessionRecording" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITabBarController *tabBarVC = [segue destinationViewController];
    [tabBarVC setSelectedIndex:1];
    // Pass the selected object to the new view controller.
}

#pragma mark - Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
