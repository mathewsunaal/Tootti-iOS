//
//  Session.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//
#include "Audio.h"

@interface Session: NSObject
@property (readonly) NSString *uid;
@property (strong, nonatomic) NSString *sessionName;
@property (strong, nonatomic) NSString *hostUid;
@property (strong, nonatomic) NSArray *guestPlayerList;
@property (strong, nonatomic) Audio *clickTrack;
@property (strong, nonatomic) NSDictionary *recordedAudioDict;
@property (strong, nonatomic) Audio *finalMergedResult;

- (instancetype) initWithUid: (NSString *)uid
                 sessionName: (NSString *)sessionName
                     hostUid: (NSString *)hostUid
             guestPlayerList: (NSArray *)guestPlayerList
                  clickTrack: (Audio *)clickTrack
           recordedAudioDict: (NSDictionary *)recordedAudioDict
           finalMergedResult: (Audio *)finalMergedResult;

//Destructor
+ (Audio *) getClickTrack;
+ (void) updateClickTrackConfiguration: (NSDictionary *)trackConfig;
+ (void) mergeAllTracks;
+ (void) updateRecordedTracks: (Audio *) audioClip;

@end
