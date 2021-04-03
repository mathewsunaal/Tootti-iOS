//
//  User.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

@import Firebase;
@interface User: NSObject
@property (readonly) NSString *uid;
@property (strong, nonatomic) NSString *instrument;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSArray *joinedSessions;
@property (strong, nonatomic) NSArray *allMergedSongs;

- (instancetype) initWithUid: (NSString *)uid
                    email: (NSString *) email
                    username: (NSString *)username 
                  instrument: (NSString *)instrument
                joinedSessions: (NSArray *)joinedSessions
              allMergedSongs: (NSArray *)allMergedSongs;

//Destructor
- (void) logOut;
- (void) shareMusic;
- (NSArray *) fetchSessions;


@end


