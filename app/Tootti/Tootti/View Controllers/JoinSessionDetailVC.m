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
#import "ActivityIndicator.h"

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
    NSString *sessionName =[self.sessionCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *hostUserName =[self.hostNameTestField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSMutableArray *joinedSessionListMutable = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"joinedSessions"];
    NSLog(@"123331231231231%@", joinedSessionListMutable);
    // Remove from currentPlayerList if joining a different session
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    if(![[[[ApplicationState sharedInstance] currentSession] sessionName] isEqual:sessionName]) {
        [[[ApplicationState sharedInstance] currentSession] updateCurrentPlayerListWithActivity:NO
                                     username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                          uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                              completionBlock:nil];
    }
    // Search for host name in firebase
    [[[self.db collectionWithPath:@"user"] queryWhereField:@"username" isEqualTo: hostUserName ]
    getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error != nil) {
                    NSLog(@"Error getting documents: %@", error);
                    [[ActivityIndicator sharedInstance] stop];
            }
            else {
                // No session found
                if ([snapshot.documents count] == 0){
                    self.errorMessage.hidden = YES;
                    self.errorMessage.text = @"The host username doesn't exist";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Host not found!"
                                                                                            message:@"Please ensure the host name is correct."
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            // Handle stuff incase of session not found
                        }];
                        [alertVC addAction:okButton];
                        [self presentViewController:alertVC animated:YES completion:nil];
                    });
                    [[ActivityIndicator sharedInstance] stop];
                    //TODO: test this, return if no session exists
                    return;
                }
                else{
                    FIRDocumentSnapshot *document  = snapshot.documents[0];
                    NSLog(@"%@ => %@", document.documentID, document.data);
                    NSString *hostUserName = document.documentID;
                    // Search for session in Firebase if exists
                    [[[[self.db collectionWithPath:@"session"] queryWhereField:@"sessionName" isEqualTo: sessionName ] queryWhereField:@"hostUid" isEqualTo: hostUserName ]
                        getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
                          if (error != nil) {
                            NSLog(@"Error getting documents: %@", error);
                              [[ActivityIndicator sharedInstance] stop];
                          } else {
                              // No session found
                              if ([snapshot.documents count] == 0){
                                  self.errorMessage.hidden = YES;
                                  self.errorMessage.text = @"The session doesn't exist";
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"No matching session not found!"
                                                                                                          message:@"Please ensure the session name/code is correct."
                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                      UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          // Handle stuff incase of session not found
                                      }];
                                      [alertVC addAction:okButton];
                                      [self presentViewController:alertVC animated:YES completion:nil];
                                  });
                                  [[ActivityIndicator sharedInstance] stop];
                                  //TODO: test this, return if no session exists
                                  return;
                              } else {
                                  FIRDocumentSnapshot *document  = snapshot.documents[0];
                                  NSLog(@"%@ => %@", document.documentID, document.data);
                                    //Will replace the Audio file
                                  //Check if the clickTrack is empty
                                      Audio *clickTrackAudio = [[Audio alloc] init];
                                      Audio *mergedAudio =  [[Audio alloc] init];
                                      if (document.data[@"clickTrackRef"]){
                                          NSURL *ckURL = [ NSURL URLWithString: document.data[@"clickTrackRef"]];
                                          clickTrackAudio = [[Audio alloc] initWithRemoteAudioName:@"click-track.wav" performerUid:performerUid performer:performer audioURL: ckURL];
                                      }
                                      if (document.data[@"finalMergedResultRef"]){
                                          NSURL *mgURL = [ NSURL URLWithString: document.data[@"finalMergedResultRef"]];
                                          mergedAudio = [[Audio alloc] initWithRemoteAudioName:@"merged-song.wav" performerUid:performerUid  performer:performer  audioURL: mgURL];
                                      }
                                      //update current player list
                                      BOOL checker = YES;
                                      NSLog(@"%ld",[document.data[@"currentPlayerList"] count]);
                                      for (int i =0 ; i< [document.data[@"currentPlayerList"] count]; i++){
                                          if ([document.data[@"currentPlayerList"][i][@"uid"] isEqual:performerUid] ){
                                              checker = NO;
                                          }
                                      }
                                      NSMutableArray *cpl = document.data[@"currentPlayerList"];
                                      if (checker){
                                          NSMutableDictionary *p = [[ NSMutableDictionary alloc] init];
                                          [ p setObject:performer forKey:@"username"];
                                          [ p setObject:performerUid forKey:@"uid"];
                                          [ p setObject: @NO forKey:@"status"];
                                          [cpl addObject:p];
                                      }
                                      Session *sn = [[Session alloc] initWithUid: document.documentID sessionName:document.data[@"sessionName"] hostUid:document.data[@"hostUid"] guestPlayerList:document.data[@"guestPlayerList"] clickTrack: clickTrackAudio recordedAudioDict:document.data[@"recordedAudioDict"] finalMergedResult: mergedAudio hostStartRecording: NO currentPlayerList:cpl ];
                                      self.session = sn;
                                      [[ApplicationState sharedInstance] setCurrentSession:self.session ] ;
                                      //save to database
                                      if (checker){
                                          NSLog(@"%@",cpl);
                                          FIRFirestore *db =  [FIRFirestore firestore];
                                          FIRDocumentReference *sessionRef = [[db collectionWithPath:@"session"] documentWithPath:document.documentID];
                                          [sessionRef updateData:@{
                                              @"currentPlayerList": cpl
                                          } completion:^(NSError * _Nullable error) {
                                              //Save the audioFile to firestore
                                              if (error){
                                                  NSLog(@"%@",error);
                                              }
                                              else{
                                                  NSLog(@"Audio file is saved successfully");
                                                  NSMutableArray *joinedSessionList = [joinedSessionListMutable copy];
                                                  if (![ joinedSessionList containsObject: document.documentID]){
                                                      FIRDocumentReference *userRef = [[db collectionWithPath:@"user"] documentWithPath: performerUid];
                                                      [userRef updateData:@{
                                                          @"joinedSessions": [FIRFieldValue fieldValueForArrayUnion: @[document.documentID]]
                                                      } completion:^(NSError * _Nullable error) {
                                                          //Save the audioFile to firestore
                                                          if (error){
                                                              NSLog(@"%@",error);
                                                          } else{
                                                              NSLog(@"Audio file is saved successfully");
                                                              [joinedSessionListMutable addObject:document.documentID];
                                                              [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"joinedSessions"];
                                                              [[NSUserDefaults standardUserDefaults] setObject: joinedSessionListMutable forKey:@"joinedSessions"];
                                                              [self performSegueWithIdentifier:@"joinSessionRecording" sender:self];
                                                          }
                                                          [[ActivityIndicator sharedInstance] stop];
                                                      }];
                                                  } else {
                                                      [self performSegueWithIdentifier:@"joinSessionRecording" sender:self];
                                                      [[ActivityIndicator sharedInstance] stop];
                                                  }
                                              }
                                          }];
                                      }
                                  else{
                                      [self performSegueWithIdentifier:@"joinSessionRecording" sender:self];
                                      [[ActivityIndicator sharedInstance] stop];
                                  }
                              //[self performSegueWithIdentifier:@"joinSessionRecording" sender:self];
                              }
                          }
                        }];
                }
                
            }
    }];
}

#pragma mark - navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"joinSessionRecording"]) {
        UITabBarController *tabBarVC = [segue destinationViewController];
        //ClickTrackSessionVC *vc = (ClickTrackSessionVC *) [tabBarVC.viewControllers objectAtIndex:1];
        //[vc setCachedSession:self.session];
        [tabBarVC setSelectedIndex:2]; // navigate to recording 
        }
}

#pragma mark - Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


@end
