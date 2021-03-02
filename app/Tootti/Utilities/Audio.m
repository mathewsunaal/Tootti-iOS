//
//  Audio.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Audio.h"

@implementation Audio
//Constructor
- (instancetype) initWithAudioName: (NSString *)audioName
                        audioSound: (NSString *)audioSound
                         performer: (NSString *)performer
                  configDictionary: (NSDictionary *)configDictionary
                         sessionId: (NSString *)sessionId
                         audioType: (NSString *)audioType
                               uid: (NSString *)uid {
    self = [super init];
    if (self) {
        _uid = uid;
        _audioName= audioName;
        _performer = performer;
        _configDictionary = configDictionary;
        _audioSound= audioSound;
        _audioType = audioType;
        _audioType = audioType;
    }
    return self;
}
- (AVAudioPlayer* ) getAudioSound{
    return [AVAudioPlayer alloc];
}
- (void) uploadAudioSound {
    return;
}

@end
