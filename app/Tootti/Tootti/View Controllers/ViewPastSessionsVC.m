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


@interface ViewPastSessionsVC () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation ViewPastSessionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pastSessionsTableView.delegate = self;
    self.pastSessionsTableView.dataSource = self;
    [self setupViews];
    // Do any additional setup after loading the view.
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


#pragma mark - IBAction Button Methods

- (IBAction)joinPastSession:(UIButton *)sender {
    NSLog(@"Join past session");
}

#pragma mark - Table View method

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sessionCell" forIndexPath:indexPath];
    [cell setSessionCell:@"sunaal jam" numberOfCollaborators:2 numberOfTracks:10 host:@"mathewsunaal"];
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = LOGO_GOLDEN_YELLOW;
    [cell setSelectedBackgroundView:backgroundColorView];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
