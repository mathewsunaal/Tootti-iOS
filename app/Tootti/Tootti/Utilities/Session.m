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
             guestPlayerList: (NSArray *)guestPlayerList // [{audioName: ... , uid: ... , username: ..., url: ...}, ...]
                  clickTrack: (Audio *)clickTrack
           recordedAudioDict: (NSDictionary *)recordedAudioDict
           finalMergedResult: (Audio *)finalMergedResult
          hostStartRecording: (BOOL) hostStartRecording
           currentPlayerList: (NSArray *)currentPlayerList{        // [{username: ..., uid: ..., status: ...}, ...]
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
        _currentPlayerList = currentPlayerList;
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
        @"hostStartRecording": @NO,
        @"currentPlayerList": self.currentPlayerList
    };
    __block FIRDocumentReference *ref =
        [[self.db collectionWithPath:@"session"] addDocumentWithData:docData completion:^(NSError * _Nullable error) {
          if (error != nil) {
            NSLog(@"Error adding Session document: %@", error);
          } else {
             NSLog(@"Document added with ID: %@", ref.documentID);
              NSLog(@"%@",self.uid);
              self.uid = ref.documentID;
              if (completionBlock != nil) completionBlock(YES);
          }
        }];
}
+ (AVAudioPlayer* ) getClickTrack{
    return [AVAudioPlayer alloc];
}
- (void) sessionRecordingStatusUpdate: (BOOL)status {
    self.db = [FIRFirestore firestore];
    [[[self.db collectionWithPath:@"session"] documentWithPath: self.uid]  updateData:@{
        @"hostStartRecording": @(status)
    } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"HostStartRecording: Error updating field: %@", error);
        } else {
          NSLog(@"HostStartRecording: Field successfully updated!");
        }
      }];
    return;
}

- (void) updateSessionActivityStatus:(BOOL)status
                                 uid: (NSString *) uid
                          completionBlock:(void (^)(BOOL success))completionBlock {
    
    //TODO: Update user status in firebase session
//    NSMutableArray* currentPlayerListCopy = [self.currentPlayerList mutableCopy];
//    for (int i=0; i< [_currentPlayerList count]; i++){
//        if (_currentPlayerList[i][@"uid"] == uid){
//            (BOOL)currentPlayerListCopy[i][@"status"] = status;
//        }
//    }
//
//    _currentPlayerList = currentPlayerListCopy;
//    FIRFirestore *db =  [FIRFirestore firestore];
//    FIRDocumentReference *sessionRef = [[db collectionWithPath:@"session"] documentWithPath:self.uid];
//    [sessionRef updateData:@{
//        @"currentPlayerList": _currentPlayerList
//    } completion:^(NSError * _Nullable error) {
//        //Save the audioFile to firestore
//        NSLog(@"The player related info has been deleted");
//        if (completionBlock != nil) completionBlock(YES);
//    }];
    return;
}

+ (void) mergeAllTracks{
    return;
}

+ (void) updateRecordedTracks: (Audio *) audioClip{
    return;
}

//un tested

-(void) deleteGuestPerformer: (NSString *)username
                    uid: (NSString *) uid
             completionBlock:(void (^)(BOOL success))completionBlock
{
    NSMutableArray* guestPlayerListCopy = [self.guestPlayerList mutableCopy];
    NSMutableArray* currentPlayerListCopy = [self.currentPlayerList mutableCopy];
    for (int i=0; i< [_guestPlayerList count]; i++){
        if (_guestPlayerList[i][@"uid"] == uid){
            [ guestPlayerListCopy removeObject:_guestPlayerList[i]];
        }
    }
    for (int i=0; i< [_currentPlayerList count]; i++){
        if (_currentPlayerList[i][@"uid"] == uid){
            [ currentPlayerListCopy removeObject:_currentPlayerList[i]];
        }
    }
    _guestPlayerList = guestPlayerListCopy;
    _currentPlayerList = currentPlayerListCopy;
    FIRFirestore *db =  [FIRFirestore firestore];
    FIRDocumentReference *sessionRef = [[db collectionWithPath:@"session"] documentWithPath:self.uid];
    [sessionRef updateData:@{
        @"guestPlayerList": _guestPlayerList,
        @"currentPlayerList": _currentPlayerList
    } completion:^(NSError * _Nullable error) {
        //Save the audioFile to firestore
        NSLog(@"The player related info has been deleted");
        if (completionBlock != nil) completionBlock(YES);
    }];
    
}
-(NSArray* ) getOnlineUserSession{
    //[{username: "..",  uid: "...", status: BOOL}, ...]
    return self.currentPlayerList;
}

@end
