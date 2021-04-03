//
//  Session.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//
#include "Audio.h"
@import Firebase;
@interface Session: NSObject
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *sessionName;
@property (strong, nonatomic) NSString *hostUid;
@property (strong, nonatomic) NSArray *guestPlayerList;
@property (strong, nonatomic) NSArray *currentPlayerList;
@property (strong, nonatomic) Audio *clickTrack;
@property (strong, nonatomic) NSDictionary *recordedAudioDict;
@property (strong, nonatomic) Audio *finalMergedResult;
@property (assign, nonatomic) BOOL hostStartRecording;
@property (nonatomic, readwrite) FIRFirestore *db;

- (instancetype) initWithUid: (NSString *)uid
                 sessionName: (NSString *)sessionName
                     hostUid: (NSString *)hostUid
             guestPlayerList: (NSArray *)guestPlayerList
                  clickTrack: (Audio *)clickTrack
           recordedAudioDict: (NSDictionary *)recordedAudioDict
           finalMergedResult: (Audio *)finalMergedResult
          hostStartRecording: (BOOL) hostStartRecording
           currentPlayerList: (NSArray *)currentPlayerList;

//Destructor
+ (Audio *) getClickTrack;
- (void) saveSessionToDatabase: (void (^)(BOOL success))completion;
- (void) sessionRecordingStatusUpdate: (BOOL) status;

+ (void) mergeAllTracks;
+ (void) updateRecordedTracks: (Audio *) audioClip;
-(void) deleteGuestPerformer;
-(NSArray* ) getOnlineUserSession;
@end
