//
//  Merge.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-03-26.
//

#import "Merge.h"
#import <AVFoundation/AVFoundation.h>

@interface Merge()

@end

@implementation Merge

-(instancetype)init {
    self = [super init];
    self.audioTracks = [[NSMutableArray alloc] init];
    return self;
}

- (instancetype)initWithSettings:(NSDictionary *)settings {
    self = [super init];
    if (self) {
//        _audioName = audioName;
//        _audioURL = audioURL;
    }
//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioURL]
//                                                         error:nil];
//    [self.player setDelegate:self];
    return self;
}

- (void)addAudio:(Audio *)track {
    if(self.audioTracks==nil) {
        self.audioTracks = [[NSMutableArray alloc] init];
    }
    [self.audioTracks addObject:track];
}

-(void)testTrackAtIndex:(NSUInteger)index {
    Audio* track = [self.audioTracks objectAtIndex:index];
    [track playAudio];
}

-(BOOL)performMerge:(NSString *) hostUid
       hostUsername:(NSString *) hostUsername
     mergedFileName:(NSString *) fileName
    completionBlock:(void (^)(BOOL success))completionBlock
{
    NSLog(@"%@",self.audioTracks);
    
    // 1) Create composition
    AVMutableComposition *composition = [AVMutableComposition composition];
    for (Audio *audioTrack in self.audioTracks){
        // 2) Get track as AVAsset
        AVURLAsset* audioURLAsset;
        //TODO: Local filepath not loading to AVURLAsset //Determine whether local or remote URL and initialize AVURLAsset accordingly
        if ([[audioTrack getURL] isFileURL]) {
            audioURLAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:audioTrack.audioURL] options:nil];
        } else {
            audioURLAsset = [[AVURLAsset alloc]initWithURL:[audioTrack getURL] options:nil];
        }
        NSLog(@"URL of %@ is: %@",audioTrack.audioName,audioTrack.audioURL);
        
        // 3) Add track to composition as a AVMutableCompositionTrack
        NSError *error;
        AVMutableCompositionTrack *compTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioURLAsset.duration)
                           ofTrack:[[audioURLAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                            atTime:kCMTimeZero
                             error:&error];
        if (error) {
             NSLog(@"%@", [error localizedDescription]);
          }
    }
    
    // 4) Create AVAsset Export Session
    //TODO: AVAssetExportPresetPassthrough is supposed to allow ".wav" but doesn't seem to work --> using .m4a for now
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    NSString* endFilePath = [NSString stringWithFormat:@"%@%@",fileName,@".m4a"];
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingString:endFilePath];
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:exportPath error:nil];
    }
    _assetExport.outputFileType = AVFileTypeAppleM4A;
    _assetExport.outputURL = exportURL;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
    ^(void ) {
        NSLog(@"Final merged track succesfully saved at: %@",exportURL.absoluteString);
        self.mergedTrack = [[Audio alloc] initWithAudioName:@"mergedtrack" performerUid:hostUid performer:hostUsername audioURL:exportURL.absoluteString];
        //TODO: remove the play portion below once testing is complete
//        if(![self.mergedTrack playAudio]) {
//            NSLog(@"Failed to play!");
//        }
        if (completionBlock != nil) completionBlock(YES);
    }];
    return YES;
}

@end
