//
//  User.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//


@interface User: NSObject
@property (readonly) NSString *uid;
@property (strong, nonatomic) NSString *instrument;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSArray *joinedSessions;
@property (strong, nonatomic) NSArray *allMergedSongs;

- (instancetype) initWithUid: (NSString *)uid
                    email: (NSString *) email
                  instrument: (NSString *)instrument
                joinedSessions: (NSArray *)joinedSessions
              allMergedSongs: (NSArray *)allMergedSongs;

//Destructor
- (void) logOut;
- (void) shareMusic;


@end


