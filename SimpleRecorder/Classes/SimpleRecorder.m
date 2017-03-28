//
//  SimpleRecorder.m
//  ToeicCategoryWord
//
//  Created by Hu Minghua on 2014/05/15.
//  Copyright (c) 2014年 HuMinghua. All rights reserved.
//

#import "SimpleRecorder.h"

#define kDefault_Record_Path      @"RecordedFile"
#define kTipImg                   @"recording_%d.png"

#define IS_LANDSCAPE              UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#define IOS_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark - TipRoundRectView
@interface TipRoundRectView:UIView
- (void)drawRoundRect:(CGRect)rect withRadius:(CGFloat)radius inContext:(CGContextRef)context;
@end

#pragma mark -
@implementation TipRoundRectView

- (void)drawRect:(CGRect)rect {
	[self drawRoundRect:rect withRadius:5.0f inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawRoundRect:(CGRect)rect withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	CGFloat lx = CGRectGetMinX(rect);
	CGFloat cx = CGRectGetMidX(rect);
	CGFloat rx = CGRectGetMaxX(rect);
	CGFloat by = CGRectGetMinY(rect);
	CGFloat cy = CGRectGetMidY(rect);
	CGFloat ty = CGRectGetMaxY(rect);
	
	[[UIColor blackColor] set];
	
	CGContextMoveToPoint(context, lx, cy);
	CGContextAddArcToPoint(context, lx, by, cx, by, radius);
	CGContextAddArcToPoint(context, rx, by, rx, cy, radius);
	CGContextAddArcToPoint(context, rx, ty, cx, ty, radius);
	CGContextAddArcToPoint(context, lx, ty, lx, cy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
}
@end

#pragma mark - RecorderProgressView
@interface RecorderProgressView : UIView
@property (nonatomic) CGFloat    allCount;
@property (nonatomic) CGFloat    curCount;
@end

#pragma mark -
@implementation RecorderProgressView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGRect rectContent   = CGRectInset(rect, 5, 10);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
	[[UIColor clearColor] setFill];
	CGContextFillRect(context, rect);
	
    if (_curCount) {
        
        int i = _curCount / (_allCount / 16);//絵は16枚
        i = MIN(MAX(1, i), 16);
        
        NSString *imgName     = [NSString stringWithFormat:kTipImg, i];
        UIImage *imgCurSrc    = [UIImage imageNamed:imgName];
        CGFloat  ratio        = rectContent.size.height / imgCurSrc.size.height;
        CGRect   rectCurImage = CGRectMake((rectContent.size.width - imgCurSrc.size.width * ratio) / 2,
                                           (rectContent.size.height - imgCurSrc.size.height * ratio) / 2,
                                           imgCurSrc.size.width * ratio,
                                           imgCurSrc.size.height * ratio);
        [imgCurSrc drawInRect:rectCurImage];
    }
    
}
@end

#pragma mark - SimpleRecorder
@implementation SimpleRecorder
{
    NSURL                 *_recordedFile;
    AVAudioPlayer         *_player;
    AVAudioRecorder       *_recorder;
    
    NSTimer               *_timer;
    
    UIView                *_tipView;
    UILabel               *_lblMsg;
    RecorderProgressView  *_imgProgress;
}

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
- (id)init
{
    self = [super init];
    if (self) {
        
        //Default value
        NSURL *URL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _soundPath = [URL URLByAppendingPathComponent:kDefault_Record_Path];
        
        [self prepare];
    }
    
    return self;
}


- (NSURL *)createRecordFilesPathIfNeeds
{
    NSURL         *URL         = _soundPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:URL.path]) {
        [fileManager createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return URL;
}

#pragma - mark
- (NSURL *)recordedFile
{
    [self createRecordFilesPathIfNeeds];
    _recordedFile = [_soundPath URLByAppendingPathComponent:_soundName];
    return _recordedFile;
}
#pragma mark -
- (void)prepare
{
    // 明示的にアクティブにしておく必要があった
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
    
    //音声出力箇所を変更する前に、カテゴリーを指定する必要がある
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
}

- (void)finish
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
 
    //録音停止
    [self stopRecord];
    
    //流れ停止
    [self stopPlay];
}

#pragma mark -
- (void)startRecord
{
    if(!self.isRecording)
    {
        _isRecording = YES;

        if (_delegate && [_delegate respondsToSelector:@selector(recorderStartRecord:)]) {
            [_delegate recorderStartRecord:_soundName];
        }
        
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:0];
        [settings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [settings setValue:[NSNumber numberWithFloat:/*8000.0*/16000.0f] forKey:AVSampleRateKey];
        [settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        [settings setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
        [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        //Encoder
        [settings setValue :[NSNumber numberWithInt:12000] forKey:AVEncoderBitRateKey];
        [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitDepthHintKey];
        [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitRatePerChannelKey];
        [settings setValue :[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
        
        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:[self recordedFile] settings:settings error:&error];
        _recorder.delegate        = self;
        _recorder.meteringEnabled = YES;  //強度を取得するために
        
        [_recorder prepareToRecord];
        [_recorder record];
        
        _player = nil;
        
        if (error) {
            NSLog(@" Error Creating recorder:  %@",[error localizedFailureReason]);
        }
        
        [self showRecordingTip];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refreshTimer) userInfo:nil repeats:YES];
    }else{
        //録音停止
        [self stopRecord];
    }
    
}

- (void)startPlay
{
    if(_player && [_player isPlaying]){
        [self stopPlay];
    }else {
        
        if (![self isExists]) {
            NSLog(@"Error!! -- not exists record file: %@",_soundName);
            return;
        }
        
        NSError *error1, *error2;
        NSData *songFile = [[NSData alloc] initWithContentsOfURL:self.recordedFile options:NSDataReadingMappedIfSafe error:&error1 ];
        _player = [[AVAudioPlayer alloc] initWithData:songFile error:&error2];
        
        if (_player == nil) {
            NSLog(@"Error creating player [error 1]:  %@", [error1 description]);
            NSLog(@"Error creating player [error 2]:  %@", [error2 description]);
        }
        _player.delegate = self;
        
        if (_delegate && [_delegate respondsToSelector:@selector(recorderStartPlay:)]) {
            [_delegate recorderStartPlay:_soundName];
        }

        [_player play];
    }
}

- (void)stopRecord
{
    if(self.isRecording){
        
        _isRecording = NO;
        [_recorder stop];
        _recorder = nil;
    }
    
    [self removeRecordingTip];
    
}
- (void)stopPlay
{
    if (_player && [_player isPlaying]) {
        [_player stop];
        _player = nil;
        
        if (_delegate && [_delegate respondsToSelector:@selector(recorderFinishedPlay:)]) {
            [_delegate recorderFinishedPlay:_soundName];
        }
    }
}
#pragma mark -
- (BOOL)isExists
{
    return [self isExistsSound:_soundName];
}
- (BOOL)isExistsSound:(NSString *)soundName
{
    NSURL         *recordedFile = [self.soundPath URLByAppendingPathComponent:soundName];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    
    return[fileManager fileExistsAtPath:[recordedFile path]];
}

#pragma mark -
- (void)removeSound:(NSString *)soundName
{
    if ([self isExistsSound:soundName]) {
        
        NSURL         *recordedFile = [self.soundPath URLByAppendingPathComponent:soundName];
        NSFileManager *fileManager  = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:recordedFile error:nil];
    }
}
- (void)removeAllSounds
{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.soundPath.path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:self.soundPath.path error:&error];
        if (error) {
            NSLog(@"error: %@", error);
        }
    }
}

#pragma mark - Private Methods
- (void) refreshTimer
{
    if (_isRecording) {
        
        [_recorder updateMeters];
        
        float  power     = [_recorder peakPowerForChannel:0];// -160 ~ 0
        double powerEdt  = pow(10, (0.05 * power)); // 0.000 ~ 1.000
        
        _imgProgress.allCount = 1.0f;
        _imgProgress.curCount = (powerEdt < 0.2) ? powerEdt * 2 : powerEdt;//小さい時の拡大
        [_imgProgress setNeedsDisplay];
        
        if (powerEdt < 0.05) {
            //音声がない時、2秒後で自動停止
            [self performSelector:@selector(autoStopRecord) withObject:nil afterDelay:2.0f];
        }else{
            //音声ある時、自動停止処理をキャンセル
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoStopRecord) object:nil];
        }
        
    }else{
        [_timer invalidate];
        _timer = nil;
        
        [self removeRecordingTip];
    }
    
}
- (void)autoStopRecord
{
    [self stopRecord];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoStopRecord) object:nil];
}

#pragma mark -
- (void)showRecordingTip
{
    
    if (!_tipView) {
        
        CGRect rect  = [[UIScreen mainScreen] bounds];
        _tipView = [[UIView alloc] initWithFrame:CGRectMake((rect.size.width - 200.0f) / 2.0f, rect.size.height / 2.0f, 200.0f, 120.0f)];
        _tipView.opaque          = NO;
        _tipView.backgroundColor = [UIColor clearColor];
        
        if (IS_LANDSCAPE) {
            //iOs 8.0以上の時、下記のローテーションの必要がない by ko 15.04.25
            if (IOS_VERSION_LESS_THAN(@"8.0")) {
                
                if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                    _tipView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }else{
                    _tipView.transform = CGAffineTransformMakeRotation(M_PI_2);
                }
            }
        }
        
        // bg view
        TipRoundRectView *bgAlphaView  = [[TipRoundRectView alloc] initWithFrame:_tipView.bounds];
        bgAlphaView.opaque             = NO;
        bgAlphaView.alpha              = 0.7f;
        [_tipView addSubview:bgAlphaView];
        
        //image icon
        _imgProgress = [[RecorderProgressView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, _tipView.bounds.size.width, _tipView.bounds.size.height)];
        _imgProgress.opaque = NO;
        [_tipView addSubview:_imgProgress];
    }
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_tipView];
    
}
- (void)removeRecordingTip
{
    if (_tipView) {
        [_tipView removeFromSuperview];
        _lblMsg = nil;
        _tipView = nil;
    }
}

#pragma mark - AudioRecorder Delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (_delegate && [_delegate respondsToSelector:@selector(recorderFinishedRecord:)]) {
        [_delegate recorderFinishedRecord:_soundName];
    }
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    _isRecording = NO;
    [recorder stop];
}

#pragma mark - AudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_delegate && [_delegate respondsToSelector:@selector(recorderFinishedPlay:)]) {
        [_delegate recorderFinishedPlay:_soundName];
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [player stop];
}

@end
