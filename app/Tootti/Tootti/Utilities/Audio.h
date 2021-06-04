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
@property (strong, nonatomic) NSString *audioURL;
@property (strong, nonatomic) NSString *performer;
@property (strong, nonatomic) NSString *performerUid;
@property (strong, nonatomic) NSDictionary *configDictionary;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *audioType;
@property (retain, nonatomic) AVAudioPlayer *player;



- (instancetype) initWithAudioName:(NSString *)audioName
                      performerUid: (NSString *)performerUid
                         performer: (NSString *)performer
                          audioURL:(NSString *)audioURL;

- (instancetype) initWithRemoteAudioName:(NSString *)audioName
                            performerUid: (NSString *)performerUid
                            performer: (NSString *)performer
                          audioURL:(NSURL *)audioURL;

- (BOOL) playAudio;
- (BOOL) playAudioAtTime:(NSTimeInterval)time;
- (void) pauseAudio;
- (void) stopAudio;
- (BOOL)cropAudioWithStartTime:(NSTimeInterval)start;
- (void) uploadAudioSound: (NSString *) userUid
               sessionUid: (NSString *) sessionUid
                 username: (NSString *) username
          completionBlock:(void (^)(BOOL success, NSURL *finalDownloadURL))completionBlock;
- (void) uploadTypedAudioSound: (NSString *) userUid
               sessionUid: (NSString *) sessionUid
                audioType: (NSString *) audioType
               completionBlock: (void (^)(BOOL success, NSURL *finalDownloadURL))completion;
-(void) deleteAudioTrack: (NSString *) userUid
              sessionUid: (NSString *) sessionUid
         guestPlayerList: (NSArray *) guestPlayerList
         completionBlock: (void (^)(BOOL success))completion;
- (NSArray *) convertAVToArr;

- (NSURL *)getURL;
@end
