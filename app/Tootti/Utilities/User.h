//
//  User.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//


@interface User: NSObject
@property (readonly) NSString *uid;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSArray *joinedSessions;
@property (strong, nonatomic) NSArray *allMergedSongs;

- (instancetype) initWithUid: (NSString *)uid
                 password: (NSString *)password
                joinedSessions: (NSArray *)joinedSessions
              allMergedSongs: (NSArray *)allMergedSongs;

//Destructor
- (void) logOut;
- (void) shareMusic;


@end


