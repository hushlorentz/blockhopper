#import "BlockAmountObject.h"

@implementation BlockAmountObject

@synthesize amount;

- (id)init :(int)x :(int)y :(AVAudioPlayer *)clickSound
{
	self = [super initWithFrame:CGRectMake(x, y, 96, 32)];

	amount = 0;
	amountField = [[UITextField alloc] initWithFrame:CGRectMake(30, 0, 32, 32)];	
	amountField.textColor = [UIColor whiteColor];
	amountField.font = [UIFont systemFontOfSize:14.0];
	amountField.placeholder = @"";
	amountField.text = [NSString stringWithFormat:@"0"];
	amountField.userInteractionEnabled = NO;
	amountField.hidden = NO;
	amountField.textAlignment = UITextAlignmentCenter;

	clickSnd = clickSound;

	[self addSubview:amountField];

	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.frame = CGRectMake(6, -7, 32, 32);
	[leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	[self addSubview:leftButton];

	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightButton.frame = CGRectMake(54, -8, 32, 32);
	[rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	[self addSubview:rightButton];

	return self;
}

- (void)leftButtonPressed
{
	amount = (amount) ? amount - 1 : 0;
	amountField.text = [NSString stringWithFormat:@"%d", amount];
	[clickSnd play];
}

- (void)rightButtonPressed
{
	amount = (amount < 20) ? amount + 1 : 20;
	amountField.text = [NSString stringWithFormat:@"%d", amount];
	[clickSnd play];
}

- (void)dealloc
{
	[amountField release];
	[super dealloc];
}

- (void)setAmount:(int)num
{
	amount = num;
	amountField.text = [NSString stringWithFormat:@"%d", amount];
}	

@end
