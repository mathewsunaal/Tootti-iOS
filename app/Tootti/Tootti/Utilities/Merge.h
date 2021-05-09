//
//  Merge.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-26.
//

#import <Foundation/Foundation.h>
#import "Audio.h"

NS_ASSUME_NONNULL_BEGIN

@interface Merge : NSObject
@property (nonatomic,strong) NSMutableArray *audioTracks;
@property (nonatomic,strong) Audio *mergedTrack;


- (instancetype)initWithSettings:(NSDictionary *)settings;
- (void)addAudio:(Audio *)track;
-(BOOL)performMerge:(NSString *) hostUid
       hostUsername:(NSString *) hostUsername
     mergedFileName:(NSString *) fileName
    completionBlock:(void (^)(BOOL success))completionBlock;

//TODO: delete after
-(void)testTrackAtIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
