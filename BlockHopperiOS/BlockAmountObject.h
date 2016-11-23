#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BlockAmountObject : UIView
{
	UITextField *amountField;
	AVAudioPlayer *clickSnd;
}

@property(nonatomic)int amount;

- (id)init :(int)x :(int)y :(AVAudioPlayer *)clickSound;
- (void)leftButtonPressed;
- (void)rightButtonPressed;
- (void)setAmount:(int)num;

@end
