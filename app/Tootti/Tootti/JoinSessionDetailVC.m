//
//  JoinSessionViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-02-28.
//

#import "JoinSessionDetailVC.h"
#import "ToottiDefinitions.h"
#import "Session.h"
#import "ClickTrackSessionVC.h"
#import "ApplicationState.h"

@import Firebase;

@interface JoinSessionDetailVC () <UITextFieldDelegate>
@property (nonatomic, readwrite) FIRFirestore *db;
@property (nonatomic,retain) Session *session;
@end

@implementation JoinSessionDetailVC

ClickTrackSessionVC *vc;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
    [self.sessionCodeTextField setDelegate:self];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    // Set up logo image
    self.logoImageView.image = [UIImage imageNamed:@"app-logo"];
    
    // Setup buttons
    self.joinSessionButton.backgroundColor = BUTTON_DARK_TEAL;
    self.joinSessionButton.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    self.joinSessionButton.clipsToBounds = YES;
    [self.joinSessionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinSessionButton.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
    // Error message
    self.errorMessage.hidden = YES;
}

- (IBAction)joinSession:(UIButton *)sender {
    self.db =  [FIRFirestore firestore];
    NSString *sessionName = self.sessionCodeTextField.text;
    [[[self.db collectionWithPath:@"session"] queryWhereField:@"sessionName" isEqualTo: sessionName]
        getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
          if (error != nil) {
            NSLog(@"Error getting documents: %@", error);
              self.errorMessage.hidden = NO;
              self.errorMessage.text = @"The session name doesn't exist";
          } else {
              FIRDocumentSnapshot *document  = snapshot.documents[0];
              NSLog(@"%@ => %@", document.documentID, document.data);
                //Will replace the Audio file
              Session *sn = [[Session alloc] initWithUid: document.documentID sessionName:document.data[@"sessionName"] hostUid:document.data[@"hostUid"] guestPlayerList:document.data[@"guestPlayerList"] clickTrack: [[Audio alloc] init] recordedAudioDict:document.data[@"recordedAudioDict"] finalMergedResult: [[Audio alloc] init] hostStartRecording: NO];
              self.session = sn;
              //NSDictionary *dict = [NSDictionary dictionaryWithObject:sn forKey:@"currentSession"];
              //Sending the notification
              //[[NSNotificationCenter defaultCenter] postNotificationName: @"sessionNotification" object:nil userInfo: dict];
              //segue
              [[ApplicationState sharedInstance] setCurrentSession:self.session ] ;
              [self performSegueWithIdentifier:@"joinSessionRecording" sender:self];
              //[self prepareForSegue: @"joinSessionRecording" sender:self];
          }
        }];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"joinSessionRecording"]) {
        UITabBarController *tabBarVC = [segue destinationViewController];
        //ClickTrackSessionVC *vc = (ClickTrackSessionVC *) [tabBarVC.viewControllers objectAtIndex:1];
        //[vc setCachedSession:self.session];
        [tabBarVC setSelectedIndex:1];
        }
}

#pragma mark - Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


@end
