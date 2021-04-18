//
//  Audio.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-02-28.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "User.h"
#import "ActivityIndicator.h"

@import Firebase;

@interface Audio() <AVAudioPlayerDelegate>

@end
@implementation Audio
//Constructor

- (instancetype) initWithAudioName:(NSString *)audioName
                      performerUid: (NSString *)performerUid
                         performer: (NSString *)performer
                                audioURL:(NSString *)audioURL{
    self = [super init];
    if (self) {
        _audioName = audioName;
        _performer = performer;
        _performerUid = performerUid;
        _audioURL = audioURL;
    }
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:audioURL]
                                                         error:nil];
    [self.player setDelegate:self];
    return self;
}

- (instancetype) initWithRemoteAudioName:(NSString *)audioName
                            performerUid: (NSString *)performerUid
                               performer: (NSString *)performer
                                audioURL:(NSURL *)audioURL {
    self = [super init];
    if (self) {
        //NSData *urlData = [NSData dataWithContentsOfURL:audioURL];
        _audioName = audioName;
        _performer = performer;
        _performerUid = performerUid;
        _audioURL = [audioURL absoluteString] ;
        //self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:_audioURL] error:nil];
        self.player = [[AVAudioPlayer alloc]  initWithData: [NSData dataWithContentsOfURL:audioURL] error:nil];
        [self.player setDelegate:self];
        }
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
    
- (void) uploadAudioSound: (NSString *) userUid
               sessionUid: (NSString *) sessionUid
                 username: (NSString *) username
          completionBlock:(void (^)(BOOL success, NSURL *finalDownloadURL))completionBlock {
    //upload the audio sound to fire storage
    FIRStorage *storage = [FIRStorage storage];
    FIRFirestore *db =  [FIRFirestore firestore];
    //FIRStorageReference *storageRef = [storage reference];
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"audio/wav";
    NSString *audioFilePath = [NSString stringWithFormat:@"gs://ece1778tooti.appspot.com/%@/%@/%@.wav", userUid, sessionUid, self.audioName];
    NSLog(@"%@", audioFilePath);
    NSLog(@"%@", self.audioURL);
    NSURL *dataFile =  [NSURL URLWithString:self.audioURL];
    //NSData *data = [NSData dataWithContentsOfFile:self.audioURL];
    FIRStorageReference *audioRef = [storage referenceForURL: audioFilePath];
    FIRStorageUploadTask *uploadTask = [audioRef putFile: dataFile metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
      if (error != nil) {
          NSLog(@"Error detecting in uploading Library track to Firebase");
      } else {
        // You can also access to download URL after upload.
        [audioRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
          if (error != nil) {
              NSLog(@"%@", error.localizedDescription);
          } else {
            NSURL *downloadURL = URL;
              NSMutableDictionary *audioDict = [NSMutableDictionary new];
              audioDict[@"uid"] = userUid;
              audioDict[@"username"] = username;
              audioDict[@"audioName"] = self.audioName;
              audioDict[@"url"] = [downloadURL absoluteString];
              //save the downloadURL to firestorage
              FIRDocumentReference *sessionRef =
                  [[db collectionWithPath:@"session"] documentWithPath:sessionUid];
              [sessionRef updateData:@{
                  @"guestPlayerList": [FIRFieldValue fieldValueForArrayUnion:@[audioDict]]
              } completion:^(NSError * _Nullable error) {
                  //Save the audioFile to firestore
                  NSLog(@"Library audio file successfully");
                  NSLog(@"Dowload URL is %@", downloadURL);
                  if (completionBlock != nil) completionBlock(YES,downloadURL);
              }];
          }
        }];
      }
    }];
    return;
}


- (void) uploadTypedAudioSound: (NSString *) userUid
               sessionUid: (NSString *) sessionUid
                      audioType: (NSString *) audioType
               completionBlock:(void (^)(BOOL success, NSURL *finalDownloadURL))completionBlock
                    {
    //upload the audio sound to fire storage
    FIRStorage *storage = [FIRStorage storage];
    FIRFirestore *db =  [FIRFirestore firestore];
    //FIRStorageReference *storageRef = [storage reference];
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"audio/wav";
    NSString *audioFilePath = [NSString stringWithFormat:@"gs://ece1778tooti.appspot.com/%@/%@/%@.wav", userUid, sessionUid, self.audioName];
    NSURL *dataFile =  [NSURL URLWithString:self.audioURL];
    //NSData *data = [NSData dataWithContentsOfFile:self.audioURL];
    FIRStorageReference *audioRef = [storage referenceForURL: audioFilePath];
    FIRStorageUploadTask *uploadTask = [audioRef putFile: dataFile metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
      if (error != nil) {
          NSLog(@"%@", error.localizedDescription);
          [[ActivityIndicator sharedInstance] stop];
        // Uh-oh, an error occurred!
      } else {
        // You can also access to download URL after upload.
        [audioRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
          if (error != nil) {
              NSLog(@"%@", error.localizedDescription);
          } else {
            NSURL *downloadURL = URL;
              //save the downloadURL to firestorage
              FIRDocumentReference *sessionRef =
                  [[db collectionWithPath:@"session"] documentWithPath:sessionUid];
              [sessionRef updateData:@{
                  audioType: [downloadURL absoluteString]
              } completion:^(NSError * _Nullable error) {
                  //Save the audioFile to firestore
                  NSLog(@"The merged result is saved successfully");
                  NSLog(@"Download URL is %@", downloadURL);
                  if (completionBlock != nil) completionBlock(YES,downloadURL);
              }];
          }
        }];
      }
    }];
    return;
}

-(void) deleteAudioTrack: (NSString *) userUid
              sessionUid: (NSString *) sessionUid
         guestPlayerList:(NSArray *)guestPlayerList
         completionBlock:(void (^)(BOOL success))completionBlock{
    // Only use the audioName to update the information
    FIRStorage *storage = [FIRStorage storage];
    FIRFirestore *db =  [FIRFirestore firestore];
    NSString *audioFilePath = [NSString stringWithFormat:@"gs://ece1778tooti.appspot.com/%@/%@/%@.wav", userUid, sessionUid, self.audioName];
    // Create a reference to the file to delete
    FIRStorageReference *audioRef = [storage referenceForURL: audioFilePath];
    // Delete the file
    [audioRef deleteWithCompletion:^(NSError *error){
      if (error != nil) {
          NSLog(@"There is an error deleting the audio file. %@", error);
      } else {
        // File deleted successfully
          FIRDocumentReference *sessionRef =
              [[db collectionWithPath:@"session"] documentWithPath:sessionUid];
          [sessionRef updateData:@{
              @"guestPlayerList": guestPlayerList
          } completion:^(NSError * _Nullable error) {
              //Save the audioFile to firestore
              NSLog(@"The audioTrack is deleted successfully");
              if (completionBlock != nil) completionBlock(YES);
          }];
      }
    }];
        
}


- (NSArray *) convertAVToArr{
    /* Use local file
    NSString *urlString = [[NSBundle mainBundle] pathForResource:_audioName ofType:@".wav"];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:urlString] options:[NSDictionary dictionary]];
    */
    //Use remoteURL
    NSData *audioBytesData = [self readSoundFileSamplesHelper];
    NSURL *playUrl = [ NSURL URLWithString: self.audioURL ];
    
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

#pragma mark - Getter methods

-(NSURL *)getURL {
    return [NSURL URLWithString:self.audioURL];
}

@end
