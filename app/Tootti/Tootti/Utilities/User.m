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
                  instrument: (NSString *)instrument
                joinedSessions:(NSArray *)joinedSessions
              allMergedSongs: (NSArray *) allMergedSongs {
    self = [super init];
    if (self) {
        _uid = uid;
        _email = email;
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

@end
