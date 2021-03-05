//
//  HostUserDecorator.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//
#import <AVFoundation/AVFoundation.h>
#import "User.h"
#import "Session.h"

@interface HostUserDecorator: NSObject
@property (strong, nonatomic) Session *session;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSArray *recordedSongs;

- (instancetype) initWithSession: (Session *)session
                            user: (User *)user
                     recordedSongs: (NSArray *)recordedSongs;

//Destructor
+ (AVAudioPlayer *) getClickTrack;
+ (void) adjustClickTrack: (NSDictionary *) configDict;
+ (void) inviteUsers: (NSArray *) usersList;
+ (void) recordAudio;
+ (void) uploadUserAudio: (Audio *) audioClip;
+ (void) removeUsers: (NSArray *) usersList;


@end
