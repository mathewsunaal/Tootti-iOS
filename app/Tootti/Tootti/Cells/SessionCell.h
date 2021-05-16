//
//  SessionCell.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-05-15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sessionName;
@property (weak, nonatomic) IBOutlet UILabel *numCollaboratorsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numTracksLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostUserLabel;


-(void)setSessionCell:(NSString *)sessionName numberOfCollaborators:(int)colabCount numberOfTracks:(int)trackCount host:(NSString *)hostUserName;
@end

NS_ASSUME_NONNULL_END
