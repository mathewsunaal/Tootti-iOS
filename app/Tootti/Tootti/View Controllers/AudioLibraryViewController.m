//
//  AudioLibraryViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-17.
//

#import "AudioLibraryViewController.h"
#import "MergeSessionVC.h"
#import "ToottiDefinitions.h"
#import "AudioCell.h"
#import "Session.h"
#import "ApplicationState.h"
#import "ActivityIndicator.h"

@interface AudioLibraryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) Session *cachedSessionLibraryVC;
@property (nonatomic) int uploadCount;
@end

@implementation AudioLibraryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.audioRecordings == nil){
        self.audioRecordings = [[NSMutableArray alloc] init];
    }
    if(self.selectedRecordings == nil){
        self.selectedRecordings = [[NSMutableArray alloc] init];
    }
    
    //Set delegates
    [self setupViews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.audioLibTableView reloadData];
    [self setupSessionStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSessionInfoFromNotification:) name:@"sessionNotification" object:nil];
    
    if (self.cachedSessionLibraryVC.uid != 0){
        [self updateTabStatus:YES];
    } else {
        // Lock other tabs
        [self updateTabStatus:NO];
    }
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    [self setupButton:self.confirmButton];
    self.audioLibTableView.delegate = self;
    self.audioLibTableView.dataSource = self;
    self.audioLibTableView.layer.cornerRadius = NORMAL_TABLE_CORNER_RADIUS;
    
    [self.refreshButton setEnabled:NO];
    [self.refreshButton setHidden:YES];
    
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

- (void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

- (void)setupSessionStatus {
    self.cachedSessionLibraryVC = [[ApplicationState sharedInstance] currentSession];
    NSString *session_title= [NSString stringWithFormat:@"No session active"];
    NSString *user_type = [NSString stringWithFormat:@""];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionLibraryVC.hostUid);
    if (self.cachedSessionLibraryVC != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionLibraryVC.sessionName];
        if ([currentUserId isEqual:self.cachedSessionLibraryVC.hostUid]){
            user_type = [NSString stringWithFormat:@"(Host)"];
        } else {
            user_type = [NSString stringWithFormat:@"(Guest)"];
        }
    }
    // Update labels
    [self.sessionCodeLabel setText:session_title];
    [self.userTypeLabel setText:[NSString stringWithFormat:@"%@ %@",username,user_type]];
    [self.sessionCodeLabel setTextColor:LOGO_GOLDEN_YELLOW];
    [self.userTypeLabel setTextColor:[UIColor whiteColor]];
}

/*
- (void)receiveSessionInfoFromNotification:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    cachedSessionLibraryVC = [dict valueForKey:@"currentSession"];
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
#pragma mark - IBAction methods

- (IBAction)refresh:(UIButton *)sender {
    NSLog(@"Refresh Audio Library");
    [self.audioLibTableView reloadData];
}

//- (IBAction)deleteSelectedTracks:(UIButton *)sender {
//    [self.audioRecordings removeObjectsInArray:self.selectedRecordings];
//    [self.selectedRecordings removeAllObjects];
//    [self.audioLibTableView reloadData];
//}

- (IBAction)confirmTracks:(UIButton *)sender {
    NSLog(@"Send library tracks to merge");
    //TODO: add case to handle no selection
    if([self.selectedRecordings count] == 0) {
        NSLog(@"No tracks selected!");
    }
    
    [[ActivityIndicator sharedInstance] startWithSuperview:self.view];
    // Add new audio object to library VC
    MergeSessionVC *mergeVC = self.tabBarController.viewControllers[4];
    if(mergeVC.audioTracks == nil){
        mergeVC.audioTracks = [[NSMutableArray alloc] init];
    }
    // TODO: figure out how we want to handle going back to library and changing tracks included
    [mergeVC.audioTracks removeAllObjects];
    [mergeVC.audioTracks addObjectsFromArray:self.selectedRecordings];
    
    NSLog(@"%@", self.cachedSessionLibraryVC.uid);
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]);
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSString *sessionID = self.cachedSessionLibraryVC.uid;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSLog(@"112111222222222209878932642364782634876234876238746");
    NSLog(@"%@", username);
    self.uploadCount=0;
    for(Audio *track in self.selectedRecordings){
        [track uploadAudioSound: userID sessionUid: sessionID username: username completionBlock: ^(BOOL success, NSURL *downloadURL) {
            NSLog(@"Library: Starting upload to Firebase");
            if (success){
                NSLog(@"Library: Uploaded %@ track to Firebase successfully",track.audioName);
                NSLog(@"Library: Download URL is %@",downloadURL);
                self.uploadCount++;
                // Check to see if all selected recordings have been uploaded successfully (TODO: duplicate uploads considered successful for moving on to Merge page
                if(self.uploadCount >= [self.selectedRecordings count]) {
                    self.uploadCount=0;
                    [[ActivityIndicator sharedInstance] stop];
                    //Navigate to merge tracks now
                    [self.tabBarController setSelectedIndex:4];
                }
            } else {
                NSLog(@"Library: Failed to upload track %@",track.audioName);
                //TODO: add alertview and handle failed uploads for user
                [[ActivityIndicator sharedInstance] stop];
            }
        }];
    }
    

}

#pragma mark - AudioLibTableView methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"audioCell" forIndexPath:indexPath];
    
    Audio* audio = self.audioRecordings[indexPath.row];
    cell.audio = audio;
    cell.audioNameLabel.text = audio.audioName;
    cell.cellPlayer = audio.player;
    [cell.cellPlayer setDelegate:cell];
    
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = LOGO_GOLDEN_YELLOW;
    [cell setSelectedBackgroundView:backgroundColorView];

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.audioRecordings.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Audio *selectedTrack = self.audioRecordings[indexPath.row];
    //NSLog(@"Selected track:%@",selectedTrack.audioName);
    [self.selectedRecordings addObject:self.audioRecordings[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Audio *deSelectedTrack = self.audioRecordings[indexPath.row];
    //NSLog(@"deSelected track:%@",deSelectedTrack.audioName);
    [self.selectedRecordings removeObject:self.audioRecordings[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        Audio *trackToDelete = [self.audioRecordings objectAtIndex:indexPath.row];
        if([self.selectedRecordings containsObject:trackToDelete]) {
            [self.selectedRecordings removeObject:trackToDelete];
        }
        [self.audioRecordings removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData]; // tell table to refresh now
    }
}

@end
