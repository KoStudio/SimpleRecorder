//
//  KOViewController.m
//  SimpleRecorder
//
//  Created by KoStudio on 03/28/2017.
//  Copyright (c) 2017 KoStudio. All rights reserved.
//

#import "KOViewController.h"

#import <SimpleRecorder/SimpleRecorder.h>

@interface KOViewController ()<SimpleRecorderDelegate>
@property(nonatomic, strong) SimpleRecorder *recorder;
@end

@implementation KOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recorder = [[SimpleRecorder alloc] init];
    self.recorder.delegate = self;
    self.recorder.soundName = @"record";
    
}

- (IBAction)actionRecord:(id)sender {
    [self.recorder startRecord];
}
- (IBAction)actionPlay:(id)sender {
    [self.recorder startPlay];
}
- (IBAction)actionStop:(id)sender {
    if ([self.recorder isRecording]) {
        [self.recorder stopRecord];
    }
    
    [self.recorder stopPlay];
}


@end
