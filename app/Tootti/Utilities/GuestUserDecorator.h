//
//  GuestUserDecorator.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <AVFoundation/AVFoundation.h>
#import "User.h"
#import "Session.h"
#import "Audio.h"

@interface GuestUserDecorator: NSObject
@property (strong, nonatomic) Session *session;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Audio *recordedSong;

- (instancetype) initWithSession: (Session *)session
                            user: (User *)user
                     recordedSong: (Audio *)recordedSong;
+ (void) recordAudio;


@end
