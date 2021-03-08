//
//  ClickTrackSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "ClickTrackSessionVC.h"
#import "ToottiDefinitions.h"

@interface ClickTrackSessionVC ()


@end

@implementation ClickTrackSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

- (void) setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
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
