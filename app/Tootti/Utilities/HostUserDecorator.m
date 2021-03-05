//
//  HostUserDecorator.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include "HostUserDecorator.h"
#import "Audio.h"
#import "Session.h"
#import "User.h"

@implementation HostUserDecorator
//Constructor
- (instancetype) initWithSession: (Session *) session
                            user: (User *) user
                     recordedSongs: (NSArray *) recordedSongs {
    self = [super init];
    if (self) {
        _session= session;
        _user = user;
        _recordedSongs = recordedSongs;
    }
    return self;
}

+ (AVAudioPlayer *) getClickTrack{
    return [AVAudioPlayer alloc];
}
+ (void) adjustClickTrack: (NSDictionary *)trackConfig{
    return;
}
+ (void) inviteUsers: (NSArray *) usersList{
    return;
}
+ (void) removeUsers: (NSArray *) usersList{
    return;
}
+ (void) recordAudio{
    return;
}
+ (void) uploadUserAudio: (Audio *) audioClip{
    return;
}
@end
