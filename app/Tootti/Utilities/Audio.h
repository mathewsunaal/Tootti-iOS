//
//  Audio.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <AVFoundation/AVFoundation.h>

@interface Audio: NSObject
@property (readonly) NSString *uid;
@property (strong, nonatomic) NSString *audioSound;
@property (strong, nonatomic) NSString *audioName;
@property (strong, nonatomic) NSString *performer;
@property (strong, nonatomic) NSDictionary *configDictionary;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *audioType;

- (instancetype) initWithAudioName: (NSString *)audioName
                        audioSound: (NSString *)audioSound
                         performer: (NSString *)performer
                  configDictionary: (NSDictionary *)configDictionary
                         sessionId: (NSString *)sessionId
                         audioType: (NSString *)audioType
                               uid: (NSString *)uid;


- (AVAudioPlayer* ) getAudioSound;
- (void) uploadAudioSound;


@end
