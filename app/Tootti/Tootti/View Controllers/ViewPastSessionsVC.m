//
//  ViewPastSessionsVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-05-15.
//

#import "ViewPastSessionsVC.h"
#import "ToottiDefinitions.h"
#import "Session.h"
#import "ApplicationState.h"
#import "ActivityIndicator.h"
#import "SessionCell.h"
#import "Session.h"


@interface ViewPastSessionsVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,retain) NSMutableArray *pastSessions;

@end

@implementation ViewPastSessionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pastSessionsTableView.delegate = self;
    self.pastSessionsTableView.dataSource = self;
    [self setupViews];
    
    self.pastSessions = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@", currentUserId);
    
    [self loadSessions: [[NSUserDefaults standardUserDefaults] arrayForKey:@"joinedSessions"]];
    //[self.pastSessionsTableView reloadData];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.joinSessionButton];

    self.pastSessionsTableView.layer.cornerRadius = NORMAL_TABLE_CORNER_RADIUS;
}

- (void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

#pragma mark - Session Firebase methods

- (void)loadSessions:(NSArray *)sessionList {
    for(NSString* sessionID in sessionList) {
        NSLog(@"Session ID: %@",sessionID);
        
        // Search for session in Firebase if exists
        [ [[[FIRFirestore firestore] collectionWithPath:@"session"]
                                        documentWithPath:sessionID]
            getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                if (snapshot.exists) {
                    // Document data may be nil if the document exists but has no keys or values.
                    NSLog(@"Session found: %@", snapshot.data[@"sessionName"]);
                    
                    // Get session information
                    Session *sessionObject = [[Session alloc] initWithUid:sessionID sessionName:snapshot.data[@"sessionName"] hostUid:snapshot.data[@"hostUid"] guestPlayerList:snapshot.data[@"guestPlayerList"] clickTrack:nil recordedAudioDict:nil finalMergedResult:nil hostStartRecording:snapshot.data[@"hostStartRecording"] currentPlayerList:snapshot.data[@"currentPlayerList"]];
                    
                    NSLog(@"Host found: %@", sessionObject.hostUid);
                    // Fetch HostUsername in "user" collection document search using "hostUid" as the document field
                    [ [[[FIRFirestore firestore] collectionWithPath:@"user"]
                                                    documentWithPath:sessionObject.hostUid]
                        getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
                            if (snapshot.exists) {
                                // Document data may be nil if the document exists but has no keys or values.
                                NSLog(@"Host User found: %@", snapshot.data[@"username"]);
                                sessionObject.hostUsername = snapshot.data[@"username"];
                               // sessionObject.hostUsername = snapshot.data[@"username"];
                                [self.pastSessionsTableView reloadData];
                            } else {
                                NSLog(@"Document does not exist");
                            }
                    }];
                    
                    // Add session data to data source here
                    [self.pastSessions addObject:sessionObject];
                    [self.pastSessionsTableView reloadData];
                    
                } else {
                    NSLog(@"Document does not exist");
                }
         }];
    }
}


#pragma mark - IBAction Button Methods

- (IBAction)joinPastSession:(UIButton *)sender {
    NSIndexPath *indexPath = [self.pastSessionsTableView indexPathForSelectedRow];
    Session *session = self.pastSessions[indexPath.row];
    NSLog(@"Join past session: %@",session.sessionName);
    
    NSString *performer = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *performerUid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSMutableArray *joinedSessionListMutable = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"joinedSessions"];
    
    // Remove from currentPlayerList if joining a different session
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    if(![[[[ApplicationState sharedInstance] currentSession] sessionName] isEqual:session.sessionName]) {
        [[[ApplicationState sharedInstance] currentSession] updateCurrentPlayerListWithActivity:NO
                                     username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                          uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                              completionBlock:nil];
    }
    
    // Search for session in Firebase if exists
    [ [[[FIRFirestore firestore] collectionWithPath:@"session"] documentWithPath:session.uid]
     getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
          if (error != nil) {
            NSLog(@"Error getting documents: %@", error);
              [[ActivityIndicator sharedInstance] stop];
          } else {
              // No session found
              if (snapshot.exists == 0){
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Session not found!"
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
                  FIRDocumentSnapshot *document  = snapshot; // to keep consistent with join sessionf or now
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
                  // Set current session
                  [[ApplicationState sharedInstance] setCurrentSession:sn];
                  
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
                                  [self performSegueWithIdentifier:@"joinPastSessionRecording" sender:self];
                                  [[ActivityIndicator sharedInstance] stop];
                              }
                          }
                      }];
                      
                  } else {
                      [self performSegueWithIdentifier:@"joinPastSessionRecording" sender:self];
                      [[ActivityIndicator sharedInstance] stop];
                  }
              }
          }
        }];
    
    
    
    //[self performSegueWithIdentifier:@"joinPastSessionRecording" sender:self];
}

#pragma mark - Table View method

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sessionCell" forIndexPath:indexPath];
    Session* session = self.pastSessions[indexPath.row];

    [cell setSessionCell:session.sessionName numberOfCollaborators:[session.currentPlayerList count]
                                                    numberOfTracks:[session.guestPlayerList count]
                                                              host:session.hostUsername];
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = LOGO_GOLDEN_YELLOW;
    [cell setSelectedBackgroundView:backgroundColorView];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pastSessions count];
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"joinPastSessionRecording"]) {
        UITabBarController *tabBarVC = [segue destinationViewController];
        [tabBarVC setSelectedIndex:2]; // set to recording
    }
}




@end
