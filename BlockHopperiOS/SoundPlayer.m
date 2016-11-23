#import "SoundPlayer.h"

@implementation SoundPlayer

@synthesize isFinished;

void audioDidFinish(SystemSoundID sound, void *isFinished);

- (id)init
{
	self = [super init];

	isFinished = true;

	return self;
}

- (void)play:(SystemSoundID)sound
{
	isFinished = false;
	AudioServicesAddSystemSoundCompletion(sound, NULL, NULL, audioDidFinish, &isFinished);
	AudioServicesPlaySystemSound(sound);
}

void audioDidFinish(SystemSoundID sound, void *isFinished)
{
	*(BOOL *)isFinished = true;
	AudioServicesRemoveSystemSoundCompletion(sound);
}

- (void)dealloc
{
	[super dealloc];
}

@end
