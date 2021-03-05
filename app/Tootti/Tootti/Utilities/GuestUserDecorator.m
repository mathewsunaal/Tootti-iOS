//
//  GuestUserDecorator.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include "GuestUserDecorator.h"
#import "Audio.h"
#import "Session.h"
#import "User.h"

@implementation GuestUserDecorator
//Constructor
- (instancetype) initWithSession: (Session *) session
                            user: (User *) user
                     recordedSong: (Audio *) recordedSong {
    self = [super init];
    if (self) {
        _session= session;
        _user = user;
        _recordedSong = recordedSong;
    }
    return self;
}

+ (void) recordAudio{
    return;
}
+ (void) uploadUserAudio: (Audio *) audioClip{
    return;
}

@end
