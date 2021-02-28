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
                    password: (NSString *)password
                joinedSessions:(NSArray *)joinedSessions
              allMergedSongs: (NSArray *) allMergedSongs {
    self = [super init];
    if (self) {
        _uid = uid;
        _password = password;
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
