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
    
    NSMutableArray* currentPlayerListCopy = [self.currentPlayerList mutableCopy];
    for (int i=0; i< [_currentPlayerList count]; i++){
        if ([_currentPlayerList[i][@"uid"] isEqualToString:uid]){
            currentPlayerListCopy[i][@"status"] = @(status);
        }
    }
 
    _currentPlayerList =[currentPlayerListCopy copy];
    FIRFirestore *db =  [FIRFirestore firestore];
    FIRDocumentReference *sessionRef = [[db collectionWithPath:@"session"] documentWithPath:self.uid];
    [sessionRef updateData:@{
        @"currentPlayerList": _currentPlayerList
    } completion:^(NSError * _Nullable error) {
        //Save the audioFile to firestore
        NSLog(@"The status of player (%@) has been updated",uid);
        if (completionBlock != nil) completionBlock(YES);
    }];
    return;
}

- (void) updateCurrentPlayerListWithActivity:(BOOL)isActive
                        username:(NSString *)username
                             uid:(NSString *)uid
                          completionBlock:(void (^)(BOOL success))completionBlock {
    NSMutableArray* currentPlayerListCopy = [self.currentPlayerList mutableCopy];
    // Check whether to add or remove
    if(isActive) {
        // ADD player to currentPlayerList
        NSMutableDictionary *newPlayer = [[ NSMutableDictionary alloc] init];
        [newPlayer setObject:username forKey:@"username"];
        [newPlayer setObject:uid forKey:@"uid"];
        [newPlayer setObject: @NO forKey:@"status"];
        [currentPlayerListCopy addObject:newPlayer];
    } else {
        // REMOVE player from currentPlayerList
        for (int i=0; i< [_currentPlayerList count]; i++){
            if ([_currentPlayerList[i][@"uid"] isEqualToString:uid]){
                [ currentPlayerListCopy removeObject:_currentPlayerList[i]];
            }
        }
    }
    _currentPlayerList =[currentPlayerListCopy copy];
    FIRFirestore *db =  [FIRFirestore firestore];
    FIRDocumentReference *sessionRef = [[db collectionWithPath:@"session"] documentWithPath:self.uid];
    [sessionRef updateData:@{
        @"currentPlayerList": _currentPlayerList
    } completion:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"Failed to update currentPlayerList in Firebased!");
        } else {
            NSLog(@"Player (%@) has left currentPlayerList",uid);
            if (completionBlock != nil) completionBlock(YES);
        }
    }];
    return;
}


- (void) updateAudioLatency {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    self.audioLatency = session.outputLatency + session.IOBufferDuration + session.inputLatency;
    NSLog(@"The total audio latency is: %f",self.audioLatency);
    
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
