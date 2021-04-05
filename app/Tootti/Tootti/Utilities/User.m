//
//  User.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import "User.h"

@implementation User
//Constructor
- (instancetype) initWithUid: (NSString *)uid
                       email: (NSString *)email
                    username: (NSString *)username
                  instrument: (NSString *)instrument
                joinedSessions:(NSArray *)joinedSessions
              allMergedSongs: (NSArray *) allMergedSongs {
    self = [super init];
    if (self) {
        _uid = uid;
        _email = email;
        _username = username;
        _instrument = instrument;
        _joinedSessions = joinedSessions;
        _allMergedSongs = allMergedSongs;
    }
    return self;
}
-(void) logOut{
    return;
}
- (void) shareMusic {
    return;
}

//TODO: Need to figure out if "joinedSessions" should be a History all sessions joined in the past or only 1 currently active session, this is a placeholder for now
-(void) deleteJoinedSession: (NSString *)session_uid completion:(void (^)(BOOL success))completionBlock
{
    NSMutableArray* joinedSessionsCopy = [self.joinedSessions mutableCopy];
    for (int i=0; i< [_joinedSessions count]; i++){
        if (_joinedSessions[i][@"uid"] == session_uid){
            [ joinedSessionsCopy removeObject:_joinedSessions[i]];
        }
    }
    FIRFirestore *db =  [FIRFirestore firestore];
    FIRDocumentReference *userRef = [[db collectionWithPath:@"user"] documentWithPath:self.uid];
    [userRef updateData:@{
        @"joinedSessions": joinedSessionsCopy
    } completion:^(NSError * _Nullable error) {
        //Save the audioFile to firestore
        NSLog(@"The player related info has been deleted");
        if (completionBlock != nil) completionBlock(YES);
    }];
}

- (NSArray *) fetchSessions{
    //Convert session id to list of session instances
    return self.joinedSessions;
}

@end
