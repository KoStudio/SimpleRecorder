//
//  SimpleRecorder.h
//  SimpleRecorder
//
//  Created by Hu Minghua on 2014/05/15.
//  Copyright (c) 2014年 HuMinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol SimpleRecorderDelegate;
@interface SimpleRecorder : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(nonatomic, readonly) BOOL                        isRecording;
@property(nonatomic, strong)   NSString                   *soundName;//録音の名前 eg: 1.mp3
@property(nonatomic, strong)   NSURL                      *soundPath;//保存するフォルダ  規定値は: [NSDocumentDirectory() stringByAppendingString:@"RecordedFiles"]]
@property(nonatomic, weak)     id<SimpleRecorderDelegate>  delegate;

- (void)prepare;
- (void)finish;

- (void)startRecord;
- (void)startPlay;

- (void)stopRecord;
- (void)stopPlay;


- (BOOL)isExists;//self.soundName
- (BOOL)isExistsSound:(NSString *)soundName;
- (void)removeSound:(NSString *)soundName;
- (void)removeAllSounds;
@end

#pragma mark -
@protocol SimpleRecorderDelegate<NSObject>

@optional
- (void) recorderStartRecord:(NSString *)soundName;
- (void) recorderFinishedRecord:(NSString *)soundName;
- (void) recorderStartPlay:(NSString *)soundName;
- (void) recorderFinishedPlay:(NSString *)soundName;

@end
