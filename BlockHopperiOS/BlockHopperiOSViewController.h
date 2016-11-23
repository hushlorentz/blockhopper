//
//  BlockHopperiOSViewController.h
//  BlockHopperiOS
//
//  Created by David Samuelsen on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <time.h>
#import <Twitter/Twitter.h>

#import "AssetManager.h"
#import "Block.h"
#import "BlockAmountObject.h"
#import "GameButton.h"
#import "Image.h"
#import "LevelButton.h"
#import "Player.h"
#import "SoundPlayer.h"
#import "Texture2D.h"
#import "Vector2D.h"

#define GRAVITY 8
#define MAP_WIDTH 30
#define MAP_HEIGHT 23
#define TILE_SIZE 32
#define COUNTDOWN_FRAMES 32
#define PORTAL_SPEED 16
#define MAX_JUMP 48
#define JUMP_FORCE 8
#define JUMP_INC 4
#define MAX_SPRING 192
#define SPRING_FORCE 32
#define SPRING_INC 16
#define MAX_USER_BLOCKS 16
#define MAX_MAPS 35
#define MAX_LEVELS_PER_PAGE 18
#define MAX_INTRO_BLOCKS 14
#define MAX_SOUNDS 19 

@interface BlockHopperiOSViewController : UIViewController <UITextFieldDelegate, AVAudioPlayerDelegate, GKAchievementViewControllerDelegate> {

    EAGLContext *context;
    GLuint program;
    
	BOOL twitterIsSupported;
	BOOL loop;
	BOOL randomMusic;
	BOOL musicPlaying;
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;

	int buttonPos[12];
	int levelProgress[MAX_MAPS];
	int levelTimes[MAX_MAPS];
	BOOL introBlocks[MAX_INTRO_BLOCKS];
	BOOL playerHasGold;
	BOOL showBlockIntro;
	BOOL congratsAdded;
	int playerHasDeaths;
	int showEditorWarning;
	int editorButtonsRow;
	int copyBuffer[23][30];
	int copySpecialBuffer[23][30];
	int undoMap[23][30];
	int undoSpecial[23][30];
	int map[23][30];
	int special[23][30];
	int userLevelIDs[4];
	int selectedUser;
	NSString *userList[4];
	NSURLConnection *connection;

	int drawTileHeight;
	int drawTileWidth;
	int drawTileStartX;
	int drawTileStartY;
	int drawPlayerX;
	int drawPlayerY;
	int bgOffsetX;
	int bgOffsetY;
	int setBoost;
	int previousBackground;
	int goldTime;
	int silverTime;
	int bronzeTime;
	int gameType;
	int connectionType;
	int pageNumber;
	int levelsPage;
	long uploadTime;
	int timeoutFrames;
	int cutsceneFrames;
	int okCancelState;
	int editorState;
	int editorOldState;
	int selectedTile;
	int selectedSpecial;
	int switchCounter;
	int loadLevel;
	int levelID;
	int editorDrawStartX;
	int editorDrawStartY;
	int editorBGOffsetX;
	int editorBGOffsetY;
	CGRect activeTextFieldOrigin;
	CGRect selection;
	CGRect copyBounds;
	UIImageView *blockImages[MAX_USER_BLOCKS];
	LevelButton *levelButtons[MAX_LEVELS_PER_PAGE];
	UITextField *levelText[MAX_LEVELS_PER_PAGE];
	BlockAmountObject *blockAmounts[MAX_USER_BLOCKS];
	TWTweetComposeViewController *twitView;
	AssetManager *am;
	UIImageView *networkErrorView;
	UIImageView *bitView;
	UIImageView *fadeView;
	UIImageView *gridView;
	UIImageView *imageView;
	UIImageView *musicVolumeView;
	UIImageView *fxVolumeView;
	UIImageView *hudView;
	UIImageView *imageSubView;
	UIImageView *helpSubView;
	UIButton *ratingButton;
	UIButton *pauseExitButton;
	UIButton *pauseConfigButton;
	UIButton *pauseReturnButton;
	UIButton *pauseRetryButton;
	UIButton *oneStar;
	UIButton *twoStar;
	UIButton *threeStar;
	UIButton *fourStar;
	UIButton *fiveStar;
	UIButton *loginButton;
	UIButton *registerButton;
	UIButton *okConfigButton;
	UIButton *defaultConfigButton;
	UIButton *okButton;
	UIButton *cancelButton;
	UIButton *leftGoldButton;
	UIButton *rightGoldButton;
	UIButton *leftSilverButton;
	UIButton *rightSilverButton;
	UIButton *leftBronzeButton;
	UIButton *rightBronzeButton;
	UIButton *leftBGTypeButton;
	UIButton *rightBGTypeButton;
	UIButton *rightDifficultyButton;
	UIButton *leftDifficultyButton;
	UIButton *menuButton;
	UIButton *userLevelsButton;
	UIButton *startButton;
	UIButton *editorButton;
	UIButton *creditsButton;
	UIButton *backButton;
	UIButton *searchButton;
	UIButton *prevSortButton;
	UIButton *nextSortButton;
	UIButton *prevFilterButton;
	UIButton *nextFilterButton;
	UIButton *prevDirectButton;
	UIButton *nextDirectButton;
	UIButton *nextUserLevelsButton;
	UIButton *prevUserLevelsButton;
	UIButton *firstUserLevelsButton;
	UIButton *prevLevelsButton;
	UIButton *nextLevelsButton;
	UIButton *returnToEditorButton;
	UIButton *nextButton;
	UIButton *returnToLevelsButton;
	UIButton *retryButton;
	Image *bgImage;
	Image *mapTiles;
	Image *specialTiles;
	ALCcontext *mContext;
	ALCdevice *mDevice;
	NSMutableArray *soundBuffers;
	NSMutableArray *soundEffects;
	NSMutableArray *blockQueue;
	NSMutableArray *checkpointBlocks;
	NSMutableArray *blockBkup;
	NSMutableArray *gameState;
	NSMutableArray *buttonsArray;
	NSMutableArray *projectileArray;
	NSMutableArray *billboards;
	NSMutableData *serverData;
	AVAudioPlayer *clickSound;
	AVAudioPlayer *musicPlayer;
	int soundFlags;
	int currentSong;
	int	blocksAvailable[MAX_USER_BLOCKS];
	int blocksBkup[MAX_USER_BLOCKS];
	int	checkpointBlocksAvailable[MAX_USER_BLOCKS];
	int blocksAvailableIndex;
	int configButtonIndex;
	int blockIndex;
	int goalX, goalY;
	int checkpointX, checkpointY;
	int playerStartX, playerStartY;
	int alarm;
	Player *player;
	Block *currentBlock;
	int currentBlockIndex;
	int explosionsCounter;
	int canJump;
	BOOL musicOn;
	BOOL fxOn;
	BOOL connectionInUse;
	BOOL loaded;
	BOOL showIntro;
	BOOL lockButtons;
	int currentLevel;
	int playerDestX;
	int playerDestY;
	int destPortalIndex;
	int counter;
	int checkpointCounter;
	int textIndex;
	int sortIndex;
	int filterIndex;
	int directIndex;
	int editorBGIndex;
	int diffIndex;
	NSArray *blockText;
	NSArray *deathText;
	NSArray *soundPaths;
	NSArray *songPaths;
	NSArray *blockIntroPaths;
	NSArray *helpText;
	NSArray *blockImagePaths;
	NSArray *medalImagePaths;
	NSArray *gameOverPaths;
	NSArray *sortText;
	NSArray *filterText;
	NSArray *directText;
	NSArray *bgText;
	NSArray *diffText;
	NSString *timeString;
	NSString *message;
	NSString *outroMessage;
	NSString *username;
	NSString *password;
	UITextField *blocksAvailableField;
	UITextField *pageField;
	UITextField *registerUsernameField;
	UITextField *registerEmailField;
	UITextField *registerPasswordField1;
	UITextField *registerPasswordField2;
	UITextField *usernameField;
	UITextField *passwordField;
	UITextField *timerField;
	UITextField *blockNumField;
	UITextField *goldTimeField;
	UITextField *silverTimeField;
	UITextField *bronzeTimeField;
	UITextField *editorGoldTimeField;
	UITextField *editorSilverTimeField;
	UITextField *editorBronzeTimeField;
	UITextField *editorBGTypeField;
	UITextField *editorBGField;
	UITextField *diffTextField;
	UITextField *diffField;
	UITextField *sortField;
	UITextField *filterField;
	UITextField *directField;
	UITextField *directInputField;
	UITextField *retryField;
	UITextView *creditsField;
	UITextView *userField1;
	UITextView *userField2;
	UITextView *userField3;
	UITextView *userField4;
	UITextView *introMessageField;
	UITextView *mainMessageField;
	UITextView *errorMessageField;
	UITextView *currentMessageField;
	UITextView *cutsceneMessageField;
	float screenWidth;
	float screenHeight;
	float editorStartX;
	float editorStartY;

	time_t lastTime;
	int frames;
	Vector2D *vec;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)leftButtonDown;
- (void)leftButtonUp;
- (void)rightButtonDown;
- (void)rightButtonUp;

@end
