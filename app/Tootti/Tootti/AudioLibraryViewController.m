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

@interface AudioLibraryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) Session *cachedSessionLibraryVC;
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
    self.audioLibTableView.delegate = self;
    self.audioLibTableView.dataSource = self;
    [self setupViews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.audioLibTableView reloadData];
    [self setupSessionStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSessionInfoFromNotification:) name:@"sessionNotification" object:nil];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    [self setupButton:self.confirmButton];
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
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", self.cachedSessionLibraryVC.hostUid);
    if (self.cachedSessionLibraryVC != 0){
        session_title = [NSString stringWithFormat:@"%@", self.cachedSessionLibraryVC.sessionName];
        if ([currentUserId isEqual:self.cachedSessionLibraryVC.hostUid]){
            user_type = [NSString stringWithFormat:@"Host user"];
        } else {
            user_type = [NSString stringWithFormat:@"Guest user"];
        }
    }
    // Update labels
    [self.sessionCodeLabel setText:session_title];
    [self.userTypeLabel setText:user_type];
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
    for(Audio *track in self.selectedRecordings){
        [track uploadAudioSound: userID sessionUid: sessionID];
    }
    
    //Navigate to merge tracks now
    [self.tabBarController setSelectedIndex:4];
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
