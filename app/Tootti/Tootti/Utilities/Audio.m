//
//  Audio.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import "Audio.h"

@interface Audio() <AVAudioPlayerDelegate>

@end
@implementation Audio
//Constructor
- (instancetype) initWithAudioName: (NSString *)audioName
                        audioSound: (NSString *)audioSound
                         performer: (NSString *)performer
                  configDictionary: (NSDictionary *)configDictionary
                         sessionId: (NSString *)sessionId
                         audioType: (NSString *)audioType
                               uid: (NSString *)uid {
    self = [super init];
    if (self) {
        _uid = uid;
        _audioName= audioName;
        _performer = performer;
        _configDictionary = configDictionary;
        _audioSound= audioSound;
        _audioType = audioType;
        _audioType = audioType;
    }
    return self;
}

- (instancetype) initWithAudioName:(NSString *)audioName
                                audioURL:(NSString *)audioURL{
    self = [super init];
    if (self) {
        _audioName = audioName;
        _audioURL = audioURL;
    }
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioURL]
                                                         error:nil];
    [self.player setDelegate:self];
    return self;
}

- (BOOL)playAudio {
    return  [self.player play];
}

-(BOOL)playAudioAtTime:(NSTimeInterval)time {
    return [self.player playAtTime:time];
}

- (void)pauseAudio {
    return [self.player pause];
}

- (void)stopAudio {
    return [self.player stop];
}
    
- (AVAudioPlayer* ) getAudioSound{
    return [AVAudioPlayer alloc];
}
- (void) uploadAudioSound {
    return;
}
- (NSArray *) convertAVToArr{
    /* Use local file
    NSString *urlString = [[NSBundle mainBundle] pathForResource:_audioName ofType:@".wav"];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:urlString] options:[NSDictionary dictionary]];
    */
    //Use remoteURL
    NSData *audioBytesData = [self readSoundFileSamplesHelper];
    NSURL *playUrl = [NSURL URLWithString: self.audioURL];
    
    NSLog(@"%@", playUrl);
    AVURLAsset* audioAsset = [self getAVAssetFromRemoteUrl: playUrl];
    CMTime audioDuration = audioAsset.duration;
    NSLog(@"%f", CMTimeGetSeconds(audioDuration));
    NSArray *audioArrayData =[self arrayFromDataHelper: audioBytesData songLengthIs: CMTimeGetSeconds(audioDuration)];
    return audioArrayData;
}
//- (NSData *)readSoundFileSamplesHelper:(NSString *)filePath
- (NSData *)readSoundFileSamplesHelper
{
    // Get raw PCM data from the track
    /*Local URL
    NSDictionary *opts = [NSDictionary dictionary];
    NSURL *assetURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:assetURL options:opts];
    */
    NSMutableData *data = [[NSMutableData alloc] init];
    const uint32_t sampleRate = 16000; // 16k sample/sec
    const uint16_t bitDepth = 16; // 16 bit/sample/channel
    const uint16_t channels = 2; // 2 channel/sample (stereo)
    //Remote URL
    NSURL *playUrl = [NSURL URLWithString:_audioURL];
    NSLog(@"%@", playUrl);
    AVURLAsset* asset = [self getAVAssetFromRemoteUrl: playUrl];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:NULL];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                              [NSNumber numberWithFloat:(float)sampleRate], AVSampleRateKey,
                              [NSNumber numberWithInt:bitDepth], AVLinearPCMBitDepthKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                              [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey, nil];

    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:[[asset tracks] objectAtIndex:0] outputSettings:settings];
    [reader addOutput:output];
    [reader startReading];

    // read the samples from the asset and append them subsequently
    while ([reader status] != AVAssetReaderStatusCompleted) {
        CMSampleBufferRef buffer = [output copyNextSampleBuffer];
        if (buffer == NULL) continue;

        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(buffer);
        size_t size = CMBlockBufferGetDataLength(blockBuffer);
        uint8_t *outBytes = malloc(size);
        CMBlockBufferCopyDataBytes(blockBuffer, 0, size, outBytes);
        CMSampleBufferInvalidate(buffer);
        CFRelease(buffer);
        [data appendBytes:outBytes length:size];
        free(outBytes);
    }
    return data;
}

- (AVURLAsset*)getAVAssetFromRemoteUrl:(NSURL*)url
{
    if (!NSTemporaryDirectory())
    {
       // no tmp dir for the app (need to create one)
    }
    [self clearTmpDirectory];
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"temp"] URLByAppendingPathExtension:@"wav"];
    NSLog(@"fileURL: %@", [fileURL path]);

    NSData *urlData = [NSData dataWithContentsOfURL:url];
    [urlData writeToURL:fileURL options:NSAtomicWrite error:nil];

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:[NSDictionary dictionary]];
    return asset;
}

- (AVURLAsset*)getAVAssetFromLocalUrl:(NSURL*)url
{
    AVURLAsset *asset =  [[AVURLAsset alloc] initWithURL:url options:[NSDictionary dictionary]];
    return asset;
}



-(NSArray *) arrayFromDataHelper: (NSData *) data songLengthIs: (float)seconds {
    NSMutableArray *ary = [NSMutableArray array];
    NSMutableArray *movingavgAry = [NSMutableArray array];
    NSArray *finalAry = [NSMutableArray array];
    const void *bytes = [data bytes];
    for (NSUInteger i = 0; i < [data length]; i += sizeof(int32_t)) {
        int32_t elem = OSReadLittleInt32(bytes, i);
        [ary addObject:[NSNumber numberWithInt:elem]];
    }
    NSLog(@"%d", (int)[ary count]);
    NSLog(@"%f", seconds);
    int interval = (int)[ary count] / (int)seconds;
    NSLog(@"%d", interval);
    for (NSUInteger i = 0; i <seconds; i++){
        NSRange theRange;
        theRange.location = i*interval;
        if (i*interval + interval >= [ary count]){
            theRange.length = (int)[ary count] - i*interval-1;
        }
        else {
            theRange.length =  interval;
        }
        NSNumber* sum = [[ary subarrayWithRange:theRange] valueForKeyPath: @"@sum.self"];
        [movingavgAry addObject:sum];
    }
    NSLog(@"%d", [movingavgAry count]);
    finalAry = [self normArrayHelper: movingavgAry];
    NSLog(@"%d", [finalAry count]);
    return finalAry;
}


-(NSArray *) normArrayHelper: (NSMutableArray *) data{
    NSNumber* min = [data valueForKeyPath:@"@min.self"];
    float Intmin = [min floatValue];
    NSNumber* max = [data valueForKeyPath:@"@max.self"];
    float Intmax = [max floatValue];
    NSMutableArray *finalArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < [data count]; i ++){
        NSNumber *num = data[i];
        int Intnum = [num intValue];
        float elem = ((float) Intnum -  Intmin) / (Intmax - Intmin);
        [finalArray addObject:[NSNumber numberWithFloat:elem]];
    }
    return finalArray;
}
- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

@end
