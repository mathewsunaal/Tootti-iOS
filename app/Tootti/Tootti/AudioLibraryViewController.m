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

@interface AudioLibraryViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation AudioLibraryViewController

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
    [super viewWillAppear:YES];
    [self.audioLibTableView reloadData];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    [self setupButton:self.sendToMergeButton];
}

-(void)setupButton:(UIButton *)button {
    button.backgroundColor = BUTTON_DARK_TEAL;
    button.layer.cornerRadius = NORMAL_BUTTON_CORNER_RADIUS;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:NORMAL_BUTTON_FONT_TYPE size:NORMAL_BUTTON_FONT_SIZE]];
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
- (IBAction)sendToMerge:(UIButton *)sender {
    NSLog(@"Send library tracks to merge");
    // Add new audio object to library VC
    MergeSessionVC *mergeVC = self.tabBarController.viewControllers[4];
    if(mergeVC.audioTracks == nil){
        mergeVC.audioTracks = [[NSMutableArray alloc] init];
    }
    [mergeVC.audioTracks addObjectsFromArray:self.audioRecordings];
    
    //Navigate to merge tracks now
    [self.tabBarController setSelectedIndex:4];
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
