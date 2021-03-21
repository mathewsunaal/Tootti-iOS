//
//  AudioLibraryViewController.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-17.
//

#import "AudioLibraryViewController.h"
#import "ToottiDefinitions.h"
#import "AudioCell.h"
#import "Session.h"
@interface AudioLibraryViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation AudioLibraryViewController

Session *cachedSessionLibraryVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.audioRecordings == nil){
        self.audioRecordings = [[NSMutableArray alloc] init];
    }
    
    //Set delegates
    self.audioLibTableView.delegate = self;
    self.audioLibTableView.dataSource = self;
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.audioLibTableView reloadData];
    [self setupSessionStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSessionInfoFromNotification:) name:@"sessionNotification" object:nil];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
//    [self setupButton:self.uploadTrackButton];
//    [self setupButton:self.playTrackButton];
//    [self setupButton:self.confirmTrackButton];
}

- (void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
}

- (void)setupSessionStatus {
    // Notification receiver
    //Check if you are in the session
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 500, 40)];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:statusLabel];
    NSString *message= [NSString stringWithFormat:@"Not in any sessions"];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    NSLog(@"%@", currentUserId);
    NSLog(@"%@", cachedSessionLibraryVC.hostUid);
    if (cachedSessionLibraryVC != 0){
        if (currentUserId == cachedSessionLibraryVC.hostUid){
            message = [NSString stringWithFormat:@"Session: %@. UserType: HOST", cachedSessionLibraryVC.sessionName];
        }
        else{
            message = [NSString stringWithFormat:@"Session: %@. UserType: GUEST", cachedSessionLibraryVC.sessionName];
        }
    }
    [statusLabel setText: message];
}

- (void)receiveSessionInfoFromNotification:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    cachedSessionLibraryVC = [dict valueForKey:@"currentSession"];
}


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

#pragma mark - AudioLibTableView methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"audioCell" forIndexPath:indexPath];
    
    Audio* audio = self.audioRecordings[indexPath.row];
    cell.audio = audio;
    cell.audioNameLabel.text = audio.audioName;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.audioRecordings.count;
}


@end
