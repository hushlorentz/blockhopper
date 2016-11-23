#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundPlayer : NSObject 
{
}

@property(nonatomic)BOOL isFinished;
- (void)play:(SystemSoundID)sound;
- (id)init;

@end
