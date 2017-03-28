# SimpleRecorder

[![CI Status](http://img.shields.io/travis/KoStudio/SimpleRecorder.svg?style=flat)](https://travis-ci.org/KoStudio/SimpleRecorder)
[![Version](https://img.shields.io/cocoapods/v/SimpleRecorder.svg?style=flat)](http://cocoapods.org/pods/SimpleRecorder)
[![License](https://img.shields.io/cocoapods/l/SimpleRecorder.svg?style=flat)](http://cocoapods.org/pods/SimpleRecorder)
[![Platform](https://img.shields.io/cocoapods/p/SimpleRecorder.svg?style=flat)](http://cocoapods.org/pods/SimpleRecorder)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![sample gif](https://github.com/KoStudio/SimpleRecorder/blob/master/SimpleRecorderSample.gif)

Property Definition

```Objective-c
@property(nonatomic, strong) SimpleRecorder *recorder;
```


```Objective-c
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
```

Delegate Methods

```Objective-C
@protocol SimpleRecorderDelegate<NSObject>

@optional
- (void) recorderStartRecord:(NSString *)soundName;
- (void) recorderFinishedRecord:(NSString *)soundName;
- (void) recorderStartPlay:(NSString *)soundName;
- (void) recorderFinishedPlay:(NSString *)soundName;

@end
```
## Requirements

## Installation

SimpleRecorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SimpleRecorder"
```

## Author

KoStudio, 44663768@163.com

## License

SimpleRecorder is available under the MIT license. See the LICENSE file for more info.
