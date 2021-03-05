//
//  Session.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Audio.h"
#import "Session.h"

@implementation Session
//Constructor
- (instancetype) initWithUid: (NSString *)uid
                 sessionName: (NSString *)sessionName
                     hostUid: (NSString *)hostUid
             guestPlayerList: (NSArray *)guestPlayerList
                  clickTrack: (Audio *)clickTrack
           recordedAudioDict: (NSDictionary *)recordedAudioDict
           finalMergedResult: (Audio *)finalMergedResult {
    self = [super init];
    if (self) {
        _uid = uid;
        _sessionName= sessionName;
        _hostUid = hostUid;
        _guestPlayerList = guestPlayerList;
        _clickTrack= clickTrack;
        _recordedAudioDict = recordedAudioDict;
        _finalMergedResult = finalMergedResult;
    }
    return self;
}
+ (AVAudioPlayer* ) getClickTrack{
    return [AVAudioPlayer alloc];
}
+ (void) updateClickTrackConfiguration: (NSDictionary *)trackConfig{
    return;
}
+ (void) mergeAllTracks{
    return;
}
+ (void) updateRecordedTracks: (Audio *) audioClip{
    return;
}
@end
