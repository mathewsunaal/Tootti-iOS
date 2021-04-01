//
//  UserStatusCell.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-04-01.
//

#import "UserStatusCell.h"

@implementation UserStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)toggleSessionStatus:(BOOL)status {
    self.sessionStatus = status;
    if(self.sessionStatus) {
        [self.statusImage setTintColor:[UIColor systemGreenColor]];
    } else {
        [self.statusImage setTintColor:[UIColor systemGrayColor]];
    }
}

@end
