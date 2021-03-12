//
//  ClickTrackSessionVC.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-04.
//

#import "ClickTrackSessionVC.h"
#import "ToottiDefinitions.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ClickTrackSessionVC () <MPMediaPickerControllerDelegate>
@property (nonatomic,retain) MPMediaPickerController *pickerVC;
//@property (nonatomic,retain)
@end

@implementation ClickTrackSessionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)setupViews {
    // Set background colour of view controller
    [self.view setBackgroundColor: BACKGROUND_LIGHT_TEAL];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Upload clicktrack" forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT-80);
    NSLog(@"%f",self.view.bounds.size.width);
    [button addTarget:self action:@selector(uploadClickTrack:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.pickerVC = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
}

- (void)uploadClickTrack:(UIButton *)button {
     NSLog(@"Button Pressed");
    
    self.pickerVC.allowsPickingMultipleItems = NO;
    self.pickerVC.popoverPresentationController.sourceView = button;
    self.pickerVC.delegate = self;
    //[self.pickerVC setModalPresentationCapturesStatusBarAppearance:UIModalPresentationCurrentContext];
    [self presentViewController:self.pickerVC animated:YES completion:nil];
}

#pragma mark - MPMediaPickerControllerDelegate methods

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSLog(@"Did pick audio track: %@",mediaItemCollection);
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
