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
           finalMergedResult: (Audio *)finalMergedResult
          hostStartRecording: (BOOL) hostStartRecording{
    self = [super init];
    if (self) {
        _uid = uid;
        _sessionName= sessionName;
        _hostUid = hostUid;
        _guestPlayerList = guestPlayerList;
        _clickTrack= clickTrack;
        _recordedAudioDict = recordedAudioDict;
        _finalMergedResult = finalMergedResult;
        _hostStartRecording =hostStartRecording;
    }
    return self;
}

- (void) saveSessionToDatabase: (void (^)(BOOL success))completionBlock{
    self.db =  [FIRFirestore firestore];
    //implement later, check if sessionname has duplicates
    //save the session
    NSDictionary *docData = @{
        @"sessionName": self.sessionName,
        @"hostUid": self.hostUid,
        @"guestPlayerList": self.guestPlayerList,
        @"clickTrackRef": @"",
        @"recordedAudioDict": self.recordedAudioDict, 
        @"finalMergedResultRef": @"",
        @"hostStartRecording": @NO
    };
    __block FIRDocumentReference *ref =
        [[self.db collectionWithPath:@"session"] addDocumentWithData:docData completion:^(NSError * _Nullable error) {
          if (error != nil) {
            NSLog(@"Error adding Session document: %@", error);
          } else {
            NSLog(@"Document added with ID: %@", ref.documentID);
              NSLog(@"%@",self.uid);
              if (completionBlock != nil) completionBlock(YES);
          }
        }];
}
+ (AVAudioPlayer* ) getClickTrack{
    return [AVAudioPlayer alloc];
}
- (void) sessionRecordingStatusUpdate: (BOOL)status {
    [[[self.db collectionWithPath:@"session"] documentWithPath: self.uid]  setData:@{
        @"hostStartRecording": @(status)
    } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error writing document: %@", error);
        } else {
          NSLog(@"Document successfully written!");
        }
      }];
    return;
}

+ (void) mergeAllTracks{
    return;
}

+ (void) updateRecordedTracks: (Audio *) audioClip{
    return;
}
@end
