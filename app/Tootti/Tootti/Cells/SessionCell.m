//
//  SessionCell.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-05-15.
//

#import "SessionCell.h"

@implementation SessionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setSessionCell:(NSString *)sessionName numberOfCollaborators:(int)colabCount numberOfTracks:(int)trackCount host:(NSString *)hostUserName {
    
    [self.sessionName setText:sessionName];
    [self.hostUserLabel setText:hostUserName];
    [self.numCollaboratorsLabel setText:[NSString stringWithFormat:@"%i",colabCount]];
    [self.numTracksLabel setText:[NSString stringWithFormat:@"%i",trackCount]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
