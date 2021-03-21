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
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    [self setupButton:self.confirmButton];
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

- (IBAction)deleteSelectedTracks:(UIButton *)sender {
    [self.audioRecordings removeObjectsInArray:self.selectedRecordings];
    [self.selectedRecordings removeAllObjects];
    [self.audioLibTableView reloadData];
}

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

@end
