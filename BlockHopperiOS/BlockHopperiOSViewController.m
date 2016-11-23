//  BlockHopperiOSViewController.m
//  BlockHopperiOS
//
//  Created by David Samuelsen on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>
#import <time.h>

#import "Animation.h"
#import "AnimData.h"
#import "AnimObject.h"
#import "Billboard.h"
#import "BlockHopperiOSViewController.h"
#import "EAGLView.h"
#import "GameButton.h"
#import "Projectile.h"
#import "Tile.h"
#import "Utils.h"

#define MAX_USER_LEVELS 4
#define EDITOR_OFFSET_X 32
#define EDITOR_OFFSET_Y 2
#define ALPHA_FADE_INCREMENT 0.1f
#define MAX_COUNTER 5563636
#define SWITCH_COUNTER_FRAMES 16
#define SPLASH_FRAMES 64 
#define MAX_TEXT_PER_DEATH 4
#define MAX_TIMEOUT_FRAMES 300
#define UPLOAD_WAIT_TIME 300 //5 mins in seconds

#define EDITOR_NO_PLAYER_NO_GOAL 0
#define EDITOR_PLAYER 1
#define EDITOR_GOAL 2
#define EDITOR_HAS_PLAYER_AND_GOAL 3

#define VOLUME_NORMAL 1.0f
#define VOLUME_BLOCKMODE 1.0f

enum
{
	STATE_PLAY,
	STATE_GAMEOVER,
	STATE_LOAD_MAP,
	STATE_PORTAL,
	STATE_PAUSE,
	STATE_RESULTS,
	STATE_LEVEL_INTRO,
	STATE_COUNTDOWN,
	STATE_LEVEL_INIT,
	STATE_PRINT_INTRO_TEXT,
	STATE_GREEN_PIXEL_SPLASH,
	STATE_STARSHIP_SPLASH,
	STATE_PLACE_BLOCKS,
	STATE_TAP_TO_CONTINUE,
	STATE_MAIN_MENU,
	STATE_INTRO_MESSAGE,
	STATE_PRINT_INTRO_MESSAGE,
	STATE_USER_LEVELS,
	STATE_USER_LEVELS_SEARCH,
	STATE_LEVEL_SELECT,
	STATE_EDITOR,
	STATE_RELOAD_MAP,
	STATE_FADE_IN,
	STATE_FADE_OUT,
	STATE_REMOVE_LEVEL_SELECT_ELEMENTS,
	STATE_CLEAR_OPENGL,
	STATE_REMOVE_UI_ELEMENTS,
	STATE_ADD_LEVEL_SELECT_ELEMENTS,
	STATE_INCREMENT_LEVEL,
	STATE_BLOCK_INTRO,
	STATE_CHECKPOINT_INTRO,
	STATE_GP_SPLASH,
	STATE_ADD_SA_SPLASH,
	STATE_SA_SPLASH,
	STATE_ADD_MAIN_MENU,
	STATE_CREDITS,
	STATE_EDITOR_POPUP,
	STATE_REMOVE_HELP_MESSAGE,
	STATE_ADD_OK_CANCEL,
	STATE_OK_CANCEL,
	STATE_INVALID_PASSWORD,
	STATE_SAVE_AND_UPLOAD,
	STATE_LOGIN,
	STATE_LEVEL_UPLOAD_SUCCESS,
	STATE_REGISTER_ERROR,
	STATE_REGISTER_SUCCESS,
	STATE_ALL_GOLD,
	STATE_CUTSCENE,
	STATE_SETUP_CUTSCENE,
	STATE_CUTSCENE_TEXT1,
	STATE_CUTSCENE_TEXT2,
	STATE_CUTSCENE_TEXT3,
	STATE_CUTSCENE_TEXT4,
	STATE_CUTSCENE_TEXT5,
	STATE_CUTSCENE_TEXT6,
	STATE_CUTSCENE_TEXT7,
	STATE_REMOVE_CUTSCENE_TEXT,
	STATE_REMOVE_LAST_STATE,
	STATE_LEVEL_INPUT_ERROR,
	STATE_REMOVE_MAIN_MENU,
	STATE_ADD_CREDITS,
	STATE_REMOVE_CREDITS,
	STATE_ADD_EDITOR,
	STATE_REMOVE_EDITOR,
	STATE_ADD_USER_LEVEL_ELEMENTS,
	STATE_WAITING_FOR_NETWORK,
	STATE_REQUEST_USER_LEVEL,
	STATE_REMOVE_USER_LEVEL_ELEMENTS,
	STATE_NETWORK_ERROR,
	STATE_RATING,
	STATE_ADD_TWITTER_DIALOG,
	STATE_ADD_LOGIN_ELEMENTS,
	STATE_INIT_OPENFEINT,
	STATE_OPENFEINT,
	STATE_CONFIG_BUTTONS,
};

enum
{
	EDITOR_STATE_SELECTION = 0,
	EDITOR_STATE_PEN = 1,
	EDITOR_STATE_FILL = 2,
	EDITOR_STATE_ERASE = 3,
	EDITOR_STATE_PASTE = 7,
	EDITOR_STATE_MOVE = 8,
	EDITOR_STATE_MAP_PROPERTIES = 9,
	EDITOR_STATE_TILES = 10,
	EDITOR_STATE_HELP = 12,
};

enum
{
	EDITOR_HELP_SELECTION,
	EDITOR_HELP_PEN,
	EDITOR_HELP_FILL,
	EDITOR_HELP_ERASE,
	EDITOR_HELP_UNDO,
	EDITOR_HELP_CUT,
	EDITOR_HELP_COPY,
	EDITOR_HELP_PASTE,
	EDITOR_HELP_MAP_PROPERTIES,
	EDITOR_HELP_TILES,
	EDITOR_HELP_RUN,
	EDITOR_HELP_MOVE,
	EDITOR_HELP_UP_ARROW,
	EDITOR_HELP_QUIT,
	EDITOR_HELP_SAVE,
	EDITOR_HELP_NEW,
	EDITOR_HELP_UPLOAD,
	EDITOR_HELP_DOWN_ARROW,
};

enum
{
	EDITOR_POPUP_INTRO = 1,
	EDITOR_POPUP_UPLOAD = 1 << 1,
};

enum
{
	CONNECTION_TYPE_USER_LEVELS,
	CONNECTION_TYPE_LOAD_USER_LEVEL,
	CONNECTION_TYPE_UPLOAD_USER_LEVEL,
	CONNECTION_TYPE_LOGIN_USER,
	CONNECTION_TYPE_REGISTER_USER,
};

enum
{
	GAME_TYPE_USER_LEVEL = 1,
	GAME_TYPE_STOCK_LEVEL = 2,
	GAME_TYPE_EDITOR_LEVEL = 3,
};

enum
{
	JUMP_CLEAR = 0,
	JUMP_BUTTON_DOWN = 1,
	JUMP_IN_AIR = 1 << 1,
};

enum
{
	OK_CANCEL_STATE_SAVE,
	OK_CANCEL_STATE_NEW,
	OK_CANCEL_STATE_QUIT,
	OK_CANCEL_STATE_REGISTER,
	OK_CANCEL_STATE_TWITTER,
};

enum
{
	DEATH_FALLING,
	DEATH_BLADE,
	DEATH_LASER,
	DEATH_SPIKES,
	DEATH_SQUISH,
	DEATH_FIRE,
	DEATH_EXPLOSION,
	DEATH_SHOT,
	DEATH_LAVA,
	MAX_DEATHS,
};

enum
{
	SONG_MENU,
	SONG_FACTORY,
	SONG_GRASS,
	SONG_CITY,
	SONG_SPACE,
	SONG_UNDERGROUND,
	SONG_ERROR,
};

enum
{
	SOUND_JUMP,
	SOUND_TNT,
	SOUND_GOAL,
	SOUND_ADD_BLOCK,
	SOUND_BUBBLE_POP,
	SOUND_CRYSTAL,
	SOUND_FIRE,
	SOUND_GUN,
	SOUND_PORTAL,
	SOUND_SPIKES,
	SOUND_SPRINGBOARD,
	SOUND_BUTTON,
	SOUND_EXPLODE,
	SOUND_COLLIDE,
	SOUND_BLOCKMODE,
	SOUND_CLICK,
	SOUND_SWITCH,
	SOUND_CHECKPOINT,
	SOUND_FIREWORKS,
	NUM_SOUNDS,
};

enum
{
	INTRO_BLADE,
	INTRO_BOMB,
	INTRO_CONVEYOR,
	INTRO_CRYSTAL,
	INTRO_DEFAULT,
	INTRO_FIRE,
	INTRO_GUN,
	INTRO_INVISIBLE,
	INTRO_LEFTRIGHT,
	INTRO_PORTAL,
	INTRO_SPIKE,
	INTRO_SPRING,
	INTRO_UPDOWN,
	INTRO_CHECKPOINT,
};

enum
{
	BUTTON_LEFT_INDEX,
	BUTTON_RIGHT_INDEX,
	BUTTON_DOWN_INDEX,
	BUTTON_UP_INDEX,
	BUTTON_BLOCKLEFT_INDEX,
	BUTTON_BLOCKRIGHT_INDEX,
	BUTTON_OK_INDEX,
	BUTTON_PREV_BLOCK_INDEX,
	BUTTON_NEXT_BLOCK_INDEX,
	BUTTON_SELF_DESTRUCT_INDEX,
	BUTTON_NEXT_MAP_INDEX,
	BUTTON_COUNT,
};

enum 
{
	MEDAL_TYPE_NONE,
	MEDAL_TYPE_BRONZE,
	MEDAL_TYPE_SILVER,
	MEDAL_TYPE_GOLD,
};


// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

/**** ACHIEVEMENT CODES
	
	All deaths  - 1482212
	All gold    - 1482222
	City 		- 1482432
	Factory		- 1482442
	Grass		- 1482462
	Space		- 1482472
	Underground - 1482482
	Rate Level	- 1482502
	Upload		- 1482522

*****/	

@interface BlockHopperiOSViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (BOOL)allLevelsHaveGold;
- (int)getGameState;
- (int)checkForGoalAndPlayerStart;
- (void)initOpenAL;
- (void)cancelConnection;
- (void)playSound:(int)index;
- (void)removeDuplicatePlayerAndGoal;
- (void)validateRegistration;
- (void)loginButtonPressed;
- (void)registerButtonPressed;
- (void)okButtonPressed;
- (void)cancelButtonPressed;
- (void)startButtonPressed;
- (void)creditsButtonPressed;
- (void)setupEditor;
- (void)editorButtonPressed;
- (void)menuButtonPressed;
- (void)userLevelsButtonPressed;
- (void)backButtonPressed;
- (void)searchButtonPressed;
- (void)prevSortButtonPressed;
- (void)nextSortButtonPressed;
- (void)prevFilterButtonPressed;
- (void)nextDirectButtonPressed;
- (void)prevDirectButtonPressed;
- (void)nextUserLevelsButtonPressed;
- (void)prevUserLevelsButtonPressed;
- (void)firstUserLevelsButtonPressed;
- (void)nextLevelsButtonPressed;
- (void)prevLevelsButtonPressed;
- (void)returnToEditorButtonPressed;
- (void)retryButtonPressed;
- (void)returnToLevelsButtonPressed;
- (void)nextButtonPressed;
- (void)leftDifficultyButtonPressed;
- (void)rightDifficultyButtonPressed;
- (void)leftGoldButtonPressed;
- (void)rightGoldButtonPressed;
- (void)leftSilverButtonPressed;
- (void)rightSilverButtonPressed;
- (void)leftBronzeButtonPressed;
- (void)rightBronzeButtonPressed;
- (void)leftBGTypeButtonPressed;
- (void)rightBGTypeButtonPressed;
- (void)pauseMenuExitPressed;
- (void)pauseMenuConfigPressed;
- (void)pauseMenuReturnPressed;
- (void)pauseMenuRetryPressed;
- (void)oneStarPressed;
- (void)twoStarPressed;
- (void)threeStarPressed;
- (void)fourStarPressed;
- (void)fiveStarPressed;
- (void)sendRating:(int)rating;
- (void)ratingButtonPressed;
- (void)playSong:(int)index repeats:(BOOL)rpt;
- (void)setupButtons;
- (void)resetMap;
- (void)saveEditorFile;
- (void)loadEditorFile;
- (void)setEditorBG;
- (void)drawGame;
- (void)drawEditor;
- (void)updateCutscene;
- (void)setupCutscene;
- (void)drawCutscene;
- (void)showIntroBlock :(int)blockType;
- (void)updatePlayer;
- (void)updateProjectiles;
- (Projectile *)getAvailableProjectile;
- (Billboard *)getAvailableBillboard;
- (void)convertTime:(int)time;
- (void)convertUserTime:(UITextField *)textField :(int)time;
- (void)killPlayer:(int)type;
- (void)updateBlocks;
- (void)updatePortal;
- (void)updateLevelIntro;
- (BOOL)playerMoveDown:(int)dist;
- (BOOL)playerMoveUp:(int)dist;
- (BOOL)playerMoveLeft:(int)dist;
- (BOOL)playerMoveRight:(int)dist;
- (void)goalPlayer;
- (void)leftButtonDown;
- (void)leftButtonUp;
- (void)rightButtonDown;
- (void)rightButtonUp;
- (void)downButtonDown;
- (void)downButtonUp;
- (void)upButtonUp;
- (void)upButtonDown;
- (void)loadNextLevel;
- (void)reloadLevel;
- (void)loadEditorLevel;
- (void)loadUserLevel:(NSString *)levelData;
- (void)copyBlock:(Block *)dest :(Block *)src;
- (void)centerWorld;
- (void)selectButtonGroup:(int)buttonGroup;
- (void)setupLasers;
- (void)setupMessage:(NSString *)msg :(UITextView *)view;
- (void)setImageView:(NSString *)imagePath :(UIImageView *)view :(int)x :(int)y;
- (void)resetLasers:(Block *)block;
- (void)setupCrystals;
- (void)getBlockIndex:(int)search;
- (void)uploadUserLevel;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)saveProgress;
- (void)loadProgress;
- (BOOL)loadLogin;
- (void)saveLogin;
- (IBAction)showAchievements;
@end

@implementation BlockHopperiOSViewController

@synthesize animating;
@synthesize context;
@synthesize displayLink;

- (void)awakeFromNib
{
//    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
}

- (void)dealloc
{
	int i;

    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

	if (twitterIsSupported)
	{
		[twitView release];
	}

	[connection release];
	[am release];
	[bgImage release];
	[mapTiles release];
	[specialTiles release];
	[player release];
	[serverData release];
	[blockQueue release];
	[blockBkup release];
	[checkpointBlocks release];
	[gameState release];
	[buttonsArray release];
	[retryField release];
	[usernameField release];
	[passwordField release];
	[registerUsernameField release];
	[registerEmailField release];
	[registerPasswordField1 release];
	[registerPasswordField2 release];
	[creditsField release];
	[blockText release];
	[helpText release];
	[bgText release];
	[diffText release];
	[deathText release];
	[soundPaths release];
	[songPaths release];
	[medalImagePaths release];
	[blockIntroPaths release];
	[blockImagePaths release];
	[gameOverPaths release];
	[sortText release];
	[filterText release];
	[directText release];
	[currentBlock release];
    [context release];
	[vec release];
	[projectileArray release];
	[billboards release];
	[editorBGTypeField release];
	[editorBGField release];
	[timerField release];
	[introMessageField release];
	[mainMessageField release];
	[errorMessageField release];
	[cutsceneMessageField release];
	[userField1 release];
	[userField2 release];
	[userField3 release];
	[userField4 release];
	[message release];
	[username release];
	[password release];
   	[blockNumField release];
	[gridView release];
	[imageView release];
	[imageSubView release];
	[musicVolumeView release];
	[fxVolumeView release];
	[helpSubView release];
	[networkErrorView release];
	[fadeView release];
	[hudView release];
	[goldTimeField release];
	[silverTimeField release];
	[bronzeTimeField release];
	[editorGoldTimeField release];
	[editorSilverTimeField release];
	[editorBronzeTimeField release];
	[diffField release];
	[diffTextField release];
	[sortField release];
	[filterField release];
	[directField release];
	[directInputField release];
	[clickSound release];

	for (i = 0; i < 4; i++)
	{
		[userList[i] release];
	}

	for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
	{
		[levelButtons[i] release];
		[levelText[i] release];
	}

	for (i = 0; i < MAX_SOUNDS; i++)
	{
		NSUInteger sourceID = [[soundEffects objectAtIndex:i] unsignedIntegerValue];
		alDeleteSources(1, &sourceID);

		NSUInteger bufferID = [[soundBuffers objectAtIndex:i] unsignedIntegerValue];
		alDeleteBuffers(1, &bufferID);
	}

	[soundBuffers removeAllObjects];
	[soundBuffers release];

	[soundEffects removeAllObjects];
	[soundEffects release];

	alcDestroyContext(mContext);
	alcCloseDevice(mDevice);

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		[blockImages[i] release];
		[blockAmounts[i] release];
	}

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {

        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(gameLoop)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)viewDidLoad
{
	int i;

	/*
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
		if (error)
		{
			NSLog(error.localizedDescription);
		}
		else
		{
			NSLog(@"Logged in successfully!");
		}
	}];
	*/

	if (MAX_SOUNDS != NUM_SOUNDS)
	{
//		printf("Sound lengths do not match!\n");
	}

	if (NSClassFromString(@"TWTweetComposeViewController")) //check for twitter support on iOS version
	{
		twitterIsSupported = true;
		twitView = [[TWTweetComposeViewController alloc] init];
	}
	else
	{
		twitterIsSupported = false;
	}

	[self.view setBackgroundColor:[UIColor blackColor]];

	CGRect rect = [[UIScreen mainScreen] bounds];
	screenWidth = rect.size.width;
	screenHeight = rect.size.height;

	timeoutFrames = 0;
	uploadTime = 0;
	levelID = -1;

	AVAudioSession *session = [AVAudioSession sharedInstance];
	[session setCategory:AVAudioSessionCategoryAmbient error:NULL];

	randomMusic = false;
	musicPlaying = false;
	currentSong = -1;
	soundFlags = 0;
	loadLevel = 0;
	loop = false;

	if (screenWidth < screenHeight)
	{
		float temp = screenWidth;
		screenWidth = screenHeight;
		screenHeight = temp;
	}

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glOrthof(0, screenWidth, 0, screenHeight, -1, 1);
	glViewport(0, 0, screenWidth, screenHeight);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	glEnableClientState(GL_VERTEX_ARRAY);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

	srand(time(NULL));
	rand();

	memset(map, 0, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
	memset(special, 0, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
	memset(undoMap, 0, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
	memset(undoSpecial, 0, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
	memset(userLevelIDs, -1, 4 * sizeof(int));
	memset(levelTimes, -1, MAX_MAPS * sizeof(int));
	memset(levelProgress, -1, MAX_MAPS * sizeof(int));
	memset(introBlocks, false, MAX_INTRO_BLOCKS * sizeof(BOOL));
	levelProgress[0] = 0; //unlock first level
	playerHasGold = false;
	playerHasDeaths = 0;
	showEditorWarning = 0;
	showBlockIntro = false;

	musicOn = true;
	fxOn = true;

	buttonPos[0] = 0;
	buttonPos[1] = screenHeight - 56;
	buttonPos[2] = 88;
	buttonPos[3] = screenHeight - 56;
	buttonPos[4] = screenWidth - 176;
	buttonPos[5] = screenHeight - 56;
	buttonPos[6] = screenWidth - 88;
	buttonPos[7] = screenHeight - 56;
	buttonPos[8] = 54;
	buttonPos[9] = screenHeight - 120;
	buttonPos[10] = screenWidth - 116;
	buttonPos[11] = screenHeight - 120;

	[self loadProgress];

	connectionInUse = false;
	pageNumber = 0;
	levelsPage = 0;

	helpText = [[NSArray alloc] initWithObjects:@"Selection Tool: Press and drag to extend the selection rectangle. When you have a selected region, you can cut or copy to the clipboard.", @"Draw Tool: Drag your finger to leave a trail of tiles or press once to draw a single tile.", @"Fill Tool: Press and drag to extend the fill rectangle. Releasing your finger will fill the region with the selected tile.", @"Eraser: Removes the tiles currently under your finger. The outer edges cannot be erased.", @"Undo: Reverses the last edit.", @"Cut: Copies the selected tiles to the clipboard and clears them from the level.", @"Copy: Copies the tiles in the selected region to the clipboard.", @"Paste: Press your finger to copy the tiles from the clipboard to the specified location.", @"Level Properties: This is where you set the number and type of blocks the player will start the level with. You can also set the medal times and choose a description for the difficulty.", @"Tile Selection: This is where you change the selected tile. The first set of tiles is used to make walls and floors and the second set is for adding special objects. You can also change the background image for your level.", @"Run: Press this button to test out your level! You can return to the editor when you fail or complete the level.", @"Move: Press and drag to move around the level", @"Up Arrow: This changes to the second set of editor buttons.", @"Quit: Exit back to the Main Menu.", @"Save: Saves the current level. If another level is already saved, you will be asked if you want to overwrite it.", @"New Level: Starts a new level from scratch.", @"Upload: Uploads your level to be shared with the rest of the community! Please make sure you are finished with your level before uploading and that it is possible to complete. You will need to create a GreenPixel account before you can upload a level.", @"Down Arrow: Returns to the first set of editor buttons.", nil];

	blockText = [[NSArray alloc] initWithObjects:@"A fine example of alien technology, these laser Blade Blocks can cut right through robots! Legend has it, the aliens were inspired when they heard the tale of the plumber and the turtle...", @"The Bomb Blocks were once used for demolition and can be used to blow away most other Blocks. To activate, stand on top, run and count to 3!", @"These Conveyor Blocks were once needed in the assembly plants, but now we can use them to jump further! Thanks, momentum! :) To get a boost, run in the direction of the Conveyor and jump!", @"This special Crystal Block is strong enough to withstand the power of lasers! They won't last forever, so we'll have to be quick!", @"Poof! These Platform Blocks may not look like much, but they are perfect for bridging gaps and getting to hard-to-reach places. If you ever box yourself in and can't continue, there is a self-destruct button at the top-right. Please try not to use it often. :)", @"I can stand on these Fire Blocks until their searing flames burst forth! Anything still on top will be incinerated. Oh, they can also melt Ice Blocks, so they're not all bad. :)", @"Pew, pew, pew! These Gun Blocks were used for cleaning up the mean streets of our cities until things got out of hand... It's been pretty lonely around here lately. Walls will stop the bullets, but they pass right through other Blocks.", @"This Block is tricky! It can only stay solid for a few seconds and when time runs out, it disappears! Don't worry though, it'll come back eventually. :)", @"These Moving Blocks are great for hitching a ride! They come in two flavors: Vertical and Horizontal. The direction of the arrow on the currently selected Block sets the starting direction of the placed Block. Careful not to get squished!", @"This Block was stolen, um... borrowed from the aliens! I don't know how they do it, but when two or more Portal Blocks of the same color are placed, activating one will send me to the next! Note: HUGE SUCCESS! :)", @"The Spike Blocks are leftover defense systems from the Great War! Their spikes poke out from all sides in a set pattern, so please make sure I'm nowhere near a spikey side! They're also sharp enough to pop Balloon Blocks.", @"Boi-oi-oi-oing! The Springboard Block was originally meant to be a toy, but they were recalled after having just over a 99\% fatality rate... Now, we can use them to jump super-high! :)", @"", @"This is a Checkpoint! If we have to retry the level, we'll start here! Any Blocks we have used to this point will stay where they are. To reset the level, choose Restart Level from the Pause Menu!", nil];

	songPaths = [[NSArray alloc] initWithObjects:@"main_menu", @"factory_level", @"grass_level", @"city_level", @"space_level", @"underground_level", @"error_level", nil];

	soundPaths = [[NSArray alloc] initWithObjects:@"BitJump2", @"BitAndBombExplode", @"GoalActivate", @"PlaceBlock", @"Pop", @"CrystalShatter", @"FireBlock", @"GunShot", @"PortalTeleport", @"SpikeBlock", @"BitJump", @"MenuButtonClick", @"BitExplode", @"BitLand", @"BlockMode", @"Click", @"Switch", @"Checkpoint", @"Fireworks", nil];

	medalImagePaths = [[NSArray alloc] initWithObjects:@"btn_LevelSelectLevel.png", @"btn_LevelSelectLevelBronze.png", @"btn_LevelSelectLevelSilver.png", @"btn_LevelSelectLevelGold.png", nil];

	gameOverPaths = [[NSArray alloc] initWithObjects:@"GameOverScreen_Fall.png", @"GameOverScreen_Blade.png", @"GameOverScreen_Laser.png", @"GameOverScreen_Spike.png", @"GameOverScreen_Squish.png", @"GameOverScreen_Fire.png", @"GameOverScreen_Explode.png", @"GameOverScreen_Bullet.png", @"GameOverScreen_Lava.png", nil];

	deathText = [[NSArray alloc] initWithObjects:@"Ahhh, now I can relax and fall for eternity... this pit IS bottomless right?", @"Weeeeeeeeeeeee!", @"That first step's a doozy!", @"Apparently, I can't fly. :(", @"Now I can do two things at once. :)", @"Looks like a sale on Bit. 50% off!", @"I'm a robot, I can put my arm back on; but you can't, so play safe.", @"I had to split.", @"Definitely do NOT go towards the bright light!", @"At least I won't need laser eye surgery! :)", @"Oh man, I thought it would just set off an alarm!", @"Hmm, smells like something's burning...", @"These speed holes should make me go faster!", @"Ok, ok, I get the point.", @"Acupuncture: The harder you do it, the better it works. It's true! I no longer feel any pain. :)", @"Gotta stay sharp...", @"I am now the undisputed grand master of limbo. :)", @"Let's play ultimate frisbee! You bring the ultimate, I can be the frisbee! :)", @"Finally, I can get that change under the fridge!", @"Hmm, I may need to invest in a ladder.", @"Please spread my ashes on the Goal!", @"Hot... too hot!", @"...and me without any marshmallows. :(", @"Anyone else find it warm?", @"And boom goes the dynamite.", @"Good thinking! I can cover more ground, if I split up!", @"Who needs fireworks when you've got me? :)", @"If a part of me lands on the Goal, does it count?", @"Guns don't kill robots... automated turrets with infinite ammo kill robots!", @"I was just trying to hitch a ride. :(", @"I opted for this cool orange paint instead of a bulletproof coating... no regrets. :)", @"Ahhh, one day to retirement...", @"You get used to it... like a hot tub! But then you die. :(", @"I hope I'm recycled into something useful!", @"Not even those awesome liquid-metal robots can survive this!", @"Oh no! It hasn't been an hour since I last ate something!", nil];

	blockIntroPaths = [[NSArray alloc] initWithObjects:@"UI_Block_Blade.png", @"UI_Block_Bomb.png", @"UI_Block_Conveyor.png", @"UI_Block_Crystal.png", @"UI_Block_Default.png", @"UI_Block_Fire.png", @"UI_Block_Gun.png", @"UI_Block_Invisible.png", @"UI_Block_LeftRight.png", @"UI_Block_Portal.png", @"UI_Block_Spike.png", @"UI_Block_Spring.png", @"UI_Block_UpDown.png", nil];

	configButtonIndex = -1;
	editorBGIndex = 1;
	bgText = [[NSArray alloc] initWithObjects:@"Factory", @"Grass", @"City", @"Space", @"Underground", @"Error!", nil];

	diffIndex = 0;
	diffText = [[NSArray alloc] initWithObjects:@"Easy", @"Medium", @"Hard", nil];

	sortText = [[NSArray alloc] initWithObjects:@"Newest", @"Oldest", @"Completed", @"Rating", nil];
	sortIndex = 0;

	filterText = [[NSArray alloc] initWithObjects:@"All", @"Easy", @"Medium", @"Hard", nil];
	filterIndex = 0;

	directText = [[NSArray alloc] initWithObjects:@"Level ID", @"Username", nil];
	directIndex = 0;

	username = [NSString alloc];
	password = [NSString alloc];
	message = [NSString alloc];

	for (i = 0; i < 4; i++)
	{
		userList[i] = [NSString alloc];
	}

	// Init images								
	am = [[AssetManager alloc] init];

	Image *playerImg;
	Image *effectsImg;

	if (playerHasGold)
	{
		playerImg = [[Image alloc] initWithString:@"playerGold.png"];
		effectsImg = [[Image alloc] initWithString:@"effectsGold.png"]; 
	}
	else
	{
		playerImg = [[Image alloc] initWithString:@"player.png"];
		effectsImg = [[Image alloc] initWithString:@"effects.png"];
	}

	NSMutableDictionary *dicface= [[NSMutableDictionary alloc] initWithCapacity:0];
	[dicface release];

	Image *blocksImg = [[Image alloc] initWithString:@"blocks.png"];
	Image *buttonsImg = [[Image alloc] initWithString:@"buttons.png"];
	Image *bulletImg = [[Image alloc] initWithString:@"bullet.png"];
	Image *fireworkImg = [[Image alloc] initWithString:@"BigFirework.png"];
	Image *firework2Img = [[Image alloc] initWithString:@"BigFireworkb.png"];
	Image *congratsImg = [[Image alloc] initWithString:@"CONGRATS.png"];

	[am.images addObject:playerImg];
	[am.images addObject:blocksImg];
	[am.images addObject:buttonsImg];
	[am.images addObject:bulletImg];
	[am.images addObject:effectsImg];
	[am.images addObject:fireworkImg];
	[am.images addObject:firework2Img];
	[am.images addObject:congratsImg];

	[playerImg release];
	[blocksImg release];
	[effectsImg release];
	[bulletImg release];
	[buttonsImg release];
	[fireworkImg release];
	[firework2Img release];
	[congratsImg release];

	Animation *anim = [[Animation alloc] initWithData:BIT_ANIMS OfLength:BIT_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:BLOCKS_ANIMS OfLength:BLOCKS_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:BUTTONS_ANIMS OfLength:BUTTONS_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:BULLET_ANIMS OfLength:BULLET_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:EFFECTS_ANIMS OfLength:EFFECTS_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:FIREWORK_ANIMS OfLength:FIREWORK_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:FIREWORK2_ANIMS OfLength:FIREWORK2_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	anim = [[Animation alloc] initWithData:CONGRATS_ANIMS OfLength:CONGRATS_ANIMS_LENGTH];
	[am.anims addObject:anim];
	[anim release];

	bgImage = [[Image alloc] initWithString:@"BGGrassLevel.png"];
	mapTiles = [[Image alloc] initWithString:@"LEVELGrassBlocks.png"];
	specialTiles = [[Image alloc] initWithString:@"editorSpecialBlocks.png"];
	previousBackground = -1;

	player = [[Player alloc] initPlayer:am];
	[player setAnim:ANIM_PLAYER_IDLE_RIGHT];

	currentBlock = [[Block alloc] initBlock:0 WithAssetManager:am];

	vec = [Vector2D alloc];

	serverData = [[NSMutableData alloc] initWithCapacity:0];
	blockQueue = [[NSMutableArray alloc] init];
	blockBkup = [[NSMutableArray alloc] init];
	checkpointBlocks = [[NSMutableArray alloc] init];

	frames = 0;

	gameState = [[NSMutableArray alloc] init];
	[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_INIT_OPENFEINT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_SA_SPLASH]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_SA_SPLASH]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
//	[gameState addObject:[NSNumber numberWithInteger:STATE_GP_SPLASH]];

	projectileArray = [[NSMutableArray alloc] init];
	billboards = [[NSMutableArray alloc] init];
	buttonsArray = [[NSMutableArray alloc] init];

	timerField = [[UITextField alloc] initWithFrame:CGRectMake(338, 124, 80, 32)];
	timerField.textColor = [UIColor whiteColor];
//	timerField.font = [UIFont systemFontOfSize:17.0];
	timerField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	timerField.placeholder = @"--:--:--";
	timerField.userInteractionEnabled = NO;
	timerField.hidden = YES;
	timerField.textAlignment = UITextAlignmentRight;

	blocksAvailableField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 79, 200, 32)];
	blocksAvailableField.textColor = [UIColor whiteColor];
//	blocksAvailableField.font = [UIFont systemFontOfSize:17.0];
	blocksAvailableField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	blocksAvailableField.placeholder = @"";
	blocksAvailableField.userInteractionEnabled = NO;
	blocksAvailableField.hidden = YES;
	blocksAvailableField.textAlignment = UITextAlignmentCenter;

	blockNumField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 16, 32, 32, 32)];
	blockNumField.textColor = [UIColor whiteColor];
//	blockNumField.font = [UIFont systemFontOfSize:17.0];
	blockNumField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	blockNumField.placeholder = @"";
	blockNumField.userInteractionEnabled = NO;
	blockNumField.hidden = YES;
	blockNumField.textAlignment = UITextAlignmentCenter;

	usernameField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 122, 200, 20)];
	usernameField.textColor = [UIColor blackColor];
	usernameField.backgroundColor = [UIColor whiteColor];
	usernameField.font = [UIFont systemFontOfSize:17.0];
//	usernameField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	usernameField.placeholder = @"USERNAME";
	usernameField.userInteractionEnabled = YES;
	usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	usernameField.hidden = YES;
	usernameField.textAlignment = UITextAlignmentCenter;
	usernameField.delegate = self;

	passwordField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 202, 200, 20)];
	passwordField.textColor = [UIColor blackColor];
	passwordField.backgroundColor = [UIColor whiteColor];
	passwordField.font = [UIFont systemFontOfSize:17.0];
//	passwordField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	passwordField.placeholder = @"PASSWORD";
	passwordField.userInteractionEnabled = YES;
	passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	passwordField.hidden = YES;
	passwordField.textAlignment = UITextAlignmentCenter;
	passwordField.delegate = self;

	registerUsernameField = [[UITextField alloc] initWithFrame:CGRectMake(260, 91, 180, 20)];
	registerUsernameField.textColor = [UIColor blackColor];
	registerUsernameField.backgroundColor = [UIColor whiteColor];
	registerUsernameField.font = [UIFont systemFontOfSize:17.0];
//	registerUsernameField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	registerUsernameField.placeholder = @"USERNAME";
	registerUsernameField.userInteractionEnabled = YES;
	registerUsernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	registerUsernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	registerUsernameField.hidden = YES;
	registerUsernameField.textAlignment = UITextAlignmentCenter;
	registerUsernameField.delegate = self;

	registerEmailField = [[UITextField alloc] initWithFrame:CGRectMake(40, 91, 180, 20)];
	registerEmailField.textColor = [UIColor blackColor];
	registerEmailField.backgroundColor = [UIColor whiteColor];
	registerEmailField.font = [UIFont systemFontOfSize:17.0];
//	registerEmailField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	registerEmailField.placeholder = @"EMAIL";
	registerEmailField.userInteractionEnabled = YES;
	registerEmailField.autocorrectionType = UITextAutocorrectionTypeNo;
	registerEmailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	registerEmailField.hidden = YES;
	registerEmailField.textAlignment = UITextAlignmentCenter;
	registerEmailField.delegate = self;

	registerPasswordField1 = [[UITextField alloc] initWithFrame:CGRectMake(40, 159, 180, 20)];
	registerPasswordField1.textColor = [UIColor blackColor];
	registerPasswordField1.backgroundColor = [UIColor whiteColor];
	registerPasswordField1.font = [UIFont systemFontOfSize:17.0];
//	registerPasswordField1.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	registerPasswordField1.placeholder = @"PASSWORD";
	registerPasswordField1.userInteractionEnabled = YES;
	registerPasswordField1.autocorrectionType = UITextAutocorrectionTypeNo;
	registerPasswordField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
	registerPasswordField1.hidden = YES;
	registerPasswordField1.textAlignment = UITextAlignmentCenter;
	registerPasswordField1.delegate = self;

	registerPasswordField2 = [[UITextField alloc] initWithFrame:CGRectMake(260, 159, 180, 20)];
	registerPasswordField2.textColor = [UIColor blackColor];
	registerPasswordField2.backgroundColor = [UIColor whiteColor];
	registerPasswordField2.font = [UIFont systemFontOfSize:17.0];
//	registerPasswordField2.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	registerPasswordField2.placeholder = @"CONFIRM PWD";
	registerPasswordField2.userInteractionEnabled = YES;
	registerPasswordField2.autocorrectionType = UITextAutocorrectionTypeNo;
	registerPasswordField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
	registerPasswordField2.hidden = YES;
	registerPasswordField2.textAlignment = UITextAlignmentCenter;
	registerPasswordField2.delegate = self;

	creditsField = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 208, 16, 420, 300)];
	creditsField.textColor = [UIColor whiteColor];
//	creditsField.font = [UIFont systemFontOfSize:14.0];
	creditsField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:15];
	creditsField.backgroundColor = [UIColor clearColor];
	creditsField.userInteractionEnabled = NO;
	creditsField.text = @"www.greenpixel.ca\nArt: Joe Pendon\nCode: Rich Halliday\n\nMusic By:\nStarship Amazing\nwww.starshipamazing.com\n\nSpecial Thanks:\nMichelle Ferrer Pendon and Nana-chan\nAnnika and David Samuelsen\nJohn and Biagio @ Queen's Subs, Hamilton, ON\nRobyn and Matthew Bremner\nRajiv Patel and Todd Showalter\nConrad and The Backlog :{|\nFFSTV - Sorry, no Fraser mode!\nAnd to YOU! Thank you for your support!";
	creditsField.hidden = YES;
	creditsField.textAlignment = UITextAlignmentCenter;

	introMessageField = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 202, screenHeight / 2 + 6, 404, 114)];
	introMessageField.textColor = [UIColor whiteColor];
//	introMessageField.font = [UIFont systemFontOfSize:14.0];
	introMessageField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	introMessageField.backgroundColor = [UIColor clearColor];
//	introMessageField.backgroundColor = [UIColor whiteColor];
	introMessageField.userInteractionEnabled = NO;
	introMessageField.hidden = YES;

	mainMessageField = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 202, screenHeight / 2 + 32, 404, 114)];
	mainMessageField.textColor = [UIColor whiteColor];
//	mainMessageField.font = [UIFont systemFontOfSize:14.0];
	mainMessageField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	mainMessageField.backgroundColor = [UIColor clearColor];
	mainMessageField.userInteractionEnabled = NO;
	mainMessageField.hidden = YES;

	errorMessageField = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 202, screenHeight / 2 + 32, 404, 114)];
	errorMessageField.textColor = [UIColor whiteColor];
//	mainMessageField.font = [UIFont systemFontOfSize:14.0];
	errorMessageField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	errorMessageField.backgroundColor = [UIColor clearColor];
	errorMessageField.userInteractionEnabled = NO;
	errorMessageField.hidden = YES;
	errorMessageField.text = @"Sorry! We encountered a networking problem. Please try again later.";

	cutsceneMessageField = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 36 , 200, 100)];
	cutsceneMessageField.textColor = [UIColor whiteColor];
//	cutsceneMessageField.font = [UIFont systemFontOfSize:14.0];
	cutsceneMessageField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	cutsceneMessageField.backgroundColor = [UIColor clearColor];
	cutsceneMessageField.userInteractionEnabled = NO;
	cutsceneMessageField.hidden = YES;

	userField1 = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 208, 36, 415, 48)];
	userField1.textColor = [UIColor whiteColor];
//	userField1.font = [UIFont systemFontOfSize:14.0];
	userField1.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	userField1.backgroundColor = [UIColor clearColor];
	userField1.userInteractionEnabled = NO;
	userField1.hidden = YES;
	userField1.textAlignment = UITextAlignmentCenter;

	userField2 = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 208, 89, 415, 48)];
	userField2.textColor = [UIColor whiteColor];
//	userField2.font = [UIFont systemFontOfSize:14.0];
	userField2.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	userField2.backgroundColor = [UIColor clearColor];
	userField2.userInteractionEnabled = NO;
	userField2.hidden = YES;
	userField2.textAlignment = UITextAlignmentCenter;

	userField3 = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 208, 142, 415, 48)];
	userField3.textColor = [UIColor whiteColor];
//	userField3.font = [UIFont systemFontOfSize:14.0];
	userField3.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	userField3.backgroundColor = [UIColor clearColor];
	userField3.userInteractionEnabled = NO;
	userField3.hidden = YES;
	userField3.textAlignment = UITextAlignmentCenter;

	userField4 = [[UITextView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 208, 195, 415, 48)];
	userField4.textColor = [UIColor whiteColor];
//	userField4.font = [UIFont systemFontOfSize:14.0];
	userField4.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	userField4.backgroundColor = [UIColor clearColor];
	userField4.userInteractionEnabled = NO;
	userField4.hidden = YES;
	userField4.textAlignment = UITextAlignmentCenter;

	goldTimeField = [[UITextField alloc] initWithFrame:CGRectMake(131, 28, 80, 32)];
	goldTimeField.textColor = [UIColor whiteColor];
//	goldTimeField.font = [UIFont systemFontOfSize:17.0];
	goldTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	goldTimeField.placeholder = @"";
	goldTimeField.userInteractionEnabled = NO;
	goldTimeField.hidden = YES;
	goldTimeField.textAlignment = UITextAlignmentCenter;

	silverTimeField = [[UITextField alloc] initWithFrame:CGRectMake(234, 28, 80, 32)];
	silverTimeField.textColor = [UIColor whiteColor];
//	silverTimeField.font = [UIFont systemFontOfSize:17.0];
	silverTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	silverTimeField.placeholder = @"";
	silverTimeField.userInteractionEnabled = NO;
	silverTimeField.hidden = YES;
	silverTimeField.textAlignment = UITextAlignmentCenter;

	bronzeTimeField = [[UITextField alloc] initWithFrame:CGRectMake(339, 28, 80, 32)];
	bronzeTimeField.textColor = [UIColor whiteColor];
//	bronzeTimeField.font = [UIFont systemFontOfSize:17.0];
	bronzeTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	bronzeTimeField.placeholder = @"";
	bronzeTimeField.userInteractionEnabled = NO;
	bronzeTimeField.hidden = YES;
	bronzeTimeField.textAlignment = UITextAlignmentCenter;

	pageField = [[UITextField alloc] initWithFrame:CGRectMake(332, 256, 80, 32)];
	pageField.textColor = [UIColor whiteColor];
//	pageField.font = [UIFont systemFontOfSize:14.0];
	pageField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:14];
	pageField.placeholder = @"";
	pageField.userInteractionEnabled = NO;
	pageField.hidden = YES;
	pageField.textAlignment = UITextAlignmentRight;

	editorGoldTimeField = [[UITextField alloc] initWithFrame:CGRectMake(308, 254, 80, 32)];
	editorGoldTimeField.textColor = [UIColor whiteColor];
//	editorGoldTimeField.font = [UIFont systemFontOfSize:17.0];
	editorGoldTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	editorGoldTimeField.placeholder = @"";
	editorGoldTimeField.userInteractionEnabled = NO;
	editorGoldTimeField.hidden = YES;
	editorGoldTimeField.textAlignment = UITextAlignmentCenter;

	editorSilverTimeField = [[UITextField alloc] initWithFrame:CGRectMake(308, 220, 80, 32)];
	editorSilverTimeField.textColor = [UIColor whiteColor];
//	editorSilverTimeField.font = [UIFont systemFontOfSize:17.0];
	editorSilverTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	editorSilverTimeField.placeholder = @"";
	editorSilverTimeField.userInteractionEnabled = NO;
	editorSilverTimeField.hidden = YES;
	editorSilverTimeField.textAlignment = UITextAlignmentCenter;

	editorBronzeTimeField = [[UITextField alloc] initWithFrame:CGRectMake(308, 186, 80, 32)];
	editorBronzeTimeField.textColor = [UIColor whiteColor];
//	editorBronzeTimeField.font = [UIFont systemFontOfSize:17.0];
	editorBronzeTimeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	editorBronzeTimeField.placeholder = @"";
	editorBronzeTimeField.userInteractionEnabled = NO;
	editorBronzeTimeField.hidden = YES;
	editorBronzeTimeField.textAlignment = UITextAlignmentCenter;

	retryField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 200, screenHeight - 64, 400, 32)];
	retryField.textColor = [UIColor whiteColor];
	retryField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	retryField.placeholder = @"";
	retryField.userInteractionEnabled = NO;
	retryField.hidden = YES;
	retryField.textAlignment = UITextAlignmentCenter;

	diffField = [[UITextField alloc] initWithFrame:CGRectMake(80, 234, 100, 40)];
	diffField.textColor = [UIColor whiteColor];
//	diffField.font = [UIFont systemFontOfSize:15.0];
	diffField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	diffField.placeholder = @"";
	diffField.userInteractionEnabled = NO;
	diffField.hidden = YES;
	diffField.textAlignment = UITextAlignmentCenter;

	diffTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 210, 100, 40)];
	diffTextField.textColor = [UIColor whiteColor];
//	diffField.font = [UIFont systemFontOfSize:15.0];
	diffTextField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:15];
	diffTextField.placeholder = @"";
	diffTextField.userInteractionEnabled = NO;
	diffTextField.hidden = YES;
	diffTextField.textAlignment = UITextAlignmentCenter;
	diffTextField.text = @"Difficulty";

	editorBGTypeField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 249, 200, 40)];
	editorBGTypeField.textColor = [UIColor whiteColor];
//	editorBGTypeField.font = [UIFont systemFontOfSize:15.0];
	editorBGTypeField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	editorBGTypeField.placeholder = @"";
	editorBGTypeField.userInteractionEnabled = NO;
	editorBGTypeField.hidden = YES;
	editorBGTypeField.textAlignment = UITextAlignmentCenter;

	editorBGField = [[UITextField alloc] initWithFrame:CGRectMake(screenWidth / 2 - 100, 222, 200, 40)];
	editorBGField.textColor = [UIColor whiteColor];
//	editorBGField.font = [UIFont systemFontOfSize:15.0];
	editorBGField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:15];
	editorBGField.placeholder = @"";
	editorBGField.userInteractionEnabled = NO;
	editorBGField.hidden = YES;
	editorBGField.textAlignment = UITextAlignmentCenter;
	editorBGField.text = @"Background";

	sortField = [[UITextField alloc] initWithFrame:CGRectMake(300, 56, 100, 40)];
	sortField.textColor = [UIColor whiteColor];
//	sortField.font = [UIFont systemFontOfSize:17.0];
	sortField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	sortField.placeholder = @"";
	sortField.userInteractionEnabled = NO;
	sortField.hidden = YES;
	sortField.textAlignment = UITextAlignmentCenter;

	filterField = [[UITextField alloc] initWithFrame:CGRectMake(300, 134, 100, 40)];
	filterField.textColor = [UIColor whiteColor];
//	filterField.font = [UIFont systemFontOfSize:17.0];
	filterField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	filterField.placeholder = @"";
	filterField.userInteractionEnabled = NO;
	filterField.hidden = YES;
	filterField.textAlignment = UITextAlignmentCenter;

	directField = [[UITextField alloc] initWithFrame:CGRectMake(300, 235, 100, 40)];
	directField.textColor = [UIColor whiteColor];
//	directField.font = [UIFont systemFontOfSize:17.0];
	directField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:17];
	directField.placeholder = @"";
	directField.userInteractionEnabled = NO;
	directField.hidden = YES;
	directField.textAlignment = UITextAlignmentCenter;

	directInputField = [[UITextField alloc] initWithFrame:CGRectMake(250, 200, 200, 20)];
	directInputField.delegate = self;
	directInputField.textColor = [UIColor blackColor];
	directInputField.backgroundColor = [UIColor whiteColor];
	directInputField.font = [UIFont systemFontOfSize:17.0];
//	directInputField.font = [UIFont fontWithName:@"VisitorTT1BRK" size:20];
	directInputField.placeholder = @"ID OR USERNAME";
	directInputField.autocorrectionType = UITextAutocorrectionTypeNo;
	directInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	directInputField.hidden = YES;
	directInputField.textAlignment = UITextAlignmentCenter;

	[self.view addSubview:blockNumField];

	hudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UI_HUD.png"]];
	hudView.hidden = YES;
	[self.view addSubview:hudView];

	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_GP.png"]];
	[self.view addSubview:imageView];

	gridView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UI_GameGrid.png"]];
	gridView.hidden = YES;
	[self.view addSubview:gridView];

	musicVolumeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_soundmusicON.png"]];
	if (musicOn)
	{
		[self setImageView:@"btn_soundmusicON.png" :musicVolumeView :444 :126];
	}
	else
	{
		[self setImageView:@"btn_soundmusicOFF.png" :musicVolumeView :444 :126];
	}
	musicVolumeView.hidden = YES;
	[self.view addSubview:musicVolumeView];

	fxVolumeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_soundfxON.png"]];
	if (fxOn)
	{
		[self setImageView:@"btn_soundfxON.png" :fxVolumeView :444 :164];
	}
	else
	{
		[self setImageView:@"btn_soundfxOFF.png" :fxVolumeView :444 :164];
	}

	fxVolumeView.hidden = YES;
	[self.view addSubview:fxVolumeView];

	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Click" ofType:@"wav"];
	NSData *sound = [NSData dataWithContentsOfFile:filePath];

	clickSound = [[AVAudioPlayer alloc] initWithData:sound error:NULL];

	int xPos = 25;
	int yPos = 50;
	for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
	{
		if (i && !(i % 6))
		{
			yPos += 53;
			xPos = 25;
		}

		levelButtons[i] = [[LevelButton alloc] initWithImage:[UIImage imageNamed:@"btn_LevelSelectLevel.png"]];
		levelButtons[i].index = i;

		CGRect tempFrame = levelButtons[i].frame;
		tempFrame.size = levelButtons[i].image.size;
		tempFrame.origin.x = xPos;
		tempFrame.origin.y = yPos;
		levelButtons[i].frame = tempFrame;
		levelButtons[i].hidden = YES;

		[self.view addSubview:levelButtons[i]];

		levelText[i] = [[UITextField alloc] initWithFrame:CGRectMake(xPos + 20, yPos + 8, 32, 32)];
		levelText[i].textColor = [UIColor whiteColor];
//		levelText[i].font = [UIFont systemFontOfSize:14.0];
		levelText[i].font = [UIFont fontWithName:@"VisitorTT1BRK" size:15];
		levelText[i].placeholder = @"";
		levelText[i].text = [NSString stringWithFormat:@"%d", (i + 1)];
		levelText[i].userInteractionEnabled = NO;
		levelText[i].hidden = YES;
		levelText[i].textAlignment = UITextAlignmentCenter;

		[self.view addSubview:levelText[i]];

		xPos += 72;
	}

	xPos = 4;
	yPos = 32;
	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		if (i && !(i % 6))
		{
			xPos = 4;
			yPos += 50;

			if (i == 12)
			{
				xPos += 80;
			}
		}

		blockAmounts[i] = [[BlockAmountObject alloc] init:xPos - 10 :yPos + 6 :clickSound];
		blockAmounts[i].hidden = YES;

		[self.view addSubview:blockAmounts[i]];

		xPos += 80;
	}

	imageSubView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UI_MainMenu.png"]];
	imageSubView.hidden = YES;
	[self.view addSubview:imageSubView];

	helpSubView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageWindow.png"]];
	[self setImageView:@"messageWindow.png" :helpSubView :INT_MAX :INT_MAX];
	helpSubView.hidden = YES;
	[self.view addSubview:helpSubView];

	networkErrorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageWindow.png"]];
	[self setImageView:@"messageWindow.png" :networkErrorView :INT_MAX :INT_MAX];
	networkErrorView.hidden = YES;

	[self.view addSubview:usernameField];
	[self.view addSubview:passwordField];
	[self.view addSubview:registerUsernameField];
	[self.view addSubview:registerEmailField];
	[self.view addSubview:registerPasswordField1];
	[self.view addSubview:registerPasswordField2];
	[self.view addSubview:timerField];
	[self.view addSubview:blocksAvailableField];
	[self.view addSubview:creditsField];
	[self.view addSubview:introMessageField];
	[self.view addSubview:mainMessageField];
	[self.view addSubview:retryField];
	[self.view addSubview:cutsceneMessageField];
	[self.view addSubview:userField1];
	[self.view addSubview:userField2];
	[self.view addSubview:userField3];
	[self.view addSubview:userField4];
	[self.view addSubview:goldTimeField];
	[self.view addSubview:silverTimeField];
	[self.view addSubview:bronzeTimeField];
	[self.view addSubview:pageField];
	[self.view addSubview:editorGoldTimeField];
	[self.view addSubview:editorSilverTimeField];
	[self.view addSubview:editorBronzeTimeField];
	[self.view addSubview:diffField];
	[self.view addSubview:diffTextField];
	[self.view addSubview:editorBGTypeField];
	[self.view addSubview:editorBGField];
	[self.view addSubview:sortField];
	[self.view addSubview:filterField];
	[self.view addSubview:directField];

	[self setupButtons];
	[self.view addSubview:directInputField];
	lockButtons = false;

	fadeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackScreen.png"]];
	[self setImageView:@"blackScreen.png" :fadeView :INT_MAX :INT_MAX];

	bitView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth / 2 - 16, screenHeight - 78, 32, 32)];
	bitView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"loading_bitwalk_03.png"], [UIImage imageNamed:@"loading_bitwalk_04.png"], [UIImage imageNamed:@"loading_bitwalk_05.png"], [UIImage imageNamed:@"loading_bitwalk_04.png"], [UIImage imageNamed:@"loading_bitwalk_03.png"], [UIImage imageNamed:@"loading_bitwalk_01.png"], [UIImage imageNamed:@"loading_bitwalk_02.png"], [UIImage imageNamed:@"loading_bitwalk_01.png"], nil];
	bitView.animationDuration = 1;
	bitView.animationRepeatCount = 0;
	[bitView startAnimating];
	bitView.hidden = YES;

	blockImagePaths = [[NSArray alloc] initWithObjects:@"block_default.png", @"block_invisible.png", @"block_leftright.png", @"block_updown.png", @"block_rightconveyor.png", @"block_leftconveyor.png", @"block_redportal.png", @"block_greenportal.png", @"block_blueportal.png", @"block_springboard.png", @"block_crystal.png", @"block_blade.png", @"block_fire.png", @"block_bomb.png", @"block_gun.png", @"block_spikes.png", nil];

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		blockImages[i] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[blockImagePaths objectAtIndex:i]]];
		blockImages[i].hidden = YES;
		[self.view addSubview:blockImages[i]];

		CGRect tempFrame = blockImages[i].frame;
		tempFrame.size = blockImages[i].image.size;
		tempFrame.origin.x = (screenWidth - 8 * TILE_SIZE) / 2 + i * 32;
		tempFrame.origin.y = 98 + (i / 8) * 32;

		if (tempFrame.origin.y == 130)
		{
			tempFrame.origin.x -= 8 * TILE_SIZE;
		}

		blockImages[i].frame = tempFrame;
	}

	[self.view addSubview:fadeView];
	fadeView.alpha = 0;

	[self.view addSubview:networkErrorView];
	[self.view addSubview:errorMessageField];

	[self.view addSubview:bitView];

	GameButton *button;
	CGRect bounds;

	//left button
	bounds.size.width = 88;
	bounds.size.height = 56;
	bounds.origin.x = buttonPos[0];
	bounds.origin.y = buttonPos[1];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_LEFT AndAssetManager:am];
	[button setAnim:ANIM_LEFT_BUTTON_UP];

	[buttonsArray addObject:button];
	[button release];

	//right button
	bounds.origin.x = buttonPos[2];
	bounds.origin.y = buttonPos[3];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_RIGHT AndAssetManager:am];
	[button setAnim:ANIM_RIGHT_BUTTON_UP];

	[buttonsArray addObject:button];
	[button release];

	//down button
	bounds.origin.x = buttonPos[4];
	bounds.origin.y = buttonPos[5];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_DOWN AndAssetManager:am];
	[button setAnim:ANIM_DOWN_BUTTON_UP];

	[buttonsArray addObject:button];
	[button release];

	//up button
	bounds.origin.x = buttonPos[6];
	bounds.origin.y = buttonPos[7];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_UP AndAssetManager:am];
	[button setAnim:ANIM_UP_BUTTON_UP];

	[buttonsArray addObject:button];
	[button release];

	//block buttons
	bounds.size.width = 64;
	bounds.size.height = 64;
	bounds.origin.x = buttonPos[8];
	bounds.origin.y = buttonPos[9];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_BLOCK AndAssetManager:am];
	[button setAnim:ANIM_BLOCK_BUTTON];

	[buttonsArray addObject:button];
	[button release];

	bounds.origin.x = buttonPos[10];
	bounds.origin.y = buttonPos[11];
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_BLOCK AndAssetManager:am];
	[button setAnim:ANIM_BLOCK_BUTTON];

	[buttonsArray addObject:button];
	[button release];

	//ok button
	bounds.size.width = 64;
	bounds.size.height = 48;
	bounds.origin.x = 0;
	bounds.origin.y = 0;
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_OK AndAssetManager:am];
	[button setAnim:ANIM_OK_BUTTON];

	[buttonsArray addObject:button];
	[button release];

	//previous block button
	bounds.origin.x = screenWidth / 2 - 96;
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_PREV_BLOCK AndAssetManager:am];
	[button setAnim:ANIM_LEFT_BUTTON_DOWN];

	[buttonsArray addObject:button];
	[button release];

	//next block button
	bounds.origin.x = screenWidth / 2 + 32;
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_NEXT_BLOCK AndAssetManager:am];
	[button setAnim:ANIM_RIGHT_BUTTON_DOWN];

	[buttonsArray addObject:button];
	[button release];

	//self destruct button
	bounds.origin.x = screenWidth - 64;
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_DESTRUCT AndAssetManager:am];
	[button setAnim:ANIM_DESTRUCT_BUTTON];

	[buttonsArray addObject:button];
	[button release];

	//skip level button
	bounds.origin.x = 0;
	button = [[GameButton alloc] initButtonWithBounds:bounds AndType:BUTTON_TYPE_NEXT_MAP AndAssetManager:am];
	[button setAnim:ANIM_MENU_BUTTON];

	[buttonsArray addObject:button];
	[button release];

	[self selectButtonGroup:BUTTON_GROUP_NONE];

	[self initOpenAL]; //init sound system

	canJump = JUMP_CLEAR;

	drawTileWidth = screenWidth / TILE_SIZE;
	drawTileHeight = screenHeight / TILE_SIZE;
	checkpointX = -1;
	checkpointY = -1;
	showIntro = false;

	loaded = true;

	self.view.multipleTouchEnabled = true;
}

- (void)initOpenAL
{
	int i;

	soundEffects = [[NSMutableArray alloc] init];
	soundBuffers = [[NSMutableArray alloc] init];

	mDevice = alcOpenDevice(NULL);

	if (mDevice)
	{
		mContext = alcCreateContext(mDevice, NULL);
		alcMakeContextCurrent(mContext);

		for (i = 0; i < MAX_SOUNDS; i++)
		{
			NSString *filePath = [[NSBundle mainBundle] pathForResource:[soundPaths objectAtIndex:i] ofType:@"caf"];
			AudioFileID outAFID;

			NSURL *url = [NSURL fileURLWithPath:filePath];

			OSStatus result = AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0, &outAFID);

			if (!result)
			{
				UInt64 outDataSize = 0;
				UInt32 thePropSize = sizeof(UInt64);
				OSStatus result = AudioFileGetProperty(outAFID, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
				
				if (!result)
				{
					UInt32 dataSize = (UInt32)outDataSize;
					unsigned char * outData = malloc(dataSize);

					OSStatus result = AudioFileReadBytes(outAFID, false, 0, &dataSize, outData);
					AudioFileClose(outAFID);

					if (!result)
					{
						NSUInteger bufferID;

						alGenBuffers(1, &bufferID);
						alBufferData(bufferID, AL_FORMAT_MONO16, outData, dataSize, 44100);
						[soundBuffers addObject:[NSNumber numberWithUnsignedInteger:bufferID]];

						NSUInteger sourceID;
						alGenSources(1, &sourceID);
						alSourcei(sourceID, AL_BUFFER, bufferID);
						alSourcef(sourceID, AL_PITCH, 1.0f);
						alSourcef(sourceID, AL_GAIN, 1.0f);
						[soundEffects addObject:[NSNumber numberWithUnsignedInteger:sourceID]];
					}

					if (outData)
					{
						free(outData);
					}
				}
			}
		}
	}
}

- (void)setupMap
{
	int i, j;
	
	[blockQueue removeAllObjects];
	blockIndex = 0;

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			switch (special[i][j])
			{
				case SPECIAL_PLAYER:
					playerStartX = player.x = j * TILE_SIZE;
					playerStartY = player.y = i * TILE_SIZE;
					break;
				case SPECIAL_GOAL:
				{
					goalX = j;
					goalY = i;

					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_GOAL WithAssetManager:am];
					block.x = goalX * TILE_SIZE;
					block.y = goalY * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_SPIKES_UP:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_SPIKES_UP WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_SPIKES_DOWN:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_SPIKES_DOWN WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_SPIKES_LEFT:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_SPIKES_LEFT WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_SPIKES_RIGHT:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_SPIKES_RIGHT WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_LAVA:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_LAVA WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_LASER:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_LASER WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_REDSWITCH:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_REDSWITCH WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_REDBLOCK:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_REDBLOCK WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_GREENSWITCH:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_GREENSWITCH WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_GREENBLOCK:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_GREENBLOCK WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_BLUESWITCH:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_BLUESWITCH WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_BLUEBLOCK:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_BLUEBLOCK WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_BUBBLE:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_BUBBLE WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_ICE:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_ICE WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_LEFTRIGHT:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_LEFTRIGHT WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_UPDOWN:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_UPDOWN WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
				case SPECIAL_CHECKPOINT:
				{
					Block *block = [[Block alloc] initBlock:BLOCK_TYPE_CHECKPOINT WithAssetManager:am];
					block.x = j * TILE_SIZE;
					block.y = i * TILE_SIZE;
					[blockQueue addObject:block];
					blockIndex++;
					[block release];
					break;
				}
			}
		}
	}

	player.flip = false;
	[player setAnim:ANIM_PLAYER_IDLE_RIGHT];

	if (playerStartX > (goalX * TILE_SIZE))
	{
		player.flip = true;
		[player setAnim:ANIM_PLAYER_IDLE_LEFT];
	}
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)gameLoop
{
	int i;

	soundFlags = 0;

	if (!loaded)
	{
		return;
	}

	if ([self getGameState] == STATE_PLAY)
	{
		if (loop)
		{
			if (!showIntro)
			{
				[self updateBlocks];
				[self updateProjectiles];
				[self updatePlayer];
			}
		}
		else
		{
			counter++;

			if (counter > MAX_COUNTER)
			{
				counter = MAX_COUNTER;
			}
			if (switchCounter)
			{
				switchCounter--;
			}

			[self drawGame];
		}
	}

	if (difftime(time(NULL), lastTime) > 1)
	{
//		printf("FPS: %d \n", frames);
		lastTime = time(NULL);
	}

	if (loop)
	{
		switch ([self getGameState])
		{
			case STATE_ADD_LOGIN_ELEMENTS:
				[gameState removeLastObject];
				loginButton.hidden = NO;
				registerButton.hidden = NO;
				cancelButton.hidden = NO;
				usernameField.hidden = NO;
				passwordField.hidden = NO;
				break;
			case STATE_EDITOR_POPUP:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
				helpSubView.hidden = NO;
				currentMessageField = mainMessageField;
				currentMessageField.hidden = NO;
				currentMessageField.text = @"Welcome to the Editor! This is the place to design and upload your own levels to share with the community! For more information on what the different icons do, just press the Help Icon. It's the question mark! Green Pixel reserves the right to remove any levels deemed inappropriate.";
				showEditorWarning |= EDITOR_POPUP_INTRO;
				[self playSound:SOUND_CLICK];
				[self saveProgress];
				break;
			case STATE_ADD_TWITTER_DIALOG:
				[gameState removeLastObject];
				if ([self getGameState] == STATE_LOGIN)
				{
					[self cancelButtonPressed];
				}
				[gameState addObject:[NSNumber numberWithInteger:STATE_OK_CANCEL]];
				[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_OK_CANCEL]];
				mainMessageField.text = @"For our first update, we want to have 70 new levels and we would love it if they came from the community! Full credit to you, of course! If you want to submit a level for consideration, press OK. It will bring up a Twitter message with everything you need. If not, just press Cancel. :)";
				okCancelState = OK_CANCEL_STATE_TWITTER;
				break;
			case STATE_WAITING_FOR_NETWORK:
				bitView.hidden = NO;

				if (timeoutFrames >= MAX_TIMEOUT_FRAMES)
				{
					[gameState removeLastObject];
					[self cancelConnection];
				}
				else
				{
					timeoutFrames++;
				}
				break;
			case STATE_CUTSCENE_TEXT1:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LAST_STATE]];
				[self setImageView:@"ChatBubble_001.png" :imageView :INT_MAX :32];
				[self setupMessage:@"Well done! You have made it through all the levels!" :cutsceneMessageField];
				break;
			case STATE_CUTSCENE_TEXT2:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LAST_STATE]];
				[self setupMessage:@"You deserve one more Block. My most favorite Block of all!" :cutsceneMessageField];
				break;
			case STATE_CUTSCENE_TEXT3:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_CUTSCENE_TEXT]];
				[self setupMessage:@"THE CAKE BLOCK! :)" :cutsceneMessageField];
				cutsceneFrames++;
				break;
			case STATE_CUTSCENE_TEXT4:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LAST_STATE]];
				[self setImageView:@"ChatBubble_001.png" :imageView :INT_MAX :32];
				[self setupMessage:@"HAIKU MODE ON." :cutsceneMessageField];
				break;
			case STATE_CUTSCENE_TEXT5:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LAST_STATE]];
				[self setupMessage:@"You deserve some cake.\nSweet delicious icing.\nThanks, I am not dead! :)" :cutsceneMessageField];
				break;
			case STATE_CUTSCENE_TEXT6:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LAST_STATE]];
				[self setupMessage:@"HAIKU MODE OFF." :cutsceneMessageField];
				break;
			case STATE_CUTSCENE_TEXT7:
				[gameState removeLastObject];
				[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_CUTSCENE_TEXT]];
				[self setupMessage:@"Now go! Create and share your own levels! This is not the last Goal Block we're going to see! :)" :cutsceneMessageField];
				cutsceneFrames++;
				break;
			case STATE_SETUP_CUTSCENE:
				[self setupCutscene];
				[gameState removeLastObject];
				break;
			case STATE_CUTSCENE:
				[self updateCutscene];
				[(EAGLView *)self.view setFramebuffer];
				[self drawCutscene];
				[(EAGLView *)self.view presentFramebuffer];
				break;
			case STATE_SAVE_AND_UPLOAD:
				[gameState removeLastObject];
				[self saveLogin];
				[self uploadUserLevel];
				break;
			case STATE_FADE_IN:
				if (fadeView.alpha < 0.1f)
				{
					fadeView.alpha = 0;
					[gameState removeLastObject];
					return;
				}
				else
				{
					fadeView.alpha -= ALPHA_FADE_INCREMENT;
				}
				break;
			case STATE_FADE_OUT:
				if (fadeView.alpha >= 0.9f)
				{
					fadeView.alpha = 1.0f;
					[gameState removeLastObject];
					return;
				}
				else
				{
					fadeView.alpha += ALPHA_FADE_INCREMENT;
				}
				break;
			case STATE_GP_SPLASH:
				frames++;

				if (frames >= SPLASH_FRAMES)
				{
					[gameState removeLastObject];
				}
				break;
			case STATE_SA_SPLASH:
				frames++;

				if (frames >= SPLASH_FRAMES)
				{
					[gameState removeLastObject];
				}
				break;
			case STATE_ADD_SA_SPLASH:
				[self setImageView:@"splash_StarshipAmazing.png" :imageView :INT_MAX :INT_MAX];
				frames = 0;
				[gameState removeLastObject];
				break;
			case STATE_ADD_OK_CANCEL:
				helpSubView.hidden = NO;
				mainMessageField.hidden = NO;
				okButton.hidden = NO;
				cancelButton.hidden = NO;
				[gameState removeLastObject];
				break;
			case STATE_INIT_OPENFEINT:
			{
				//check for iOS 4.1 and the availability of GKLocalPlayer for Game Center.
                /*
				Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

				NSString *reqSysVer = @"4.1";
				NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
				BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);

				NSNumber *enableGameCenter = [NSNumber numberWithBool:(gcClass && osVersionSupported)];

				NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft], OpenFeintSettingDashboardOrientation,
										  @"BlockHopper", OpenFeintSettingShortDisplayName,
										  [NSNumber numberWithBool:NO], OpenFeintSettingEnablePushNotifications,
										  [NSNumber numberWithBool:YES], OpenFeintSettingDisableUserGeneratedContent,
										  enableGameCenter, OpenFeintSettingGameCenterEnabled,
										  [NSNumber numberWithBool:NO], OpenFeintSettingAlwaysAskForApprovalInDebug,
//										  [NSNumber numberWithInt:OFDevelopmentMode_DEVELOPMENT], OpenFeintSettingDevelopmentMode,
										  [NSNumber numberWithInt:OFDevelopmentMode_RELEASE], OpenFeintSettingDevelopmentMode,
										  self.view.window, OpenFeintSettingPresentationWindow,
										  nil
										  ];
										  
				OFDelegatesContainer *delegates = [OFDelegatesContainer containerWithOpenFeintDelegate:self];

				[OpenFeint initializeWithProductKey:@"xhWB63mCoMNqgK5kzKXnTQ" andSecret:@"C4OLFZu5wbZVSGkNXtHa59lMamOno9aFhZrs6zmb4s" andDisplayName:@"BlockHopper" andSettings:settings andDelegates:delegates];
				*/
                 /*
				[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
				{
					if (error)
					{
						NSLog(error.localizedDescription);
					}
					else
					{
						NSLog(@"Reset Complete");
					}
				}];
				*/
    
				[gameState removeLastObject];
				break;
			}
			case STATE_ADD_MAIN_MENU:
			{
				[self setImageView:@"UI_MainMenu.png" :imageView :INT_MAX :INT_MAX];

				CGRect temp;
				temp = musicVolumeView.frame;
				temp.origin.x = 444;
				temp.origin.y = 126;
				musicVolumeView.frame = temp;

				temp = fxVolumeView.frame;
				temp.origin.x = 444;
				temp.origin.y = 164;
				fxVolumeView.frame = temp;

				startButton.hidden = NO;
				editorButton.hidden = NO;
				creditsButton.hidden = NO;
				ratingButton.hidden = NO;
				fxVolumeView.hidden = NO;
				musicVolumeView.hidden = NO;
				randomMusic = false;
				self.view.multipleTouchEnabled = true;
				[self playSong:0 repeats:YES];
				[gameState removeLastObject];
				break;
			}
			case STATE_REMOVE_UI_ELEMENTS:
				imageView.hidden = YES;
				retryButton.hidden = YES;
				retryField.hidden = YES;
				nextButton.hidden = YES;
				returnToLevelsButton.hidden = YES;
				hudView.hidden = YES;
				imageSubView.hidden = YES;
				timerField.hidden = YES;
				blockNumField.hidden = YES;
				mainMessageField.hidden = YES;
				pauseReturnButton.hidden = YES;
				pauseExitButton.hidden = YES;
				pauseConfigButton.hidden = YES;
				pauseRetryButton.hidden = YES;
				musicVolumeView.hidden = YES;
				fxVolumeView.hidden = YES;
				[self selectButtonGroup:BUTTON_GROUP_NONE];
				[gameState removeLastObject];
				lockButtons = false;
				break;
			case STATE_INCREMENT_LEVEL:
				currentLevel = (currentLevel + 1) < MAX_MAPS ? (currentLevel + 1) : 0;
				[gameState removeLastObject];
				break;
			case STATE_ADD_LEVEL_SELECT_ELEMENTS:
				switch (gameType)
				{
					case GAME_TYPE_STOCK_LEVEL:	
						menuButton.hidden = NO;
						userLevelsButton.hidden = NO;

						if (currentLevel >= MAX_LEVELS_PER_PAGE)
						{
							levelsPage = 1;
							prevLevelsButton.hidden = NO;
						}
						else
						{
							levelsPage = 0;

							if (levelProgress[MAX_LEVELS_PER_PAGE] > -1)
							{
								nextLevelsButton.hidden = NO;
							}
						}

						for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
						{
							levelButtons[i].hidden = YES;
							levelText[i].hidden = YES;

							if (i + (levelsPage * MAX_LEVELS_PER_PAGE) < 35)
							{
								if (levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)] > -1)
								{
									levelButtons[i].hidden = NO;
									[self setImageView:[medalImagePaths objectAtIndex:levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)]] :levelButtons[i] :levelButtons[i].frame.origin.x :levelButtons[i].frame.origin.y];
									levelText[i].hidden = NO;
									levelText[i].text = [NSString stringWithFormat:@"%d", (i + (levelsPage * MAX_LEVELS_PER_PAGE) + 1)];
								}
							}
						}
						[self setImageView:@"UI_LevelSelect.png" :imageView :INT_MAX :INT_MAX];
						break;
					case GAME_TYPE_USER_LEVEL:
						backButton.hidden = NO;
						searchButton.hidden = NO;

						userField1.hidden = NO;
						userField2.hidden = NO;
						userField3.hidden = NO;
						userField4.hidden = NO;

						if (pageNumber > 0)
						{
							prevUserLevelsButton.hidden = NO;
							firstUserLevelsButton.hidden = NO;
						}
						else
						{
							prevUserLevelsButton.hidden = YES;
							firstUserLevelsButton.hidden = YES;
						}	

						BOOL showNext = true;

						for (i = 0; i < 4; i++)
						{
							if (userLevelIDs[i] < 0)
							{
								showNext = false;
							}
						}

						if (showNext)
						{
							nextUserLevelsButton.hidden = NO;
						}
						else
						{
							nextUserLevelsButton.hidden = YES;
						}

						pageField.hidden = NO;
						pageField.text = [NSString stringWithFormat:@"Page: %d", (pageNumber + 1)];

						[self setImageView:@"UI_LevelSelectUsers.png" :imageView :INT_MAX :INT_MAX];
						break;
				}
				[gameState removeLastObject];
				break;
			case STATE_REMOVE_MAIN_MENU:
				startButton.hidden = YES;
				editorButton.hidden = YES;
				creditsButton.hidden = YES;
				ratingButton.hidden = YES;
				fxVolumeView.hidden = YES;
				musicVolumeView.hidden = YES;
				[gameState removeLastObject];
				break;
			case STATE_CLEAR_OPENGL:
				[(EAGLView *)self.view setFramebuffer];
				glClear(GL_COLOR_BUFFER_BIT);
				[(EAGLView *)self.view presentFramebuffer];
				[gameState removeLastObject];
				break;
			case STATE_REMOVE_LEVEL_SELECT_ELEMENTS:
				for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
				{
					levelButtons[i].hidden = YES;
					levelText[i].hidden = YES;
				}

				imageView.hidden = YES;
				menuButton.hidden = YES;
				nextLevelsButton.hidden = YES;
				prevLevelsButton.hidden = YES;
				userLevelsButton.hidden = YES;
				[gameState removeLastObject];
				break;
			case STATE_REMOVE_USER_LEVEL_ELEMENTS:
				backButton.hidden = YES;
				searchButton.hidden = YES;

				userField1.hidden = YES;
				userField2.hidden = YES;
				userField3.hidden = YES;
				userField4.hidden = YES;

				prevUserLevelsButton.hidden = YES;
				nextUserLevelsButton.hidden = YES;
				firstUserLevelsButton.hidden = YES;
				pageField.hidden = YES;

				for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
				{
					levelButtons[i].hidden = YES;
					levelText[i].hidden = YES;

					if (i + (levelsPage * MAX_LEVELS_PER_PAGE) < 35)
					{
						if (levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)] > -1)
						{
							levelButtons[i].hidden = NO;
							[self setImageView:[medalImagePaths objectAtIndex:levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)]] :levelButtons[i] :levelButtons[i].frame.origin.x :levelButtons[i].frame.origin.y];
							levelText[i].hidden = NO;
						}
					}
				}

				[self setImageView:@"UI_LevelSelect.png" :imageView :INT_MAX :INT_MAX];
				menuButton.hidden = NO;
				userLevelsButton.hidden = NO;

				if (levelsPage == 0 && levelProgress[MAX_LEVELS_PER_PAGE] > -1)
				{
					nextLevelsButton.hidden = NO;
				}
				if (levelsPage > 0)
				{
					prevLevelsButton.hidden = NO;
				}
				[gameState removeLastObject];
				break;
			case STATE_ADD_CREDITS:
				[self setImageView:@"UI_CreditsScreen.png" :imageView :INT_MAX :INT_MAX];
				backButton.hidden = NO;
				creditsField.hidden = NO;
				[gameState removeLastObject];
				break;
			case STATE_REMOVE_CREDITS:
				backButton.hidden = YES;
				creditsField.hidden = YES;
				[gameState removeLastObject];
				break;
			case STATE_ADD_EDITOR:
				self.view.multipleTouchEnabled = false;
				randomMusic = true;

				[self setupEditor];

				int choice = ((float)rand() / RAND_MAX) * [songPaths count];

				if (choice == [songPaths count])
				{
					choice--;
				}

				[musicPlayer stop];
				currentSong = -1;
				[self playSong:choice repeats:NO];
				[gameState removeLastObject];
				break;
			case STATE_REMOVE_EDITOR:
				gridView.hidden = YES;
				imageSubView.hidden = YES;
				helpSubView.hidden = YES;
				mainMessageField.hidden = YES;
				okButton.hidden = YES;
				cancelButton.hidden = YES;
				[gameState removeLastObject];
				break;
			case STATE_ADD_USER_LEVEL_ELEMENTS:
				[gameState removeLastObject];
				userField1.text = @"";
				userField2.text = @"";
				userField3.text = @"";
				userField4.text = @"";

				if (!connectionInUse)
				{
					connectionInUse = true;
					connectionType = CONNECTION_TYPE_USER_LEVELS;

					pageNumber = 0;

					NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getuserlevelsiOS.php?filter=%d&sort=%d&page=%d&resultsPerPage=%d&directSearch=%@&directSearchType=%d", filterIndex, sortIndex, pageNumber * MAX_USER_LEVELS, (MAX_USER_LEVELS + 1), directInputField.text ? [directInputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"", directInputField.text ? (directIndex + 1) : 0];
					NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
					[request setHTTPMethod:@"GET"];

					[connection release];
					connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
					[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
					timeoutFrames = 0;
				}

				menuButton.hidden = YES;
				userLevelsButton.hidden = YES;
				prevLevelsButton.hidden = YES;
				nextLevelsButton.hidden = YES;

				for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
				{
					levelButtons[i].hidden = YES;
					levelText[i].hidden = YES;
				}

				[self setImageView:@"UI_LevelSelectUsers.png" :imageView :INT_MAX :INT_MAX];

				backButton.hidden = NO;
				searchButton.hidden = NO;

				userField1.hidden = NO;
				userField2.hidden = NO;
				userField3.hidden = NO;
				userField4.hidden = NO;

				pageField.hidden = NO;
				pageField.text = [NSString stringWithFormat:@"Page: %d", (pageNumber + 1)];
				break;
			case STATE_REQUEST_USER_LEVEL:
				[gameState removeLastObject];
				connectionInUse = true;
				connectionType = CONNECTION_TYPE_LOAD_USER_LEVEL;
				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getiOS.php?id=%d", loadLevel]]];
				[request setHTTPMethod:@"GET"];
				[connection release];
				connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
				[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
				timeoutFrames = 0;
				break;
			case STATE_LOAD_MAP:
				[self loadNextLevel];
				break;
			case STATE_RELOAD_MAP:
				[self reloadLevel];
				break;
			case STATE_GAMEOVER:
				[self updateBlocks];
				[self updateProjectiles];
				[self drawGame];
				break;
			case STATE_PORTAL:
				[self updatePortal];
				[self drawGame];
				break;
			case STATE_RESULTS:
				[player setAnim:ANIM_PLAYER_DANCE];
				if (frames == 39)
				{
					if (gameType == GAME_TYPE_STOCK_LEVEL)
					{
						if (!playerHasGold && [self allLevelsHaveGold])
						{
							Image *playerImg = [[Image alloc] initWithString:@"playerGold.png"];
							[am.images replaceObjectAtIndex:0 withObject:playerImg];
							[playerImg release];

							Image *effectsImg = [[Image alloc] initWithString:@"effectsGold.png"];
							[am.images replaceObjectAtIndex:4 withObject:effectsImg];
							[effectsImg release];

							[self setImageView:@"messageWindowGOLD.png" :imageView :INT_MAX :INT_MAX];
							[gameState addObject:[NSNumber numberWithInteger:STATE_ALL_GOLD]];

							[self setupMessage:@"GET EQUIPPED WITH GOLD SUIT... Congratulations on getting a gold medal on every level!" :mainMessageField];
							mainMessageField.hidden = NO;
							playerHasGold = true;
							[self saveProgress];

							//[[OFAchievement achievement:@"1482222"] updateProgressionComplete:100.0f andShowNotification:YES];
						}
					}
					else if (gameType == GAME_TYPE_USER_LEVEL)
					{
						oneStar.hidden = NO;
						twoStar.hidden = NO;
						threeStar.hidden = NO;
						fourStar.hidden = NO;
						fiveStar.hidden = NO;
						helpSubView.hidden = NO;
						mainMessageField.text = @"What did you think? Please give the level a fair rating out of five! :)";
						mainMessageField.hidden = NO;
						[self playSound:SOUND_CLICK];
						[gameState addObject:[NSNumber numberWithInteger:STATE_RATING]];
					}
				}
				if (frames == 40)
				{
					imageView.hidden = NO;
					imageSubView.hidden = NO;
					
					CGRect tempFrame = timerField.frame;
					tempFrame.origin.x = (screenWidth - tempFrame.size.width) / 2;
					tempFrame.origin.y = (screenHeight - tempFrame.size.height) / 2 + 6;
					timerField.frame = tempFrame;
					timerField.hidden = NO;
					retryButton.hidden = NO;

					switch (gameType)
					{
						case GAME_TYPE_STOCK_LEVEL:
							returnToLevelsButton.hidden = NO;
							nextButton.hidden = NO;
							break;
						case GAME_TYPE_EDITOR_LEVEL:
							returnToEditorButton.hidden = NO;
							break;
						case GAME_TYPE_USER_LEVEL:
							returnToLevelsButton.hidden = NO;
							break;
					}
				}

				[self drawGame];
				frames++;
				break;
			case STATE_PRINT_INTRO_MESSAGE:
				currentMessageField.text = [message substringToIndex:textIndex];
				textIndex += 2;

				if (textIndex > [message length])
				{
					currentMessageField.text = message;
					[gameState removeLastObject];
				}
				break;
			case STATE_LEVEL_INTRO:
				[self updateLevelIntro];
				[self drawGame];
				break;
			case STATE_LEVEL_INIT:
				loop = false;
				[gameState removeLastObject];
				break;
			case STATE_COUNTDOWN:
				if (counter >= alarm)
				{
					counter = 0;
					[gameState removeLastObject];
				}

				counter++;
				[self drawGame];
				break;
			case STATE_PLACE_BLOCKS:
				[self drawGame];
				break;
			case STATE_TAP_TO_CONTINUE:
			case STATE_PAUSE:
			case STATE_CONFIG_BUTTONS:
				[self drawGame];
				break;
			case STATE_EDITOR:
				[self drawEditor];
				break;
		}
	}

	loop = !loop;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	int i;
	int j;
	NSArray *points = [touches allObjects];

	if ([self getGameState] == STATE_CONFIG_BUTTONS)
	{
		configButtonIndex = -1;
		return;
	}

	for (i = 0; i < [points count]; i++)
	{
		CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];

		if (pt.y < 32)
		{
			return;
		}

		if ([self getGameState] == STATE_EDITOR)
		{
			switch (editorState)
			{
				case EDITOR_STATE_FILL:
					if (selection.size.width == 0 || selection.size.height == 0)
					{
						return;
					}

					int fillBeginX = (int)selection.origin.x / TILE_SIZE;
					int fillEndX = (int)(selection.origin.x + selection.size.width) / TILE_SIZE;
					int fillBeginY = (int)selection.origin.y / TILE_SIZE;
					int fillEndY = (int)(selection.origin.y + selection.size.height) / TILE_SIZE;

					memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
					memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

					for (i = fillBeginY; i < fillEndY; i++)
					{
						for (j = fillBeginX; j < fillEndX; j++)
						{
							if ((i <= 2) || (j == 0) || (j == MAP_WIDTH - 1))
							{
								continue;
							}

							if (selectedTile > -1)
							{
								map[i][j] = selectedTile;
							}
							else
							{
								special[i][j] = selectedSpecial;
							}
						}
					}

					selection.size.width = 0;
					selection.size.height = 0;
					selection.origin.x = 0;
					selection.origin.y = 0;
					break;
			}
		}

		for (j = 0; j < [buttonsArray count]; j++)
		{
			GameButton *button = [buttonsArray objectAtIndex:j];

			if (!button.isActive)
			{
				continue;
			}

			if ([button releaseHitTest:pt])
			{
				switch (button.type)
				{
					case BUTTON_TYPE_LEFT:
						[button setAnim:ANIM_LEFT_BUTTON_UP];
						[self leftButtonUp];	
						break;
					case BUTTON_TYPE_RIGHT:
						[button setAnim:ANIM_RIGHT_BUTTON_UP];
						[self rightButtonUp];	
						break;
					case BUTTON_TYPE_UP:
						[button setAnim:ANIM_UP_BUTTON_UP];
						[self upButtonUp];	
						break;
					case BUTTON_TYPE_DOWN:
						[button setAnim:ANIM_DOWN_BUTTON_UP];
						[self downButtonUp];	
						break;
				}
			}
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	int i;
	int j;
	int tileX, tileY;
	GameButton *button;
	NSArray *allTouches = [[event allTouches] allObjects];
	NSArray *points = [touches allObjects];
	BOOL cancelJump = true;

	switch ([self getGameState])
	{
		case STATE_CONFIG_BUTTONS:
		{
			if (configButtonIndex > -1)
			{
				for (i = 0; i < [points count]; i++)
				{
					CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
					button = [buttonsArray objectAtIndex:configButtonIndex];
					CGRect tempBounds = button.bounds;
					tempBounds.origin.x = pt.x - tempBounds.size.width / 2;
					tempBounds.origin.y = pt.y - tempBounds.size.height / 2;
					button.bounds = tempBounds;
				}
			}
			return;
			break;
	}
		case STATE_EDITOR:
		{
			for (i = 0; i < [points count]; i++)
			{
				CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
				if (pt.y <= 32 || !helpSubView.hidden)
				{
					return;
				}
			}
			switch (editorState)
			{
				case EDITOR_STATE_PEN:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if (tileY <= 2 || tileX == 0 || tileX == MAP_WIDTH - 1)
						{
							return;
						}

						if (selectedTile > -1)
						{
							map[tileY][tileX] = selectedTile;
						}
						else
						{
							special[tileY][tileX] = selectedSpecial;
						}
					}
					break;
				case EDITOR_STATE_ERASE:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if (tileY <= 2 || tileX == 0 || tileX == MAP_WIDTH - 1)
						{
							return;
						}

						map[tileY][tileX] = 0;
						special[tileY][tileX] = 0;
					}
					break;
				case EDITOR_STATE_FILL:
				case EDITOR_STATE_SELECTION:	
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if ((((int)pt.x - bgOffsetX) % TILE_SIZE) > TILE_SIZE >> 1)
						{
							tileX++;
						}
						if ((((int)pt.y + bgOffsetY) % TILE_SIZE) > TILE_SIZE >> 1)
						{
							tileY++;
						}

						if (tileX * TILE_SIZE < editorStartX)
						{
							selection.size.width = abs(tileX * TILE_SIZE - editorStartX);
							selection.origin.x = tileX * TILE_SIZE;
						}
						else
						{
							selection.origin.x = editorStartX;
							selection.size.width = abs(tileX * TILE_SIZE - selection.origin.x);
						}

						if (tileY * TILE_SIZE < editorStartY)
						{
							selection.size.height = abs(tileY * TILE_SIZE - editorStartY);
							selection.origin.y = tileY * TILE_SIZE;
						}
						else
						{
							selection.origin.y = editorStartY;
							selection.size.height = abs(tileY * TILE_SIZE - selection.origin.y);
						}
					}
					break;
				case EDITOR_STATE_MOVE:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						if (fabs(pt.x - editorStartX) > 2.0f)
						{
							if (pt.x > editorStartX)
							{
								if (drawTileStartX > -1)
								{
									bgOffsetX += 16;

									if (bgOffsetX >= 0)
									{
										bgOffsetX = -TILE_SIZE;
										drawTileStartX--;
									}
								}
							}
							if (pt.x < editorStartX)
							{
								if (drawTileStartX < (MAP_WIDTH - drawTileWidth))
								{
									bgOffsetX -= 16;

									if (bgOffsetX <= -TILE_SIZE)
									{
										bgOffsetX = 0;
										drawTileStartX++;
									}
								}
							}
						}
						if (fabs(pt.y - editorStartY) > 2.0f)
						{
							if (pt.y > editorStartY)
							{
								if (drawTileStartY > 0)
								{
									bgOffsetY -= 16;

									if (bgOffsetY <= -TILE_SIZE)
									{
										bgOffsetY = 0;
										drawTileStartY--;
									}
								}
							}
							if (pt.y < editorStartY)
							{
								if (drawTileStartY <= (MAP_HEIGHT - drawTileHeight))
								{
									bgOffsetY += 16;

									if (bgOffsetY >= 0)
									{
										bgOffsetY = -TILE_SIZE;
										drawTileStartY++;
									}
								}
							}
						}

						editorStartX = pt.x;
						editorStartY = pt.y;
					}
					break;
			}
		}
		case STATE_PLAY:
		{
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];

				if (!button.isActive)
				{
					continue;
				}

				switch (button.type)
				{
					case BUTTON_TYPE_LEFT:
						[button setAnim:ANIM_LEFT_BUTTON_UP];
						break;
					case BUTTON_TYPE_RIGHT:
						[button setAnim:ANIM_RIGHT_BUTTON_UP];
						break;
					case BUTTON_TYPE_UP:
						[button setAnim:ANIM_UP_BUTTON_UP];
						break;
					case BUTTON_TYPE_DOWN:
						[button setAnim:ANIM_DOWN_BUTTON_UP];
						break;
				}
			}

			[self leftButtonUp];
			[self rightButtonUp];
			[self downButtonUp];

			for (i = 0; i < [allTouches count]; i++)
			{
				UITouch *touch = [allTouches objectAtIndex:i];
				CGPoint pt = [touch locationInView:self.view];

				if (pt.y < screenHeight - 56)
				{
//					continue;
				}

				for (j = 0; j < [buttonsArray count]; j++)
				{
					button = [buttonsArray objectAtIndex:j];

					if (!button.isActive)
					{
						continue;
					}

					if ([button pressHitTest:pt])
					{
						switch (button.type)
						{
							case BUTTON_TYPE_LEFT:
								[button setAnim:ANIM_LEFT_BUTTON_DOWN];
								[self leftButtonDown];	
								break;
							case BUTTON_TYPE_RIGHT:
								[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
								[self rightButtonDown];	
								break;
							case BUTTON_TYPE_UP:
								cancelJump = false;
								[button setAnim:ANIM_UP_BUTTON_DOWN];
								[self upButtonDown];	
								break;
							case BUTTON_TYPE_DOWN:
								[button setAnim:ANIM_DOWN_BUTTON_DOWN];
								[self downButtonDown];	
								break;
						}
					}
				}
			}

			if (cancelJump)
			{
				[self upButtonUp];
			}
			break;
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	int i;
	int j;
	int k;
	int tileX;
	int tileY;
	Block *block;
	NSArray *points = [touches allObjects];
	BOOL buttonPressed = false;
	BOOL resetJump = false; //to test if we should keep jumping or reset it
	int state = [self getGameState];

	if (state == STATE_PAUSE)
	{
		if (!fxVolumeView.hidden && !musicVolumeView.hidden)
		{
			for (i = 0; i < [points count]; i++)
			{
				CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];

				if ([Utils pointInBoxf:pt.x :pt.y :musicVolumeView.frame.origin.x :musicVolumeView.frame.size.width :musicVolumeView.frame.origin.y :musicVolumeView.frame.size.height])
				{
					musicOn = !musicOn;

					if (musicOn)
					{
						[self setImageView:@"btn_soundmusicON.png" :musicVolumeView :musicVolumeView.frame.origin.x :musicVolumeView.frame.origin.y];
						musicPlayer.volume = 1.0f;
					}
					else
					{
						[self setImageView:@"btn_soundmusicOFF.png" :musicVolumeView :musicVolumeView.frame.origin.x :musicVolumeView.frame.origin.y];
						musicPlayer.volume = 0.0f;
					}

					[self saveProgress];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :fxVolumeView.frame.origin.x :fxVolumeView.frame.size.width :fxVolumeView.frame.origin.y :fxVolumeView.frame.size.height])
				{
					fxOn = !fxOn;

					if (fxOn)
					{
						[self setImageView:@"btn_soundfxON.png" :fxVolumeView :fxVolumeView.frame.origin.x :fxVolumeView.frame.origin.y];
					}
					else
					{
						[self setImageView:@"btn_soundfxOFF.png" :fxVolumeView :fxVolumeView.frame.origin.x :fxVolumeView.frame.origin.y];
					}

					[self saveProgress];
				}
			}
		}

		return;
	}

	else if (state == STATE_CONFIG_BUTTONS)
	{
		for (i = 0; i < [points count]; i++)
		{
			CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];

			for (j = 0; j < [buttonsArray count]; j++)
			{
				GameButton *button = [buttonsArray objectAtIndex:j];
				
				if (!button.isActive)
				{
					continue;
				}

				if ([button pressHitTest:pt])
				{
					configButtonIndex = j;
					return;
				}
			}
		}

		return;
	}

	switch (state)
	{
		case STATE_NETWORK_ERROR:
			networkErrorView.hidden = YES;
			errorMessageField.hidden = YES;
			[gameState removeLastObject];
			break;
		case STATE_LEVEL_INPUT_ERROR:
			searchButton.hidden = NO;
			backButton.hidden = NO;
			prevDirectButton.hidden = NO;
			nextDirectButton.hidden = NO;
			directField.hidden = NO;
			directInputField.hidden = NO;
			currentMessageField.hidden = YES;
			helpSubView.hidden = YES;
			[gameState removeLastObject];
			break;
		case STATE_ALL_GOLD:
			[self setImageView:@"levelresults.png" :imageView :INT_MAX :INT_MAX];
			mainMessageField.hidden = YES;
			[gameState removeLastObject];
			break;
		case STATE_REGISTER_ERROR:
			okButton.hidden = NO;
			cancelButton.hidden = NO;
			helpSubView.hidden = YES;
			mainMessageField.hidden = YES;
			registerPasswordField1.hidden = NO;
			registerPasswordField2.hidden = NO;
			registerUsernameField.hidden = NO;
			registerEmailField.hidden = NO;
			[gameState removeLastObject];
			break;
		case STATE_REGISTER_SUCCESS:
			helpSubView.hidden = YES;
			mainMessageField.hidden = YES;
			[gameState removeLastObject];
			break;
		case STATE_INVALID_PASSWORD:
			helpSubView.hidden = YES;
			mainMessageField.hidden = YES;
			loginButton.hidden = NO;
			registerButton.hidden = NO;
			cancelButton.hidden = NO;
			usernameField.hidden = NO;
			passwordField.hidden = NO;
			[gameState removeLastObject];
			break;
		case STATE_REMOVE_CUTSCENE_TEXT:
			[gameState removeLastObject];
			imageView.hidden = YES;
			cutsceneMessageField.hidden = YES;
			break;
		case STATE_REMOVE_LAST_STATE:
			[gameState removeLastObject];
			break;
		case STATE_REMOVE_HELP_MESSAGE:
			[gameState removeLastObject];
			helpSubView.hidden = YES;
			currentMessageField.hidden = YES;
			break;
		case STATE_LEVEL_UPLOAD_SUCCESS:
			[gameState removeLastObject];
			if ([self getGameState] == STATE_LOGIN)
			{
				[self cancelButtonPressed];
			}
			else
			{
				mainMessageField.hidden = YES;
				helpSubView.hidden = YES;
			}
			break;
		case STATE_TAP_TO_CONTINUE:
			[gameState removeLastObject];
			resetJump = true;
			break;
		case STATE_PRINT_INTRO_MESSAGE:
			currentMessageField.text = message;
			[gameState removeLastObject];
			break;
		case STATE_BLOCK_INTRO:
		{
			[self setImageView:@"UI_GameGrid.png" :imageView :bgOffsetX :-bgOffsetY];
			imageSubView.hidden = YES;
			mainMessageField.hidden = YES;
			GameButton *button = [buttonsArray objectAtIndex:BUTTON_OK_INDEX];
			button.isActive = true;
			[gameState removeLastObject];
			return;
			break;
		}
		case STATE_CHECKPOINT_INTRO:
		{
			imageView.hidden = YES;
			imageSubView.hidden = YES;
			timerField.hidden = NO;
			mainMessageField.hidden = YES;
			hudView.hidden = NO;
			GameButton *button = [buttonsArray objectAtIndex:BUTTON_NEXT_MAP_INDEX];
			button.isActive = true;
			button = [buttonsArray objectAtIndex:BUTTON_SELF_DESTRUCT_INDEX];
			button.isActive = true;
			button = [buttonsArray objectAtIndex:BUTTON_PREV_BLOCK_INDEX];
			button.isActive = true;
			button = [buttonsArray objectAtIndex:BUTTON_NEXT_BLOCK_INDEX];
			button.isActive = true;

			if (blocksAvailable[blocksAvailableIndex])
			{
				currentBlock.drawBlock = true;
				blockNumField.hidden = NO;
			}

			[self saveProgress];
			[gameState removeLastObject];
			return;
			break;
		}
		case STATE_INTRO_MESSAGE:
			for (j = 0; j < MAX_USER_BLOCKS; j++)
			{
				blockImages[j].hidden = YES;
			}

			blocksAvailableField.hidden = YES;
			imageView.hidden = YES;
			currentMessageField.hidden = YES;
			goldTimeField.hidden = YES;
			silverTimeField.hidden = YES;
			bronzeTimeField.hidden = YES;
			hudView.hidden = NO;
			timerField.hidden = NO;
			counter = 0;

			if (showBlockIntro)
			{
				[self selectButtonGroup:BUTTON_GROUP_BLOCKS_INTRO];
			}
			else
			{
				[self selectButtonGroup:BUTTON_GROUP_PLAY];
			}

			if (blocksAvailable[blocksAvailableIndex])
			{
				currentBlock.drawBlock = true;
				blockNumField.hidden = NO;
			}
			showIntro = false;
			[gameState removeLastObject];
			[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];

			if (gameType == GAME_TYPE_STOCK_LEVEL)
			{
				switch (currentLevel)
				{
					case 2:
						[self showIntroBlock :BLOCK_TYPE_DEFAULT];
						break;
					case 7:
						[self showIntroBlock :BLOCK_TYPE_UPDOWN];
						break;
					case 8:
						[self showIntroBlock :BLOCK_TYPE_LEFTCONVEYOR];
						break;
					case 9:
						[self showIntroBlock :BLOCK_TYPE_SPRINGBOARD];
						break;
					case 10:
						[self showIntroBlock :BLOCK_TYPE_FIRE];
						break;
					case 12:
						[self showIntroBlock :BLOCK_TYPE_MOVINGSPIKES];
						break;
					case 13:
						[self showIntroBlock :BLOCK_TYPE_GUN];
						break;
					case 14:
						[self showIntroBlock :BLOCK_TYPE_INVISIBLE];
						break;
					case 15:
						[self showIntroBlock :BLOCK_TYPE_BOMB];
						break;
					case 17:
						[self showIntroBlock :BLOCK_TYPE_CRYSTAL];
						break;
					case 18:
						[self showIntroBlock :BLOCK_TYPE_LASER];
						break;
					case 21:
						[self showIntroBlock :BLOCK_TYPE_REDPORTAL];
						break;
				}
			}
			return;
			break;
		case STATE_GAMEOVER:
			if (!imageView.hidden)
			{
				[gameState removeLastObject];
			}
			return;
			break;
	}

	for (i = 0; i < [points count]; i++)
	{
		CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];

		switch (state)
		{
			case STATE_USER_LEVELS:
				if (!connectionInUse)
				{
					loadLevel = -1;

					if (!userField1.hidden && [Utils pointInBoxf:pt.x :pt.y :userField1.frame.origin.x :userField1.frame.size.width :userField1.frame.origin.y :userField1.frame.size.height] && userLevelIDs[0] > -1)
					{
						loadLevel = userLevelIDs[0];
						selectedUser = 0;
					}
					else if (!userField2.hidden && [Utils pointInBoxf:pt.x :pt.y :userField2.frame.origin.x :userField2.frame.size.width :userField2.frame.origin.y :userField2.frame.size.height] && userLevelIDs[1] > -1)
					{
						loadLevel = userLevelIDs[1];
						selectedUser = 1;
					}
					else if (!userField3.hidden && [Utils pointInBoxf:pt.x :pt.y :userField3.frame.origin.x :userField3.frame.size.width :userField3.frame.origin.y :userField3.frame.size.height] && userLevelIDs[2] > -1)
					{
						loadLevel = userLevelIDs[2];
						selectedUser = 2;
					}
					else if (!userField4.hidden && [Utils pointInBoxf:pt.x :pt.y :userField4.frame.origin.x :userField4.frame.size.width :userField4.frame.origin.y :userField4.frame.size.height] && userLevelIDs[3] > -1)
					{
						loadLevel = userLevelIDs[3];
						selectedUser = 3;
					}

					if (loadLevel > -1)
					{
						[self playSound:SOUND_BUTTON];

						[gameState addObject:[NSNumber numberWithInteger:STATE_REQUEST_USER_LEVEL]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
					}
				}
				break;
			case STATE_MAIN_MENU:
				if ([Utils pointInBoxf:pt.x :pt.y :0 :60.0f :0 :60.0f])
				{
				//	[OpenFeint launchDashboard];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :437.0f :43.0f :0 :54.0f])
				{
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/greenpixeldev"]];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :393.0f :43.0f :0 :54.0f])
				{
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/pages/Green-Pixel/138986542876870?sk=info"]];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :337.0f :55.0f :0 :55.0f])
				{
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.greenpixel.ca"]];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :musicVolumeView.frame.origin.x :musicVolumeView.frame.size.width :musicVolumeView.frame.origin.y :musicVolumeView.frame.size.height])
				{
					musicOn = !musicOn;

					if (musicOn)
					{
						[self setImageView:@"btn_soundmusicON.png" :musicVolumeView :444 :126];
						musicPlayer.volume = 1.0f;
					}
					else
					{
						[self setImageView:@"btn_soundmusicOFF.png" :musicVolumeView :444 :126];
						musicPlayer.volume = 0.0f;
					}

					[self saveProgress];
				}
				else if ([Utils pointInBoxf:pt.x :pt.y :fxVolumeView.frame.origin.x :fxVolumeView.frame.size.width :fxVolumeView.frame.origin.y :fxVolumeView.frame.size.height])
				{
					fxOn = !fxOn;

					if (fxOn)
					{
						[self setImageView:@"btn_soundfxON.png" :fxVolumeView :444 :164];
					}
					else
					{
						[self setImageView:@"btn_soundfxOFF.png" :fxVolumeView :444 :164];
					}

					[self saveProgress];
				}
				return;
				break;
			case STATE_LEVEL_SELECT:
				for (j = 0; j < MAX_LEVELS_PER_PAGE; j++)
				{
					LevelButton *b = levelButtons[j];

					if (!b.hidden && [Utils pointInBoxf:pt.x :pt.y :b.frame.origin.x :b.frame.size.width :b.frame.origin.y :b.frame.size.height])
					{
						previousBackground = -1;
						currentLevel = b.index + (levelsPage * MAX_LEVELS_PER_PAGE);

						[gameState removeAllObjects];
						[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_LOAD_MAP]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LEVEL_SELECT_ELEMENTS]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_CLEAR_OPENGL]];

						gameType = GAME_TYPE_STOCK_LEVEL;
						showIntro = true;
						[self playSound:SOUND_BUTTON];
						return;
					}
				}
				break;
		}

		for (j = 0; j < [buttonsArray count]; j++)
		{
			GameButton *button = [buttonsArray objectAtIndex:j];
			
			if (!button.isActive || (!currentBlock.drawBlock && (button.type == BUTTON_TYPE_NEXT_BLOCK || button.type == BUTTON_TYPE_BLOCK || button.type == BUTTON_TYPE_PREV_BLOCK)))
			{
				continue;
			}

			if ([button pressHitTest:pt])
			{
				int oldBlockIndex = blocksAvailableIndex;

				switch (button.type)
				{
					case BUTTON_TYPE_LEFT:
						[button setAnim:ANIM_LEFT_BUTTON_DOWN];
						[self leftButtonDown];	
						break;
					case BUTTON_TYPE_RIGHT:
						[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
						[self rightButtonDown];	
						break;
					case BUTTON_TYPE_UP:
						resetJump = false;
						[button setAnim:ANIM_UP_BUTTON_DOWN];
						[self upButtonDown];	
						break;
					case BUTTON_TYPE_DOWN:
						[button setAnim:ANIM_DOWN_BUTTON_DOWN];
						[self downButtonDown];	
						break;
					case BUTTON_TYPE_BLOCK:
						if ([self getGameState] == STATE_PLAY)
						{
							[self rightButtonUp];
							[self leftButtonUp];
							[self downButtonUp];
							[self selectButtonGroup:BUTTON_GROUP_BLOCKS];

							for (k = 0; k < [buttonsArray count]; k++)
							{
								GameButton *tempButton = [buttonsArray objectAtIndex:k];

								switch (tempButton.type)
								{
									case BUTTON_TYPE_LEFT:
										[tempButton setAnim:ANIM_LEFT_BUTTON_UP];
										break;
									case BUTTON_TYPE_RIGHT:
										[tempButton setAnim:ANIM_RIGHT_BUTTON_UP];
										break;
									case BUTTON_TYPE_UP:
										[tempButton setAnim:ANIM_UP_BUTTON_UP];
										break;
									case BUTTON_TYPE_DOWN:
										[tempButton setAnim:ANIM_DOWN_BUTTON_UP];
										break;
								}
							}

							[self playSound:SOUND_BLOCKMODE];
							[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
							[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
							[gameState addObject:[NSNumber numberWithInteger:STATE_PLACE_BLOCKS]];
							if (showBlockIntro)
							{
								[self setImageView:@"messageWindow.png" :imageView :INT_MAX :INT_MAX];
								[gameState addObject:[NSNumber numberWithInteger:STATE_BLOCK_INTRO]];
								[gameState addObject:[NSNumber numberWithInteger:STATE_PRINT_INTRO_MESSAGE]];
								[message release];
								message = [[NSString alloc] initWithFormat:@"Welcome to Block Mode! Here you can place blocks by touching the grid. When you are finished, press the button in the upper-left to return. The game will remain paused until you touch the screen again, so you can continue jumping or moving!"];
								showBlockIntro = false;
								textIndex = 0;
								currentMessageField = mainMessageField;
								mainMessageField.text = @"";
								mainMessageField.hidden = NO;
							}
							else
							{
								[self setImageView:@"UI_GameGrid.png" :imageView :bgOffsetX :-bgOffsetY];
							}

							[self drawGame];
						}
						break;
					case BUTTON_TYPE_OK:
						[self playSound:SOUND_CLICK];
						[gameState removeLastObject];
						imageView.hidden = YES;
						[self setupCrystals];
						[self selectButtonGroup:BUTTON_GROUP_PLAY];
						break;
					case BUTTON_TYPE_DESTRUCT:
						[self killPlayer:DEATH_EXPLOSION];
						break;
					case BUTTON_TYPE_NEXT_MAP:
						if (!buttonPressed)
						{
							[gameState addObject:[NSNumber numberWithInteger:STATE_PAUSE]];
							[self setImageView:@"UI_PauseMenu.png" :imageView :INT_MAX :0];

							CGRect temp = goldTimeField.frame;
							temp.origin.y += 32;
							goldTimeField.frame = temp;
							goldTimeField.hidden = NO;

							temp = silverTimeField.frame;
							temp.origin.y += 32;
							silverTimeField.frame = temp;
							silverTimeField.hidden = NO;

							temp = bronzeTimeField.frame;
							temp.origin.y += 32;
							bronzeTimeField.frame = temp;
							bronzeTimeField.hidden = NO;

							temp = musicVolumeView.frame;
							temp.origin.x = 91;
							temp.origin.y = 109;
							musicVolumeView.frame = temp;

							temp = fxVolumeView.frame;
							temp.origin.x = 357;
							temp.origin.y = 109;
							fxVolumeView.frame = temp;

							pauseReturnButton.hidden = NO;
							pauseExitButton.hidden = NO;
							pauseConfigButton.hidden = NO;
							pauseRetryButton.hidden = NO;
							musicVolumeView.hidden = NO;
							fxVolumeView.hidden = NO;
						}
						break;
					case BUTTON_TYPE_PREV_BLOCK:
						[self getBlockIndex :-1];
						if (oldBlockIndex != blocksAvailableIndex)
						{
							[self playSound:SOUND_CLICK];
						}
						break;
					case BUTTON_TYPE_NEXT_BLOCK:
						[self getBlockIndex :1];
						if (oldBlockIndex != blocksAvailableIndex)
						{
							[self playSound:SOUND_CLICK];
						}
						break;
				}

				buttonPressed = true;
			}
		}
	}

	if (resetJump)
	{
		[self upButtonUp];
	}
	if (buttonPressed)
	{
		return;
	}

	switch (state)
	{
		case STATE_PLACE_BLOCKS:
			for (i = 0; i < [points count]; i++)
			{
				CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
				BOOL addBlock = true;

				tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
				tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

				if (!blocksAvailable[blocksAvailableIndex] || pt.y < 48.0f)
				{
					return;
				}

				if ([Tile hasFlag:map[tileY][tileX] :WALL] || (goalX == tileX && goalY == tileY))
				{
					continue;
				}

				if ([Utils boxInBox:player.x :player.width :player.y :player.height :tileX * TILE_SIZE :TILE_SIZE :tileY * TILE_SIZE :TILE_SIZE])
				{
					if (![self playerMoveUp:(abs(tileY * TILE_SIZE - (player.y + player.height)))])
					{
						return;
					}

					player.state = PLAYER_IDLE;
					player.jump = 0;
					canJump = JUMP_CLEAR;
					if (player.flip)
					{
						[player setAnim:ANIM_PLAYER_IDLE_LEFT];
					}
					else
					{
						[player setAnim:ANIM_PLAYER_IDLE_RIGHT];
					}
					[self centerWorld];
					[self setImageView:@"UI_GameGrid.png" :imageView :bgOffsetX :-bgOffsetY];
				}

				for (i = 0; i < blockIndex; i++)
				{
					block = [blockQueue objectAtIndex:i];

					if (!block.isAlive || !block.drawBlock)
					{
						continue;
					}

					int mX = pt.x - bgOffsetX + (TILE_SIZE * drawTileStartX);
					int mY = pt.y + bgOffsetY + (TILE_SIZE * drawTileStartY);

					mX /= TILE_SIZE;
					mX *= TILE_SIZE;
					mY /= TILE_SIZE;
					mY *= TILE_SIZE;

					if ([Utils boxInBox:mX :TILE_SIZE :mY :TILE_SIZE :block.x :TILE_SIZE :block.y :TILE_SIZE])
					{
						addBlock = false;
						break;
					}
				}

				if (addBlock)
				{
					Block *addedBlock = [[Block alloc] initBlock:blocksAvailableIndex WithAssetManager:am];
					addedBlock.x = tileX * TILE_SIZE;
					addedBlock.y = tileY * TILE_SIZE;
					[blockQueue addObject:addedBlock];
					blockIndex++;
					blocksAvailable[blocksAvailableIndex]--;

					switch (currentBlock.type)
					{
						case BLOCK_TYPE_LEFTRIGHT:
							if ([currentBlock getAnim] == ANIM_LEFT_PLATFORM)
							{
								addedBlock.heading.x *= -1;
								[addedBlock setBlockAnim:ANIM_LEFT_PLATFORM];
								addedBlock.currentFrame = 134;
							}
							else
							{
								addedBlock.currentFrame = 154;
							}
							break;
						case BLOCK_TYPE_UPDOWN:
							if ([currentBlock getAnim] == ANIM_UP_PLATFORM)
							{
								addedBlock.heading.y *= -1;
								[addedBlock setBlockAnim:ANIM_UP_PLATFORM];
								addedBlock.currentFrame = 180;
							}
							else
							{
								addedBlock.currentFrame = 204;
							}
							break;
					}

					blockNumField.text = [NSString stringWithFormat:@"%d", blocksAvailable[blocksAvailableIndex]];

					Billboard *b = [self getAvailableBillboard];
					[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
					[self playSound:SOUND_ADD_BLOCK];

					if (!blocksAvailable[blocksAvailableIndex])
					{
						[self getBlockIndex:1];
					}

					if (!blocksAvailable[blocksAvailableIndex])
					{
						GameButton *button;
						button = [buttonsArray objectAtIndex:BUTTON_PREV_BLOCK_INDEX];
						[button setAnim:ANIM_LEFT_BUTTON_UP];
						button = [buttonsArray objectAtIndex:BUTTON_NEXT_BLOCK_INDEX];
						[button setAnim:ANIM_RIGHT_BUTTON_UP];
						currentBlock.drawBlock = false;
						blockNumField.hidden = YES;
					}

					[addedBlock release];

					if (addedBlock.type == BLOCK_TYPE_CRYSTAL)
					{
						for (i = 0; i < blockIndex; i++)
						{
							CGRect zone;
							block = [blockQueue objectAtIndex:i];

							if (!block.isAlive ||
								block.type != BLOCK_TYPE_LASER)
							{
								continue;	
							}

							if (addedBlock.y - block.y == 0 && //crystal is to the right
								addedBlock.x > block.x)
							{
								zone = [[block.damageZones objectAtIndex:0] CGRectValue];

								if (addedBlock.x <= block.x + zone.size.width)
								{
									zone.size.width = abs((block.x + TILE_SIZE) - addedBlock.x);
									[block.damageZones replaceObjectAtIndex:0 withObject:[NSValue valueWithCGRect:zone]];
								}
							}
							else if (addedBlock.y - block.y == 0 && //crystal is to the left
								addedBlock.x < block.x)
							{
								zone = [[block.damageZones objectAtIndex:1] CGRectValue];

								if (addedBlock.x >= (block.x + zone.origin.x))
								{
									zone.size.width = abs(block.x - (addedBlock.x + TILE_SIZE));
									zone.origin.x = -zone.size.width;
									[block.damageZones replaceObjectAtIndex:1 withObject:[NSValue valueWithCGRect:zone]];
								}
							}
							else if (addedBlock.x - block.x == 0 && //crystal is above
									addedBlock.y < block.y)
							{
								zone = [[block.damageZones objectAtIndex:2] CGRectValue];

								if (addedBlock.y >= (block.y + zone.origin.y))
								{
									zone.size.height = abs(block.y - (addedBlock.y + TILE_SIZE));
									zone.origin.y = -zone.size.height;
									[block.damageZones replaceObjectAtIndex:2 withObject:[NSValue valueWithCGRect:zone]];
								}
							}
							else if (addedBlock.x - block.x == 0 && //crystal is below
									addedBlock.y > block.y)
							{
								zone = [[block.damageZones objectAtIndex:3] CGRectValue];

								if (addedBlock.y <= (block.y + zone.size.height))
								{
									zone.size.height = abs((block.y + TILE_SIZE) - addedBlock.y);
									[block.damageZones replaceObjectAtIndex:3 withObject:[NSValue valueWithCGRect:zone]];
								}
							}
						}
					}
				}
			}
			break;
		case STATE_EDITOR:
		{
			for (i = 0; i < [points count]; i++)
			{
				CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
				int selectionPlacementX = (int)pt.x / TILE_SIZE * TILE_SIZE;

				if (!helpSubView.hidden && pt.y > 32)
				{
					return;
				}

				if (editorState == EDITOR_STATE_TILES)
				{
					//user has pressed inside the tile set
					if (pt.x > EDITOR_OFFSET_X && pt.x < EDITOR_OFFSET_X + TILE_SIZE * 7 && pt.y > EDITOR_OFFSET_Y && pt.y < EDITOR_OFFSET_Y + TILE_SIZE * 6)
					{
						int tileX = ((int)pt.x - EDITOR_OFFSET_X) / TILE_SIZE;
						int tileY = ((int)pt.y - EDITOR_OFFSET_Y) / TILE_SIZE;
						selectedTile = (tileY << TILE_YPOS_SHIFT) | (tileX << TILE_XPOS_SHIFT);
						if (selectedTile)
						{
							selectedTile |= WALL;
						}

						[self setImageView:@"editorSelection.png" :imageSubView :tileX * TILE_SIZE + EDITOR_OFFSET_X :tileY * TILE_SIZE + EDITOR_OFFSET_Y];
						selectedSpecial = -1;
					}
					//user has pressed inside the special tiles
					else if (pt.x > 2 * EDITOR_OFFSET_X + 7 * TILE_SIZE && pt.x < 2 * EDITOR_OFFSET_X + 12 * TILE_SIZE && pt.y > EDITOR_OFFSET_Y + TILE_SIZE && pt.y < EDITOR_OFFSET_Y + 5 * TILE_SIZE)
					{
						int tileX = ((int)pt.x - (2 * EDITOR_OFFSET_X + 7 * TILE_SIZE)) / TILE_SIZE;
						int tileY = ((int)pt.y - (EDITOR_OFFSET_Y + TILE_SIZE)) / TILE_SIZE;

						selectedSpecial = tileX + 5 * tileY;
						[self setImageView:@"editorSelection.png" :imageSubView :tileX * TILE_SIZE + EDITOR_OFFSET_X + 8 * TILE_SIZE :tileY * TILE_SIZE + EDITOR_OFFSET_Y + TILE_SIZE];
						selectedTile = -1;
					}
				}
				else if (editorState == EDITOR_STATE_MAP_PROPERTIES)
				{
					//hax to do nothing when the map properties are visible.
				}
				else if (pt.y <= 32)
				{
					if (pt.x >= screenWidth - 32)
					{
						[self playSound:SOUND_CLICK];

						if (!helpSubView.hidden)
						{
							[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_QUIT] :mainMessageField];
						}
						else
						{
							[gameState addObject:[NSNumber numberWithInteger:STATE_OK_CANCEL]];
							[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_OK_CANCEL]];
							mainMessageField.text = @"Are you sure you want to quit to the main menu? Any unsaved edits will be lost. You can save your level by pressing the Save Icon located in the second set of editor buttons.";
							okCancelState = OK_CANCEL_STATE_QUIT;
							return;
						}
					}

					if (!editorButtonsRow)
					{
						[self playSound:SOUND_CLICK];

						if (pt.x < 32)
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_SELECTION] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_SELECTION;	
							}
						}
						else if (pt.x < 64)
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_PEN] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_PEN;
							}
						}
						else if (pt.x < 96)
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_FILL] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_FILL;
							}
						}
						else if (pt.x < 128)
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_ERASE] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_ERASE;
							}
						}
						else if (pt.x < 160) //undo
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_UNDO] :mainMessageField];
							}
							else
							{
								memcpy(map, undoMap, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
								memcpy(special, undoSpecial, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
								return;
							}
						}
						else if (pt.x < 192) //cut
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_CUT] :mainMessageField];
							}
							else
							{
								if (selection.size.width == 0 || selection.size.height == 0)
								{
									return;
								}

								copyBounds.origin.x = selection.origin.x;
								copyBounds.origin.y = selection.origin.y;
								copyBounds.size.width = selection.size.width;
								copyBounds.size.height = selection.size.height;

								int fillBeginX = (int)selection.origin.x / TILE_SIZE;
								int fillEndX = (int)(selection.origin.x + selection.size.width) / TILE_SIZE;
								int fillBeginY = (int)selection.origin.y / TILE_SIZE;
								int fillEndY = (int)(selection.origin.y + selection.size.height) / TILE_SIZE;

								memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
								memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

								for (i = fillBeginY; i < fillEndY; i++)
								{
									for (j = fillBeginX; j < fillEndX; j++)
									{
										copyBuffer[i][j] = map[i][j];
										copySpecialBuffer[i][j] = special[i][j];

										if (i <= 2 || j == 0 || j == (MAP_WIDTH - 1))
										{
											continue;
										}

										map[i][j] = 0;
										special[i][j] = 0;
									}
								}

								selectionPlacementX = 0;
							}
						}
						else if (pt.x < 224) //copy
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_COPY] :mainMessageField];
							}
							else
							{
								if (selection.size.width == 0 || selection.size.height == 0)
								{
									return;
								}

								copyBounds.origin.x = selection.origin.x;
								copyBounds.origin.y = selection.origin.y;
								copyBounds.size.width = selection.size.width;
								copyBounds.size.height = selection.size.height;

								int fillBeginX = (int)selection.origin.x / TILE_SIZE;
								int fillEndX = (int)(selection.origin.x + selection.size.width) / TILE_SIZE;
								int fillBeginY = (int)selection.origin.y / TILE_SIZE;
								int fillEndY = (int)(selection.origin.y + selection.size.height) / TILE_SIZE;

								for (i = fillBeginY; i < fillEndY; i++)
								{
									for (j = fillBeginX; j < fillEndX; j++)
									{
										copyBuffer[i][j] = map[i][j];
										copySpecialBuffer[i][j] = special[i][j];
									}
								}
								selectionPlacementX = 0;
							}
						}
						else if (pt.x < 256) //paste
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_PASTE] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_PASTE;
							}
						}
						else if (pt.x < 288) //movement
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_MOVE] :mainMessageField];
							}
							else
							{
								editorState = EDITOR_STATE_MOVE;
							}
						}
						else if (pt.x < 320) //map properties window
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_MAP_PROPERTIES] :mainMessageField];
							}
							else
							{
								[self setImageView:@"UI_Editor_BlockPanel.png" :imageView :INT_MAX :INT_MAX];
								editorOldState = editorState;
								editorState = EDITOR_STATE_MAP_PROPERTIES;
								backButton.hidden = NO;

								for (j = 0; j < MAX_USER_BLOCKS; j++)
								{
									blockAmounts[j].hidden = NO;
								}

								editorGoldTimeField.hidden = NO;
								editorSilverTimeField.hidden = NO;
								editorBronzeTimeField.hidden = NO;
								diffField.hidden = NO;
								diffTextField.hidden = NO;
								[self convertUserTime:editorGoldTimeField :goldTime];
								[self convertUserTime:editorSilverTimeField :silverTime];
								[self convertUserTime:editorBronzeTimeField :bronzeTime];
								diffField.text = [diffText objectAtIndex:diffIndex];
								leftDifficultyButton.hidden = NO;
								rightDifficultyButton.hidden = NO;
								leftGoldButton.hidden = NO;
								rightGoldButton.hidden = NO;
								leftSilverButton.hidden = NO;
								rightSilverButton.hidden = NO;
								leftBronzeButton.hidden = NO;
								rightBronzeButton.hidden = NO;
								gridView.hidden = YES;
								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 352) //tile sheet
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_TILES] :mainMessageField];
							}
							else
							{
								selection.origin.x = 0;
								selection.origin.y = 0;
								selection.size.width = 0;
								selection.size.height = 0;
								[self setImageView:@"UI_Editor_TilesPanel.png" :imageView :INT_MAX :INT_MAX];

								if (selectedTile > -1)
								{
									int tileX = [Tile getImageX:selectedTile];
									int tileY = [Tile getImageY:selectedTile];

									[self setImageView:@"editorSelection.png" :imageSubView :tileX * TILE_SIZE + EDITOR_OFFSET_X :tileY * TILE_SIZE + EDITOR_OFFSET_Y];
								}
								else
								{
									int tileX = (selectedSpecial % 5);
									int tileY = (selectedSpecial / 5);

									[self setImageView:@"editorSelection.png" :imageSubView :tileX * TILE_SIZE + EDITOR_OFFSET_X + 8 * TILE_SIZE :tileY * TILE_SIZE + EDITOR_OFFSET_Y + TILE_SIZE];

								}

								editorOldState = editorState;
								editorState = EDITOR_STATE_TILES;
								backButton.hidden = NO;
								leftBGTypeButton.hidden = NO;
								rightBGTypeButton.hidden = NO;
								editorBGTypeField.hidden = NO;
								editorBGField.hidden = NO;
								editorBGTypeField.text = [bgText objectAtIndex:editorBGIndex];
								gridView.hidden = YES;
								return;
							}
						}
						else if (pt.x < 384) //load level
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_RUN] :mainMessageField];
							}
							else
							{
								[self removeDuplicatePlayerAndGoal];
								int goalAndPlayerStatus = [self checkForGoalAndPlayerStart];
								if (goalAndPlayerStatus == EDITOR_HAS_PLAYER_AND_GOAL)
								{
									returnToEditorButton.hidden = YES;
									imageSubView.hidden = YES;
									[self loadEditorLevel];
								}
								else
								{
									NSString *errorString = @"Oops, we encountered a problem when trying to run the level! You must assign a starting position for Bit and the Goal Block. You can find Bit and the Goal Block by pressing the Tile Selection icon just to the left of this one!";

									[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
									helpSubView.hidden = NO;
									mainMessageField.text = errorString;
									mainMessageField.hidden = NO;
									currentMessageField = mainMessageField;
								}
								return;
							}
						}
						else if (pt.x < 416) //help window
						{
							if (helpSubView.hidden)
							{
								helpSubView.hidden = NO;
								[self setupMessage:@"Welcome to Help Mode! Press the other icons to get information about the editor's functions. To return to Edit Mode, just press this icon again." :mainMessageField];
								editorState = EDITOR_STATE_HELP;
							}
							else
							{
								helpSubView.hidden = YES;
								mainMessageField.hidden = YES;
								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 448) //switch to second row
						{
							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_UP_ARROW] :mainMessageField];
							}
							else
							{
								editorButtonsRow++;
								[self setImageView:@"btn_EditorButtons2.png" :imageView :INT_MAX :0];	
								selectionPlacementX = -32;
							}
						}
					}
					else //second row buttons
					{
						if (pt.x < 32) //save 
						{
							[self playSound:SOUND_CLICK];

							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_SAVE] :mainMessageField];
							}
							else
							{
								NSArray *dirPaths;
								NSString *docsDir;
								NSString *filePath;

								dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

								docsDir = [dirPaths objectAtIndex:0];
								filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"level.dat"];
								NSDictionary *loadFile = [[NSDictionary alloc] initWithContentsOfFile:filePath];

								if (loadFile)
								{
									[gameState addObject:[NSNumber numberWithInteger:STATE_OK_CANCEL]];
									[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_OK_CANCEL]];
									mainMessageField.text = @"Overwrite your previously saved level?";
									okCancelState = OK_CANCEL_STATE_SAVE;
									[loadFile release];
								}
								else
								{
									[self saveEditorFile];
								}

								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 64) //new map
						{
							[self playSound:SOUND_CLICK];

							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_NEW] :mainMessageField];
							}
							else
							{
								[gameState addObject:[NSNumber numberWithInteger:STATE_OK_CANCEL]];
								[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_OK_CANCEL]];
								mainMessageField.text = @"Are you sure you want to clear the level and start fresh?";
								okCancelState = OK_CANCEL_STATE_NEW;
								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 96) //upload map
						{
							[self playSound:SOUND_CLICK];

							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_UPLOAD] :mainMessageField];
							}
							else
							{
								if (time(NULL) - uploadTime < UPLOAD_WAIT_TIME)
								{
									NSString *errorString = @"Please wait at least 5 minutes before uploading another level. Thanks! :)";

									[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
									helpSubView.hidden = NO;
									mainMessageField.text = errorString;
									mainMessageField.hidden = NO;
									currentMessageField = mainMessageField;
								}
								else
								{
									[self removeDuplicatePlayerAndGoal];
									int goalAndPlayerStatus = [self checkForGoalAndPlayerStart];
									if (goalAndPlayerStatus == EDITOR_HAS_PLAYER_AND_GOAL)
									{
										if ([self loadLogin])
										{
											[self uploadUserLevel];
										}
										else
										{
											[gameState addObject:[NSNumber numberWithInteger:STATE_LOGIN]];
											[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_LOGIN_ELEMENTS]];

											[self setImageView:@"UI_Login.png" :imageSubView :INT_MAX :INT_MAX];
											if (!(showEditorWarning & EDITOR_POPUP_UPLOAD))
											{
												[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
												helpSubView.hidden = NO;
												currentMessageField = mainMessageField;
												currentMessageField.hidden = NO;
												currentMessageField.text = @"To upload a level, you will need a GreenPixel account! If you already have one, just enter your username and password and press the Login Button. To create an account, press the Register Button. After you log in for the first time, your username and password are saved on your device.";
												showEditorWarning |= EDITOR_POPUP_UPLOAD;
												[self saveProgress];
											}
											return;
										}
									}
									else
									{
										NSString *errorString = @"Oops, we encountered a problem when trying to upload the level! You must assign a starting position for Bit and the Goal Block. You can find Bit and the Goal Block by pressing the Tile Selection icon on the first page!";

										[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
										helpSubView.hidden = NO;
										mainMessageField.text = errorString;
										mainMessageField.hidden = NO;
										currentMessageField = mainMessageField;
									}
								}

								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 128) //help
						{
							[self playSound:SOUND_CLICK];

							if (helpSubView.hidden)
							{
								helpSubView.hidden = NO;
								[self setupMessage:@"Welcome to Help Mode! Press the other icons to get information about the editor's functions. To return to Edit Mode, just press this icon again." :mainMessageField];
								editorState = EDITOR_STATE_HELP;
							}
							else
							{
								helpSubView.hidden = YES;
								mainMessageField.hidden = YES;
								selectionPlacementX = -32;
							}
						}
						else if (pt.x < 160) //switch back to first row
						{
							[self playSound:SOUND_CLICK];

							if (!helpSubView.hidden)
							{
								[self setupMessage:[helpText objectAtIndex:EDITOR_HELP_DOWN_ARROW] :mainMessageField];
							}
							else
							{
								editorButtonsRow--;
								[self setImageView:@"btn_EditorButtons.png" :imageView :INT_MAX :0];
								return;
							}
						}
						else if (pt.x < screenWidth - 32)
						{
							selectionPlacementX = -32;
						}
					}

					selection.origin.x = 0;
					selection.origin.y = 0;
					selection.size.width = 0;
					selection.size.height = 0;

					[self setImageView:@"editorSelection.png" :imageSubView :selectionPlacementX :0];
					return;
				}
			}

			switch (editorState)
			{
				case EDITOR_STATE_PEN:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if (tileY <= 2 || tileX == 0 || tileX == MAP_WIDTH - 1)
						{
							return;
						}

						memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
						memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

						if (selectedTile > -1)
						{
							map[tileY][tileX] = selectedTile;
						}
						else
						{
							special[tileY][tileX] = selectedSpecial;
						}
					}
					break;
				case EDITOR_STATE_ERASE:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if (tileY <= 2 || tileX == 0 || tileX == MAP_WIDTH - 1)
						{
							return;
						}

						memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
						memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

						map[tileY][tileX] = 0;
						special[tileY][tileX] = 0;
					}
					break;
				case EDITOR_STATE_MOVE:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						editorStartX = pt.x;
						editorStartY = pt.y;
					}
					break;
				case EDITOR_STATE_FILL:
				case EDITOR_STATE_SELECTION:
					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						if ((((int)pt.x - bgOffsetX) % TILE_SIZE) > TILE_SIZE >> 1)
						{
							tileX++;
						}
						if ((((int)pt.y + bgOffsetY) % TILE_SIZE) > TILE_SIZE >> 1)
						{
							tileY++;
						}

						editorStartX = selection.origin.x = tileX * TILE_SIZE;
						editorStartY = selection.origin.y = tileY * TILE_SIZE;
						selection.size.height = 0;
						selection.size.width = 0;
					}
					break;
				case EDITOR_STATE_PASTE:
				{	
					if (copyBounds.size.width == 0 || copyBounds.size.height == 0)
					{
						return;
					}

					for (i = 0; i < [points count]; i++)
					{
						CGPoint pt = [[points objectAtIndex:i] locationInView:self.view];
						tileX = ((pt.x - bgOffsetX) / TILE_SIZE) + drawTileStartX;
						tileY = ((pt.y + bgOffsetY) / TILE_SIZE) + drawTileStartY;

						int fillBeginX = (int)copyBounds.origin.x / TILE_SIZE;
						int copyWidth = (int)copyBounds.size.width / TILE_SIZE;
						int fillBeginY = (int)copyBounds.origin.y / TILE_SIZE;
						int copyHeight = (int)copyBounds.size.height / TILE_SIZE;

						memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
						memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

						for (j = 0; j < copyHeight; j++)
						{
							for (k = 0; k < copyWidth; k++)
							{
								if (j < MAP_HEIGHT && k < MAP_WIDTH)
								{
									if ((j + tileY <= 2) || (k + tileX == 0) || (k + tileX >= MAP_WIDTH - 1) || (j + tileY > MAP_HEIGHT - 1))
									{
										continue;
									}

									map[j + tileY][k + tileX] = copyBuffer[fillBeginY + j][fillBeginX + k];
									special[j + tileY][k + tileX] = copySpecialBuffer[fillBeginY + j][fillBeginX + k];
								}
							}
						}
					}
					break;
				}
			}
		}
	}
}

- (void)selectButtonGroup:(int)buttonGroup
{
	int i;
	GameButton *button;

	switch (buttonGroup)
	{
		case BUTTON_GROUP_NONE:
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];
				button.isActive = false;
			}
			break;
		case BUTTON_GROUP_PLAY:
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];
				button.isActive = true;

				if (button.type == BUTTON_TYPE_OK)
				{
					button.isActive = false;
				}
			}
			break;
		case BUTTON_GROUP_BLOCKS:
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];
				button.isActive = false;

				if (button.type == BUTTON_TYPE_OK ||
					button.type == BUTTON_TYPE_PREV_BLOCK ||
					button.type == BUTTON_TYPE_NEXT_BLOCK ||
					button.type == BUTTON_TYPE_DESTRUCT)
				{
					button.isActive = true;
				}
			}
			break;
		case BUTTON_GROUP_CONFIG:
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];
				button.isActive = true;

				if (button.type == BUTTON_TYPE_OK ||
					button.type == BUTTON_TYPE_NEXT_MAP ||
					button.type == BUTTON_TYPE_PREV_BLOCK ||
					button.type == BUTTON_TYPE_NEXT_BLOCK ||
					button.type == BUTTON_TYPE_DESTRUCT)
				{
					button.isActive = false;
				}
			}
			break;
		case BUTTON_GROUP_BLOCKS_INTRO:
			for (i = 0; i < [buttonsArray count]; i++)
			{
				button = [buttonsArray objectAtIndex:i];
				button.isActive = false;

				if (button.type == BUTTON_TYPE_BLOCK ||
					button.type == BUTTON_TYPE_DESTRUCT ||
					button.type == BUTTON_TYPE_PREV_BLOCK ||
					button.type == BUTTON_TYPE_NEXT_BLOCK ||
					button.type == BUTTON_TYPE_NEXT_MAP)
				{
					button.isActive = true;
				}
			}
			break;
	}
}

- (void)loadNextLevel
{
	int i, j;

	[gameState removeLastObject];

	NSString *mapPath;

	if (currentLevel < 10)
	{
		mapPath = [NSString stringWithFormat:@"map0%d", currentLevel];
	}
	else
	{
		mapPath = [NSString stringWithFormat:@"map%d", currentLevel];
	}

	NSString *filePath = [[NSBundle mainBundle] pathForResource:mapPath ofType:@"dat"];
	NSData *mapFile = [NSData dataWithContentsOfFile:filePath];
	Byte *mapData = (Byte *)[mapFile bytes];

	int newSongIndex = -1;

	if (currentLevel < 7)
	{
		newSongIndex = SONG_GRASS;
	}
	else if (currentLevel < 17)
	{
		newSongIndex = SONG_FACTORY;
	}
	else if (currentLevel < 23)
	{
		newSongIndex = SONG_SPACE;
	}
	else if (currentLevel < 28)
	{
		newSongIndex = SONG_UNDERGROUND;
	}
	else if (currentLevel < 35)
	{
		newSongIndex = SONG_CITY;
	}

	if (newSongIndex != currentSong)
	{
		[self playSong:newSongIndex repeats:YES];
	}

	//goldTime
	goldTime = OSReadBigInt32(mapData, 0);
	[self convertUserTime:goldTimeField :goldTime];
	mapData += sizeof(int);
	//silverTime
	silverTime = OSReadBigInt32(mapData, 0);
	[self convertUserTime:silverTimeField :silverTime];
	mapData += sizeof(int);
	//bronzeTime
	bronzeTime = OSReadBigInt32(mapData, 0);
	[self convertUserTime:bronzeTimeField :bronzeTime];
	mapData += sizeof(int);
	//backgroundType
	int levelType = OSReadBigInt32(mapData, 0);
	mapData += sizeof(int);

	if (previousBackground != levelType)
	{
		previousBackground = levelType;

		[bgImage release];
		[mapTiles release];

		switch (levelType)
		{
			case 0:
				bgImage = [[Image alloc] initWithString:@"BGFactoryLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELFactoryBlocks.png"];
				break;
			case 1:
				bgImage = [[Image alloc] initWithString:@"BGGrassLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELGrassBlocks.png"];
				break;
			case 2:
				bgImage = [[Image alloc] initWithString:@"BGCityLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELCityBlocks.png"];
				break;
			case 3:
				bgImage = [[Image alloc] initWithString:@"BGSpaceLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELSpaceBlocks.png"];
				break;
			case 4: 
				bgImage = [[Image alloc] initWithString:@"BGUndergroundLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELUndergroundBlocks.png"];
				break;
			case 5:
				bgImage = [[Image alloc] initWithString:@"BGErrorLevel.png"];
				mapTiles = [[Image alloc] initWithString:@"LEVELErrorBlocks.png"];
				break;
		}
	}

	blocksAvailableIndex = 0;
	BOOL foundBlock = false;

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		int amount = OSReadBigInt32(mapData, 0);

		if (!foundBlock && amount)
		{
			blocksAvailableIndex = i;
			foundBlock = true;
		}

		blocksAvailable[i] = amount;
		blocksBkup[i] = amount;

		//num of blocks in the queue
		mapData += sizeof(int);
	}

	//intro message
	short msgLength = OSReadBigInt16(mapData, 0);
	mapData += sizeof(short);

	[message release];
	message = [[NSString alloc] initWithBytes:mapData length:msgLength encoding:NSUTF8StringEncoding];
	textIndex = 0;
	currentMessageField = introMessageField;
	currentMessageField.hidden = YES;
	currentMessageField.text = @"";
	mapData += msgLength;

	//outro message
	msgLength = OSReadBigInt16(mapData, 0);
	mapData += sizeof(short);

//	outroMessage = [[NSString alloc] initWithBytes:mapData length:msgLength encoding:NSUTF8StringEncoding];
	mapData += msgLength;

	//old data no longer used
	mapData += sizeof(int); //tile size
	mapData += sizeof(int); //width
	mapData += sizeof(int); //height
	//end data no longer used

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			//add special blocks
			special[i][j] = OSReadBigInt32(mapData, 0);
			mapData += sizeof(int);

			//add walls
			map[i][j] = OSReadBigInt32(mapData, 0);
			mapData += sizeof(int);
		}
	}

	[self setupMap];
	counter = 0;

	blockNumField.hidden = NO;
	[self getBlockIndex:0];

	CGRect tempFrame = timerField.frame;
	tempFrame.origin.x = 341;
	tempFrame.origin.y = 16;
	timerField.frame = tempFrame;
	timerField.hidden = NO;
	hudView.hidden = NO;
	[self selectButtonGroup:BUTTON_GROUP_PLAY];

	if (showIntro)
	{
		alarm = COUNTDOWN_FRAMES;
		player.x = goalX * TILE_SIZE;
		player.y = goalY * TILE_SIZE - TILE_SIZE;
		playerDestX = playerStartX;
		playerDestY = playerStartY;
		currentBlock.drawBlock = false;
		blockNumField.hidden = YES;

		[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INTRO]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_COUNTDOWN]];

		timerField.hidden = YES;
		hudView.hidden = YES;
		[self selectButtonGroup:BUTTON_GROUP_NONE];
	}
	else if (!blocksAvailable[blocksAvailableIndex])
	{
		currentBlock.drawBlock = false;
		blockNumField.hidden = YES;
	}

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_UP];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_UP];
				break;
			case BUTTON_TYPE_PREV_BLOCK:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_LEFT_BUTTON_DOWN];
				}
				break;
			case BUTTON_TYPE_NEXT_BLOCK:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
				}
				break;
		}
	}

	[self setupLasers];

	showBlockIntro = false;

	if (gameType == GAME_TYPE_STOCK_LEVEL && currentLevel == 2)
	{
		showBlockIntro = true;
	}

	[self setImageView:@"levelIntro.png" :imageView :INT_MAX :INT_MAX];
	imageView.hidden = YES;

	[projectileArray removeAllObjects];
	[billboards removeAllObjects];

	player.isAlive = true;
	player.state = PLAYER_IDLE;
	player.boost = 0;
	player.jump = 0;
	canJump = JUMP_CLEAR;
	explosionsCounter = -1;
	checkpointX = -1;
	checkpointY = -1;

	[self drawGame];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
}

- (void)reloadLevel
{
	int i;

	[gameState removeLastObject];
	blocksAvailableIndex = 0;
	BOOL foundBlock = false;

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		int amount = blocksBkup[i];

		if (!foundBlock && amount)
		{
			blocksAvailableIndex = i;
			foundBlock = true;
		}

		blocksAvailable[i] = amount;
	}

	if (checkpointX == -1 && checkpointY == -1)
	{
		[self setupMap];
		counter = 0;
	}
	else
	{
		player.x = checkpointX;
		player.y = checkpointY;

		[blockQueue removeAllObjects];
		blockIndex = 0;

		for (i = 0; i < [checkpointBlocks count]; i++)
		{
			Block *src = [checkpointBlocks objectAtIndex:i];
			Block *dest = [[Block alloc] initBlock:src.type WithAssetManager:am];

			[self copyBlock:dest :src];
			[blockQueue addObject:dest];
			blockIndex++;

			[dest release];
		}

		for (i = 0; i < MAX_USER_BLOCKS; i++)
		{
			blocksAvailable[i] = checkpointBlocksAvailable[i];
		}

		counter = checkpointCounter;
		[self getBlockIndex:1];
	}

	blockNumField.hidden = NO;
	[self getBlockIndex:0];

	CGRect tempFrame = timerField.frame;
	tempFrame.origin.x = 341;
	tempFrame.origin.y = 16;
	timerField.frame = tempFrame;
	timerField.hidden = NO;
	hudView.hidden = NO;

	if (showBlockIntro)
	{
		[self selectButtonGroup:BUTTON_GROUP_BLOCKS_INTRO];
	}
	else
	{
		[self selectButtonGroup:BUTTON_GROUP_PLAY];
	}

	if (!blocksAvailable[blocksAvailableIndex])
	{
		currentBlock.drawBlock = false;
		blockNumField.hidden = YES;
	}

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_UP];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_UP];
				break;
			case BUTTON_TYPE_PREV_BLOCK:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_LEFT_BUTTON_DOWN];
				}
				break;
			case BUTTON_TYPE_NEXT_BLOCK:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
				}
				break;
		}
	}

	[self setupLasers];
	[self setupCrystals];
	[projectileArray removeAllObjects];
	[billboards removeAllObjects];

	player.isAlive = true;
	player.state = PLAYER_IDLE;
	player.boost = 0;
	player.jump = 0;
	canJump = JUMP_CLEAR;
	explosionsCounter = -1;

	[self drawGame];

	imageView.hidden = YES;
	imageSubView.hidden = YES;
	returnToEditorButton.hidden = YES;
	retryButton.hidden = YES;
	returnToLevelsButton.hidden = YES;
	nextButton.hidden = YES;
	mainMessageField.hidden = YES;
	retryField.hidden = YES;
}

- (void)loadEditorLevel
{
	int i;

	editorDrawStartX = drawTileStartX;
	editorDrawStartY = drawTileStartY;
	editorBGOffsetX = bgOffsetX;
	editorBGOffsetY = bgOffsetY;
	gridView.hidden = YES;

	self.view.multipleTouchEnabled = true;
	blocksAvailableIndex = 0;
	BOOL foundBlock = false;

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		int amount = blockAmounts[i].amount;

		if (!foundBlock && amount)
		{
			blocksAvailableIndex = i;
			foundBlock = true;
		}

		blocksAvailable[i] = amount;
		blocksBkup[i] = amount;
	}

	[self setupMap];
	counter = 0;

	[self getBlockIndex:0];
	currentBlock.drawBlock = true;
	blockNumField.hidden = NO;

	if (!blocksAvailable[blocksAvailableIndex])
	{
		currentBlock.drawBlock = false;
		blockNumField.hidden = YES;
	}

	CGRect tempFrame = timerField.frame;
	tempFrame.origin.x = 341;
	tempFrame.origin.y = 16;
	timerField.frame = tempFrame;
	timerField.hidden = NO;

	[self convertUserTime:goldTimeField :goldTime];
	[self convertUserTime:silverTimeField :silverTime];
	[self convertUserTime:bronzeTimeField :bronzeTime];

	imageView.hidden = YES;
	imageSubView.hidden = YES;
	hudView.hidden = NO;
	[self selectButtonGroup:BUTTON_GROUP_PLAY];

	[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_UP];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_UP];
				break;
			case BUTTON_TYPE_PREV_BLOCK:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_LEFT_BUTTON_DOWN];
				}
				break;
			case BUTTON_TYPE_NEXT_BLOCK:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
				}
				break;
		}
	}

	[self setupLasers];

	showBlockIntro = false;
	showIntro = false;

	[projectileArray removeAllObjects];
	[billboards removeAllObjects];

	player.isAlive = true;
	player.state = PLAYER_IDLE;
	player.boost = 0;
	player.jump = 0;
	canJump = JUMP_CLEAR;
	explosionsCounter = -1;
	checkpointX = -1;
	checkpointY = -1;
}

- (void)loadUserLevel:(NSString *)levelData
{
	int i;
	int j;
	NSArray *mapData = [levelData componentsSeparatedByString:@"|"];
	int mapIndex = 0;

	goldTime = [[mapData objectAtIndex:mapIndex] intValue];
	[self convertUserTime:goldTimeField :goldTime];
	mapIndex++;
	silverTime = [[mapData objectAtIndex:mapIndex] intValue];
	[self convertUserTime:silverTimeField :silverTime];
	mapIndex++;
	bronzeTime = [[mapData objectAtIndex:mapIndex] intValue];
	[self convertUserTime:bronzeTimeField :bronzeTime];
	mapIndex++;
	int levelType = [[mapData objectAtIndex:mapIndex] intValue];
	mapIndex++;

	blocksAvailableIndex = 0;
	BOOL foundBlock = false;

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		int amount = [[mapData objectAtIndex:mapIndex] intValue];
		mapIndex++;

		if (!foundBlock && amount)
		{
			blocksAvailableIndex = i;
			foundBlock = true;
		}

		blocksAvailable[i] = amount;
		blocksBkup[i] = amount;
	}

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			map[i][j] = [[mapData objectAtIndex:mapIndex] intValue];
			mapIndex++;
		}
	}

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			special[i][j] = [[mapData objectAtIndex:mapIndex] intValue];
			mapIndex++;
		}
	}

	[mapTiles release];
	mapTiles = [[Image alloc] initWithString:@"userblocks.png"];

	if (previousBackground != levelType)
	{
		previousBackground = levelType;

		[bgImage release];

		switch (levelType)
		{
			case 0:
				bgImage = [[Image alloc] initWithString:@"BGFactoryLevel.png"];
				break;
			case 1:
				bgImage = [[Image alloc] initWithString:@"BGGrassLevel.png"];
				break;
			case 2:
				bgImage = [[Image alloc] initWithString:@"BGCityLevel.png"];
				break;
			case 3:
				bgImage = [[Image alloc] initWithString:@"BGSpaceLevel.png"];
				break;
			case 4: 
				bgImage = [[Image alloc] initWithString:@"BGUndergroundLevel.png"];
				break;
			case 5:
				bgImage = [[Image alloc] initWithString:@"BGErrorLevel.png"];
				break;
		}
	}

	[self playSong:levelType + 1 repeats:YES];

	[self setupMap];
	counter = 0;

	blockNumField.hidden = NO;
	[self getBlockIndex:0];

	CGRect tempFrame = timerField.frame;
	tempFrame.origin.x = 341;
	tempFrame.origin.y = 16;
	timerField.frame = tempFrame;
	timerField.hidden = NO;
	hudView.hidden = NO;
	[self selectButtonGroup:BUTTON_GROUP_PLAY];

	alarm = COUNTDOWN_FRAMES;
	player.x = goalX * TILE_SIZE;
	player.y = goalY * TILE_SIZE - TILE_SIZE;
	playerDestX = playerStartX;
	playerDestY = playerStartY;
	currentBlock.drawBlock = false;
	blockNumField.hidden = YES;

	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INTRO]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_COUNTDOWN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];

	currentMessageField = introMessageField;
	currentMessageField.hidden = YES;
	currentMessageField.text = @"";

	timerField.hidden = YES;
	hudView.hidden = YES;
	[self selectButtonGroup:BUTTON_GROUP_NONE];

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_UP];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_UP];
				break;
			case BUTTON_TYPE_PREV_BLOCK:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_LEFT_BUTTON_DOWN];
				}
				break;
			case BUTTON_TYPE_NEXT_BLOCK:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				if (blocksAvailable[blocksAvailableIndex])
				{
					[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
				}
				break;
		}
	}

	[self setupLasers];

	[self setImageView:@"levelIntro.png" :imageView :INT_MAX :INT_MAX];
	imageView.hidden = YES;

	[projectileArray removeAllObjects];
	[billboards removeAllObjects];

	player.isAlive = true;
	player.state = PLAYER_IDLE;
	player.boost = 0;
	player.jump = 0;
	canJump = JUMP_CLEAR;
	explosionsCounter = -1;
	checkpointX = -1;
	checkpointY = -1;

	[self drawGame];
}

- (int)getGameState
{
	if (![gameState count])
	{
		return -1;
	}

	return [[gameState lastObject] intValue];
}

- (void)updatePlayer
{
	int i, j;
	Block *block;

	if (!player.isAlive)
	{
		return;
	}

	player.state &= ~PLAYER_FALL;

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		if (block.type != BLOCK_TYPE_CHECKPOINT && (!block.isVisible || !block.isAlive || !block.drawBlock))
		{
			continue;
		}

		if (block.type == BLOCK_TYPE_BLADE)
		{
			[vec initVector2D:player.x + (player.width >> 1) - (block.x + (TILE_SIZE >> 1)) :player.y + (player.height >> 1) - (block.y + (TILE_SIZE >> 1))];

			if ([vec squaredDistance] <= 6400)
			{
				float playerAngle = atan2((player.y + (player.height >> 1)) - (block.y + (TILE_SIZE >> 1)), (player.x + (player.width >> 1)) - (block.x + (TILE_SIZE >> 1)));
				playerAngle = (playerAngle < 0) ? playerAngle + 2 * M_PI : playerAngle;

				if (fabs(playerAngle - (2 * M_PI - [block getAngle])) < 0.3f)
				{
					[self killPlayer:DEATH_BLADE];
				}
			}
		}

		for (j = 0; j < [block.damageZones count]; j++)
		{
			CGRect rect = [[block.damageZones objectAtIndex:j] CGRectValue];

			if ([Utils pointInBox:player.x + (player.width >> 1) :player.y + (player.height >> 1) :block.x + rect.origin.x :rect.size.width :block.y + rect.origin.y :rect.size.height])
			{
				switch (block.type)
				{
					case BLOCK_TYPE_LASER:
						[self killPlayer:DEATH_LASER];
						break;
					case BLOCK_TYPE_MOVINGSPIKES:
					case BLOCK_TYPE_SPIKES_UP:
					case BLOCK_TYPE_SPIKES_DOWN:
					case BLOCK_TYPE_SPIKES_LEFT:
					case BLOCK_TYPE_SPIKES_RIGHT:
						[self killPlayer:DEATH_SPIKES];
						break;
					case BLOCK_TYPE_LAVA:
						[self killPlayer:DEATH_LAVA];
						break;
				}

				return;
			}
		}

		if (block.type == BLOCK_TYPE_CHECKPOINT)
		{
			if ([Utils AABBCollision:vec :player.x :player.width >> 1 :player.y :player.height >> 1 :block.x :TILE_SIZE >> 1 :block.y :TILE_SIZE >> 1])
			{
				if (checkpointX != block.x || checkpointY != block.y)
				{
					[self playSound:SOUND_CHECKPOINT];
					[checkpointBlocks removeAllObjects];
					checkpointX = block.x;
					checkpointY = block.y;

					if (gameType == GAME_TYPE_STOCK_LEVEL)
					{
						[self showIntroBlock :BLOCK_TYPE_CHECKPOINT];
					}

					for (j = 0; j < blockIndex; j++)
					{
						Block *src = [blockQueue objectAtIndex:j];
						Block *dest = [[Block alloc] initBlock:src.type WithAssetManager:am];
						[self copyBlock:dest :src];
						[checkpointBlocks addObject:dest];
						[dest release];
					}

					for (j = 0; j < MAX_USER_BLOCKS; j++)
					{
						checkpointBlocksAvailable[j] = blocksAvailable[j];
					}

					checkpointCounter = counter;
					[block nextState];
				}
			}
		}
	}

	if (!(player.state & PLAYER_JUMP) && [self playerMoveDown:GRAVITY])
	{
		player.state |= PLAYER_FALL;
	}
	else if (setBoost != 0)
	{
		player.boost = setBoost;
		setBoost = 0;
	}

	if ((player.jump > 0) || (!(player.state & PLAYER_FALL) && player.state & (PLAYER_JUMP | PLAYER_SPRING)))
	{
		int maxJump = (player.state & PLAYER_JUMP) ? MAX_JUMP : MAX_SPRING;
		int jumpDist = (player.state & PLAYER_JUMP) ? JUMP_FORCE : SPRING_FORCE;
		player.jump = (player.state & PLAYER_JUMP) ? player.jump + JUMP_INC : player.jump + SPRING_INC;
		player.slide = 0;

		if (![self playerMoveUp:jumpDist] || player.jump >= maxJump)
		{
			player.state |= PLAYER_FALL;
			player.state &= ~(PLAYER_JUMP | PLAYER_SPRING);
			player.jump = 0;
		}
	}

	BOOL noBoost = true;

	if (player.state & PLAYER_LEFT)
	{
		player.flip = true;
		noBoost = false;
		if (player.boost > 0)
		{
			player.boost = 0;
		}
		[self playerMoveLeft:player.speed];
	}
	else if (player.state & PLAYER_RIGHT)
	{
		player.flip = false;
		noBoost = false;
		if (player.boost < 0)
		{
			player.boost = 0;
		}
		[self playerMoveRight:player.speed];
	}
	else if (player.state == PLAYER_IDLE)
	{
		if (player.slide > 0)
		{
			if (![self playerMoveRight:abs(player.slide)])
			{
				player.slide = 0;
			}
		}	
		else if (player.slide < 0)
		{
			if (![self playerMoveLeft:abs(player.slide)])
			{
				player.slide = 0;
			}
		}
	}
	if (noBoost)
	{
		player.boost = 0;
	}
	if (player.boost < 0)
	{
		if (![self playerMoveLeft:abs(player.boost)])
		{
			player.boost = 0;
		}
	}
	else if (player.boost > 0)
	{
		if (![self playerMoveRight:abs(player.boost)])
		{
			player.boost = 0;
		}
	}

	if (player.state & (PLAYER_JUMP | PLAYER_SPRING))
	{
		if (player.flip)
		{
			[player setAnim:ANIM_PLAYER_JUMP_LEFT];
		}
		else
		{
			[player setAnim:ANIM_PLAYER_JUMP_RIGHT];
		}
	}
	else if (player.state & PLAYER_FALL)
	{
		if (player.flip)
		{
			[player setAnim:ANIM_PLAYER_FALL_LEFT];
		}
		else
		{
			[player setAnim:ANIM_PLAYER_FALL_RIGHT];
		}
	}	
	else if (player.state & (PLAYER_LEFT | PLAYER_RIGHT))
	{
		if (player.flip)
		{
			[player setAnim:ANIM_PLAYER_RUN_LEFT];
		}
		else
		{
			[player setAnim:ANIM_PLAYER_RUN_RIGHT];
		}
	}
	else
	{
		if (player.flip)
		{
			[player setAnim:ANIM_PLAYER_IDLE_LEFT];
		}
		else
		{
			[player setAnim:ANIM_PLAYER_IDLE_RIGHT];
		}
	}
}

- (void)killPlayer:(int)type
{
	int i;

	if (!player.isAlive)
	{
		return;
	}

	player.state = PLAYER_IDLE;
	player.boost = 0;
	player.isAlive = false;

	//add the player death animation so we know to pop up the death screen when it finishes

	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_RELOAD_MAP]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_GAMEOVER]];

	[self setImageView:@"gameOverAndBlocksBG.png" :imageView :INT_MAX :INT_MAX];
	[self setImageView:[gameOverPaths objectAtIndex:type] :imageSubView :INT_MAX :40];
	imageView.hidden = YES;
	imageSubView.hidden = YES;

	int choice = (float)rand() / RAND_MAX * MAX_TEXT_PER_DEATH;

	if (choice >= MAX_TEXT_PER_DEATH)
	{
		choice--;
	}

	playerHasDeaths |= (1 << type);

	if (playerHasDeaths == (1 << MAX_DEATHS) - 1)
	{
	//	[[OFAchievement achievement:@"1482212"] updateProgressionComplete:100.0f andShowNotification:YES];
	}

	mainMessageField.text = [deathText objectAtIndex:((MAX_TEXT_PER_DEATH * type) + choice)];

	if (checkpointX == -1 && checkpointY == -1)
	{
		retryField.text = @"Tap to retry!";
	}
	else
	{
		retryField.text = @"Tap to retry from the checkpoint!";
	}

	//add explosion billboards except when falling
	if (type == DEATH_FALLING)
	{
		Billboard *b = [self getAvailableBillboard];
		[b setupBillboard :-100 :-100 :BILLBOARD_TYPE_PLAYER_DEATH :ANIM_EXPLOSION :0 :0 :0];
	}
	else
	{
		float angle = 0.0;

		Billboard *b = [self getAvailableBillboard];
		[b setupBillboard :player.x :player.y :BILLBOARD_TYPE_PLAYER_DEATH :ANIM_EXPLOSION :0 :0 :0];

		for (i = 0; i < 8; i++)
		{
			float random = 0.5 - (float)rand() / RAND_MAX;

			Billboard *body = [self getAvailableBillboard];
			[body setupBillboard :player.x + player.width / 2 :player.y + player.height / 2 :BILLBOARD_TYPE_BODY_PART :ANIM_EFFECT_BODY_PART_1 + i :8 + random :16 :random + angle];

			angle -= M_PI / 4;
		}

		explosionsCounter = 0;
//		[self playSound:SOUND_STATIC];
		[self playSound:SOUND_EXPLODE];
	}
}

- (void)updateBlocks
{
	int i, j, k;
	int tileX, tileY;
	Block *collideBlock;

	[vec initVector2D:0 :0];

	for (i = 0; i < blockIndex; i++)
	{
		Block *block = [blockQueue objectAtIndex:i];

		if (!block.isAlive)
		{
			continue;
		}

		if (block.type != BLOCK_TYPE_BUBBLE)
		{
			for (j = 0; j < blockIndex; j++)
			{
				if (i == j)
				{
					continue;
				}

				collideBlock = [blockQueue objectAtIndex:j];

				if ((collideBlock.type != BLOCK_TYPE_UPDOWN &&
					collideBlock.type != BLOCK_TYPE_LEFTRIGHT) ||
					block.isVisible != collideBlock.isVisible)
				{
					continue;
				}

				if (collideBlock.isAlive && [Utils boxInBox:collideBlock.x :TILE_SIZE :collideBlock.y :TILE_SIZE :block.x :TILE_SIZE :block.y :TILE_SIZE])
				{
					collideBlock.isAlive = false;

					if (collideBlock.drawBlock)
					{
						Billboard *b = [self getAvailableBillboard];
						[b setupBillboard :collideBlock.x :collideBlock.y :BILLBOARD_TYPE_EXPLOSION :ANIM_EXPLOSION :0 :0 :0];
						[self playSound:SOUND_TNT];
					}
				}
			}
		}

		switch (block.type)
		{
			case BLOCK_TYPE_BUBBLE:
				if ([block getAnim] == ANIM_BUBBLE_POP)
				{
					break;
				}

				tileX = (block.x + block.heading.x) / TILE_SIZE;
				tileY = (block.y + block.heading.y) / TILE_SIZE;

				if (block.counter)
				{
					block.counter--;

					if (!block.counter)
					{
						block.heading.y = 1;
					}
				}

				if ((block.x + block.heading.y < 0) || (tileY + 1) >= MAP_HEIGHT || (block.heading.y < 0 && [Tile hasFlag:map[tileY][tileX] :WALL]) ||
					(block.heading.y > 0 && [Tile hasFlag:map[tileY + 1][tileX] :WALL]) || (block.heading.y > 0 && [Utils boxInBox:block.x :TILE_SIZE :block.y + 1 :TILE_SIZE :player.x :player.width :player.y :player.height]))
				{
					block.heading.y = 0;
					[block nextState];
				}
				else
				{
					for (j = 0; j < blockIndex; j++)
					{
						collideBlock = [blockQueue objectAtIndex:j];

						if (i == j || !collideBlock.isVisible || !collideBlock.isAlive)
						{
							continue;
						}

						if ([Utils AABBCollision:vec :block.x + block.heading.x :TILE_SIZE >> 1 :block.y + block.heading.y :TILE_SIZE >> 1 :collideBlock.x :TILE_SIZE >> 1 :collideBlock.y :TILE_SIZE >> 1])
						{
							if (collideBlock.type == BLOCK_TYPE_BUBBLE)
							{
								collideBlock.heading.y = 1;
							}
							else
							{
								[block nextState];
								break;
							}
						}

						if (collideBlock.type == BLOCK_TYPE_BLADE)
						{
							int dX = block.x + (TILE_SIZE >> 1) - (collideBlock.x + (TILE_SIZE >> 1));
							int dY = block.y + (TILE_SIZE >> 1) - (collideBlock.y + (TILE_SIZE >> 1));

							if (dX * dX + dY * dY <= 6400) //lenght of the blade squared
							{
								float bubbleAngle = atan2((block.y + (TILE_SIZE >> 1)) - (collideBlock.y + (TILE_SIZE >> 1)), (block.x + (TILE_SIZE >> 1)) - (collideBlock.x + (TILE_SIZE >> 1)));
								bubbleAngle = (bubbleAngle < 0) ? bubbleAngle + 2 * M_PI : bubbleAngle;

								if (fabs(bubbleAngle - (2 * M_PI - [collideBlock getAngle])) < 0.1f)
								{
									[block nextState];
								}
							}
						}

						for (k = 0; k < [collideBlock.damageZones count]; k++)
						{
							CGRect rect = [[collideBlock.damageZones objectAtIndex:k] CGRectValue];

							if ([Utils pointInBox:block.x + (TILE_SIZE >> 1) :block.y + (TILE_SIZE >> 1) :collideBlock.x + rect.origin.x :rect.size.width :collideBlock.y + rect.origin.y :rect.size.height])
							{
								[block nextState];
								break;
							}
						}
					}
				}

				block.y += block.heading.y;
				break;
			case BLOCK_TYPE_FIRE:
				break;
			case BLOCK_TYPE_CRYSTAL:
				block.health -= block.numLasers;

				if (block.health <= 0)
				{
					block.isAlive = false;
					[self resetLasers:block];
					if (block.drawBlock)
					{
						[self playSound:SOUND_CRYSTAL];
					}
				}
				else if (block.health <= (BLOCK_HEALTH / 2))
				{
					[block setBlockAnim:ANIM_CRYSTAL_BREAK];
				}
				break;
			case BLOCK_TYPE_UPDOWN:
			{
				BOOL canMove = true;
				tileX = (block.x + block.heading.x) / TILE_SIZE;
				tileY = (block.y + block.heading.y) / TILE_SIZE;

				if (block.heading.y < 0 && [Tile hasFlag:map[tileY][tileX] :WALL])
				{	
					block.heading.y *= -1;
					canMove = false;
				}
				else if (block.heading.y > 0 && ((tileY + 1 >= MAP_HEIGHT) || [Tile hasFlag:map[tileY + 1][tileX] :WALL]))
				{
					block.heading.y *= -1;
					canMove = false;
				}
				else
				{
					for (j = 0; j < blockIndex; j++)
					{
						collideBlock = [blockQueue objectAtIndex:j];

						if (i == j || !collideBlock.isVisible || !collideBlock.isAlive)
						{
							continue;
						}

						if ([Utils AABBCollision:vec :block.x :TILE_SIZE >> 1 :block.y + block.heading.y + 1 :TILE_SIZE >> 1 :collideBlock.x :TILE_SIZE >> 1 :collideBlock.y :TILE_SIZE >> 1])
						{
							switch (collideBlock.type)
							{
								case BLOCK_TYPE_REDSWITCH:
								case BLOCK_TYPE_BLUESWITCH:
								case BLOCK_TYPE_GREENSWITCH:
									if (block.heading.y > 0)
									{
										if ([collideBlock getAnim] != ANIM_REDSWITCH_ON && [collideBlock getAnim] != ANIM_GREENSWITCH_ON)
										{
											[collideBlock nextState];

											for (k = 0; k < blockIndex; k++)
											{
												if (k == j || k == i)
												{
													continue;
												}

												Block *tempBlock = [blockQueue objectAtIndex:k];
												if (tempBlock.type == (collideBlock.type + 1) || tempBlock.type == collideBlock.type)
												{
													if ([Utils boxInBox:player.x :player.width :player.y :player.height :tempBlock.x :TILE_SIZE :tempBlock.y :TILE_SIZE])
													{
														[self killPlayer:DEATH_SQUISH];
													}

													[tempBlock nextState];
													[self resetLasers:tempBlock];
												}
											}
										}
									}
									break;
							}

							if (collideBlock.type == BLOCK_TYPE_BUBBLE)
							{
								if ([collideBlock getAnim] != ANIM_BUBBLE_POP)
								{
									[collideBlock nextState];
								}
							}
							else
							{
								canMove = false;
								block.heading.y *= -1;
							}
							break;
						}
					}
				}
				if (canMove)
				{
					block.y += block.heading.y;
				}

				if (block.heading.y < 0)
				{		
					[block setBlockAnim:ANIM_UP_PLATFORM];
				}	
				else
				{
					[block setBlockAnim:ANIM_DOWN_PLATFORM];
				}

				if ([Utils AABBCollision:vec :player.x :player.width >> 1 :player.y :player.height >> 1 :block.x :TILE_SIZE >> 1 :block.y :TILE_SIZE >> 1])
				{
					if (vec.y * block.heading.y > 0)
					{
						if (block.heading.y > 0)
						{
							if (![self playerMoveDown:block.heading.y])
							{
								[self killPlayer:DEATH_SQUISH];
							}
						}
						else
						{
							if (![self playerMoveUp:abs(block.heading.y)])
							{
								[self killPlayer:DEATH_SQUISH];
							}
						}
					}
				}
				break;
			}
			case BLOCK_TYPE_LEFTRIGHT:
			{
				BOOL canMove = true;
				tileX = (block.x + block.heading.x) / TILE_SIZE;
				tileY = (block.y + block.heading.y) / TILE_SIZE;

				if (block.heading.x > 0 && [Tile hasFlag:map[tileY][tileX + 1] :WALL])
				{
					block.heading.x *= -1;
					canMove = false;
				}
				else if (block.heading.x < 0 && [Tile hasFlag:map[tileY][tileX] :WALL])
				{
					block.heading.x *= -1;
					canMove = false;
				}
				else
				{
					for (j = 0; j < blockIndex; j++)
					{
						collideBlock = [blockQueue objectAtIndex:j];

						if (i == j || !collideBlock.isVisible || !collideBlock.isAlive)
						{
							continue;
						}

						if ([Utils AABBCollision:vec :block.x + block.heading.x :TILE_SIZE >> 1 :block.y :TILE_SIZE >> 1 :collideBlock.x :TILE_SIZE >> 1 :collideBlock.y :TILE_SIZE >> 1])
						{
							if (collideBlock.type == BLOCK_TYPE_BUBBLE)
							{
								if ([collideBlock getAnim] != ANIM_BUBBLE_POP)
								{
									[collideBlock nextState];
								}
							}
							else
							{
								canMove = false;
								block.heading.x *= -1;
							}
							break;
						}
					}
				}
				if (canMove)
				{
					block.x += block.heading.x;
				}

				if (block.heading.x < 0)
				{
					[block setBlockAnim:ANIM_LEFT_PLATFORM];
				}
				else
				{
					[block setBlockAnim:ANIM_RIGHT_PLATFORM];
				}

				if ([Utils AABBCollision:vec :player.x :player.width >> 1 :player.y :player.height >> 1 :block.x :TILE_SIZE >> 1 :block.y :TILE_SIZE >> 1])
				{
					if (vec.x * block.heading.x > 0)
					{
						if (block.heading.x > 0)
						{
							if (![self playerMoveRight:block.heading.x])
							{
								[self killPlayer:DEATH_SQUISH];
							}
						}
						else
						{
							if (![self playerMoveLeft:abs(block.heading.x)])
							{
								[self killPlayer:DEATH_SQUISH];
							}
						}
					}
				}
				break;
			}
			case BLOCK_TYPE_MOVINGSPIKES:
				[block.damageZones removeAllObjects];

				switch ([block getAnim])
				{
					case ANIM_SPIKES_EXTEND_UP:
					case ANIM_SPIKES_UP:
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, -24, 32, 32)]];
						break;
					case ANIM_SPIKES_EXTEND_RIGHT:
					case ANIM_SPIKES_RIGHT:
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(24, 0, 32, 32)]];
						break;
					case ANIM_SPIKES_EXTEND_LEFT:
					case ANIM_SPIKES_LEFT:
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(-24, 0, 32, 32)]];

						break;
					case ANIM_SPIKES_EXTEND_DOWN:
					case ANIM_SPIKES_DOWN:
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, 24, 32, 32)]];
						break;
					case ANIM_SPIKES_EXTEND_ALL:
					case ANIM_SPIKES_ALL:
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, -24, 32, 32)]];
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(24, 0, 32, 32)]];
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(-24, 0, 32, 32)]];
						[block.damageZones addObject:[NSValue valueWithCGRect:CGRectMake(0, 24, 32, 32)]];
						break;
				}
				break;
		}

		if (block.animFinished)
		{
			if (!block.isVisible && block.type != BLOCK_TYPE_CHECKPOINT)
			{
				if ([Utils boxInBox:player.x :player.width :player.y :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
				{
					[self killPlayer:DEATH_SQUISH];
				}
			}

			if (block.type == BLOCK_TYPE_MOVINGSPIKES)
			{
				switch ([block getAnim])
				{
					case ANIM_SPIKES_EXTEND_UP:
					case ANIM_SPIKES_EXTEND_LEFT:
					case ANIM_SPIKES_EXTEND_DOWN:
					case ANIM_SPIKES_EXTEND_RIGHT:
					case ANIM_SPIKES_EXTEND_ALL:
						if (block.drawBlock)
						{
							[self playSound:SOUND_SPIKES];
						}
						break;
				}
			}
			if (block.type == BLOCK_TYPE_FIRE)
			{
				if ([block getAnim] == ANIM_FIRE)
				{
					for (j = 0; j < blockIndex; j++)
					{
						Block *tempBlock = [blockQueue objectAtIndex:j];

						if (tempBlock.type == BLOCK_TYPE_ICE && 
							[tempBlock getAnim] != ANIM_ICE_MELT &&
							abs(tempBlock.x - block.x) <= (TILE_SIZE << 1) &&
							abs(tempBlock.y - block.y) <= (TILE_SIZE << 1))
						{
							[tempBlock nextState];
						}
					}

					if (block.drawBlock)
					{
						[self playSound:SOUND_FIRE];
					}
				}
			}

			[block nextState];

			switch (block.type)
			{
				case BLOCK_TYPE_GREENBLOCK:
				case BLOCK_TYPE_REDBLOCK:
					switch ([block getAnim])
					{
						case ANIM_GREENBLOCK_INVISIBLE:
						case ANIM_REDBLOCK_VISIBLE:
							[self resetLasers:block];
							break;
					}
					break;
				case BLOCK_TYPE_GUN:
				{
					Projectile *p;

					switch ([block getAnim])
					{
						case ANIM_GUN_SHOOT_UP:	
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + (TILE_SIZE >> 1) - 3 :block.y :ANIM_BULLET_UP];
							[p setHeadingFromAngle:M_PI + (M_PI / 2)];
							if (block.drawBlock)
							{
								[self playSound:SOUND_GUN];
							}
							break;
						case ANIM_GUN_SHOOT_DOWN:
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + (TILE_SIZE >> 1) - 3 :block.y + TILE_SIZE - 3 :ANIM_BULLET_DOWN];
							[p setHeadingFromAngle:M_PI / 2];
							if (block.drawBlock)
							{
								[self playSound:SOUND_GUN];
							}
							break;
						case ANIM_GUN_SHOOT_LEFT:
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x :block.y + (TILE_SIZE >> 1) - 3 :ANIM_BULLET_LEFT];
							[p setHeadingFromAngle:M_PI];
							if (block.drawBlock)
							{
								[self playSound:SOUND_GUN];
							}
							break;
						case ANIM_GUN_SHOOT_RIGHT:
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + TILE_SIZE - 3 :block.y + (TILE_SIZE >> 1) - 3 :ANIM_BULLET_RIGHT];
							[p setHeadingFromAngle:0];
							if (block.drawBlock)
							{
								[self playSound:SOUND_GUN];
							}
							break;
						case ANIM_GUN_SHOOT_ALL:
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + (TILE_SIZE >> 1) - 3 :block.y :ANIM_BULLET_UP];
							[p setHeadingFromAngle:M_PI + (M_PI / 2)];
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + (TILE_SIZE >> 1) - 3 :block.y + TILE_SIZE - 3 :ANIM_BULLET_DOWN];
							[p setHeadingFromAngle:M_PI / 2];
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x :block.y + (TILE_SIZE >> 1) - 3 :ANIM_BULLET_LEFT];
							[p setHeadingFromAngle:M_PI];
							p = [self getAvailableProjectile];
							[p setupProjectile:block.x + TILE_SIZE - 3 :block.y + (TILE_SIZE >> 1) - 3 :ANIM_BULLET_RIGHT];
							[p setHeadingFromAngle:0];
							if (block.drawBlock)
							{
								[self playSound:SOUND_GUN];
							}
							break;
					}
					break;
				}
				case BLOCK_TYPE_BOMB:
					block.isAlive = false;

					[self playSound:SOUND_TNT];

					//make the explosions
					Billboard *b = [self getAvailableBillboard];
					[b setupBillboard :block.x :block.y :BILLBOARD_TYPE_EXPLOSION :ANIM_EXPLOSION :0 :0 :0];

					for (j = 0; j < 6; j++)
					{
						b = [self getAvailableBillboard];
						[b setupBillboard :block.x + TILE_SIZE * cos(2 * M_PI * (j / 6.0f)) :block.y + TILE_SIZE * sin(2 * M_PI * (j / 6.0f)) :BILLBOARD_TYPE_EXPLOSION :ANIM_EXPLOSION :0 :0 :0];
					}

					[vec initVector2D:(player.x - block.x) :(player.y - block.y)];
					if ([vec squaredDistance] <= (4 * TILE_SIZE * TILE_SIZE))
					{
						[self killPlayer:DEATH_EXPLOSION];
					}

					for (j = 0; j < blockIndex; j++)
					{
						Block *tempBlock = [blockQueue objectAtIndex:j];

						if (j == i || !tempBlock.isAlive)
						{
							continue;
						}

						[vec initVector2D:(tempBlock.x - block.x) :(tempBlock.y - block.y)];

						if ([vec squaredDistance] <= (4 * TILE_SIZE * TILE_SIZE))
						{
							if (tempBlock.type == BLOCK_TYPE_BUBBLE)
							{
								[tempBlock nextState];
							}
							else
							{
								tempBlock.isAlive = false;
								b = [self getAvailableBillboard];
								[b setupBillboard :tempBlock.x :tempBlock.y :BILLBOARD_TYPE_EXPLOSION :ANIM_EXPLOSION :0 :0 :0];
							}
						}
					}
					break;
				case BLOCK_TYPE_BUBBLE:
					if (block.drawBlock)
					{
						[self playSound:SOUND_BUBBLE_POP];
					}
					block.isAlive = false;
					break;
				case BLOCK_TYPE_ICE:
					block.isAlive = false;
					break;
			}
		}
	}
}

- (void)getBlockIndex:(int)search
{
	int startIndex = blocksAvailableIndex;

	if (search < 0)
	{
		blocksAvailableIndex = (blocksAvailableIndex - 1 > -1) ? blocksAvailableIndex - 1 : MAX_USER_BLOCKS - 1;

		while (blocksAvailableIndex != startIndex && blocksAvailable[blocksAvailableIndex] == 0)
		{
			blocksAvailableIndex = (blocksAvailableIndex - 1 > -1) ? blocksAvailableIndex - 1 : MAX_USER_BLOCKS - 1;
		}
	}
	else if (search > 0)
	{
		blocksAvailableIndex = (blocksAvailableIndex + 1 < MAX_USER_BLOCKS) ? blocksAvailableIndex + 1 : 0;

		while (blocksAvailableIndex != startIndex && blocksAvailable[blocksAvailableIndex] == 0)
		{
			blocksAvailableIndex = (blocksAvailableIndex + 1 < MAX_USER_BLOCKS) ? blocksAvailableIndex + 1 : 0;
		}
	}

	[currentBlock release];
	currentBlock = [[Block alloc] initBlock:blocksAvailableIndex WithAssetManager:am];
	currentBlock.x = (screenWidth - TILE_SIZE) / 2;
	currentBlock.y = TILE_SIZE;

	if (blocksAvailableIndex == BLOCK_TYPE_BOMB)
	{
		[currentBlock nextState];
	}

	blockNumField.text = [NSString stringWithFormat:@"%d", blocksAvailable[blocksAvailableIndex]];
}

- (void)updatePortal
{
	[vec initVector2D:(playerDestX - player.x) :(playerDestY - player.y)];
	float distance = [vec squaredDistance];
	int i;

	[vec normalize];
	vec.x *= PORTAL_SPEED;
	vec.y *= PORTAL_SPEED;

	if (distance <= [vec squaredDistance])
	{
		[[blockQueue objectAtIndex:destPortalIndex] nextState];
		[gameState removeLastObject];
		player.x = playerDestX;
		player.y = playerDestY;
		canJump = JUMP_CLEAR;

		int tileX = player.x / TILE_SIZE;
		int tileY = player.y / TILE_SIZE;

		if ([Tile hasFlag:map[tileY][tileX] :WALL])
		{
			[self killPlayer:DEATH_SQUISH];
		}

		for (i = 0; i < blockIndex; i++)
		{
			Block *block = [blockQueue objectAtIndex:i];

			if (!block.isVisible)
			{
				continue;
			}

			if ([Utils boxInBox:player.x :player.width :player.y :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
			{
				[self killPlayer:DEATH_SQUISH];
			}
		}
	}
	else
	{
		player.x += vec.x;
		player.y += vec.y;
	}
}

- (void)updateLevelIntro
{
	[vec initVector2D:(playerDestX - player.x) :(playerDestY - player.y)];
	float distance = [vec squaredDistance];

	[vec normalize];
	vec.x *= PORTAL_SPEED;
	vec.y *= PORTAL_SPEED;

	if (distance <= [vec squaredDistance])
	{
		[gameState removeLastObject];
		player.x = playerDestX;
		player.y = playerDestY;

		Billboard *b = [self getAvailableBillboard];
		[b setupBillboard :player.x :player.y :BILLBOARD_TYPE_INTRO_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[self playSound:SOUND_ADD_BLOCK];
	}
	else
	{
		player.x += vec.x;
		player.y += vec.y;
	}
}

- (void)updateProjectiles
{
	int i;

	for (i = 0; i < [projectileArray count]; i++)
	{
		Projectile *p = [projectileArray objectAtIndex:i];

		if (p.isAlive)
		{
			p.x += p.heading.x;
			p.y += p.heading.y;

			if (p.x < 0 || p.x >= TILE_SIZE * (MAP_WIDTH - 1) || 
				p.y < 0 || p.y >= TILE_SIZE * (MAP_HEIGHT - 1))
			{
				p.isAlive = false;
			}
			else
			{
				if ([Utils boxInBox:p.x :p.width :p.y :p.height :player.x :player.width :player.y :player.height])
				{
					[self killPlayer:DEATH_SHOT];
				}

				int tileX = p.x / TILE_SIZE;
				int tileY = p.y / TILE_SIZE;

				if ([Tile hasFlag:map[tileY][tileX] :WALL])
				{
					p.isAlive = false;
				}
			}
		}
	}
}

- (Projectile *)getAvailableProjectile
{
	int i;

	for (i = 0; i < [projectileArray count]; i++)
	{
		Projectile *p = [projectileArray objectAtIndex:i];

		if (!p.isAlive)
		{
			return p;
		}
	}

	Projectile *newP = [Projectile alloc];
	[newP initProjectile:am];
	[projectileArray addObject:newP];
	[newP release];

	return [projectileArray lastObject];
}

- (Billboard *)getAvailableBillboard
{
	int i;

	for (i = 0; i < [billboards count]; i++)
	{
		Billboard *b = [billboards objectAtIndex:i];

		if (!b.isAlive)
		{
			return b;
		}
	}

	Billboard *newB = [Billboard alloc];
	[newB initBillboard:am];
	[billboards addObject:newB];
	[newB release];

	return [billboards lastObject];
}

- (void)convertTime:(int)time
{
	int ms = time * 33;
	int sec = ms / 1000;
	int m = sec / 60;

	timeString = [NSString stringWithFormat:@"%02d:%02d:%02d", m % 100, sec % 60, ms / 10 % 100];

	if (time == MAX_COUNTER)
	{
		timeString = @"59:59:99";
	}
}

- (void)convertUserTime:(UITextField *)textField :(int)time
{
	int sec = time % 60;
	int m = time / 60;

	textField.text = [NSString stringWithFormat:@"%02d:%02d:00", m % 100, sec % 60];
}

- (void)drawGame
{
	int i, j;

	[self centerWorld];

	[(EAGLView *)self.view setFramebuffer];

	glClear(GL_COLOR_BUFFER_BIT);

	[bgImage renderAtPoint:CGPointMake(-((drawTileStartX + (abs(bgOffsetX) / (float)TILE_SIZE)) * 8), -(bgImage.imageHeight - (screenHeight + (drawTileStartY + (abs(bgOffsetY) / (float)TILE_SIZE)) * 8))) centerOfImage:NO];

	[self convertTime:counter];

	if ([self getGameState] != STATE_LEVEL_INTRO && [self getGameState] != STATE_COUNTDOWN)// && !showIntroMessage)
	{
		timerField.text = timeString;
	}
	else
	{
		timerField.text = @"--:--:--";
	}

	for (i = 0; i <= drawTileHeight; i++)
	{
		for (j = 0; j <= drawTileWidth; j++)
		{
			if (i + drawTileStartY >= MAP_HEIGHT || j + drawTileStartX >= MAP_WIDTH)
			{
				continue;
			}

			int tile = map[i + drawTileStartY][j + drawTileStartX];

			if (tile)
			{
				int imgX = [Tile getImageX:tile] * TILE_SIZE;
				int imgY = [Tile getImageY:tile] * TILE_SIZE;

				[mapTiles renderSubImageAtPoint:CGPointMake(j * 32 + bgOffsetX, screenHeight - i * 32 - TILE_SIZE + bgOffsetY) offset:CGPointMake(imgX, imgY) subImageWidth:32.0f subImageHeight:32.0f centerOfImage:NO];
			}
		}
	}

	Animation *animation;
	Image *img;
	CGRect animRect;

	//draw red block, green block, blue block
	for (i = 0; i < blockIndex; i++)
	{
		Block *block = [blockQueue objectAtIndex:i];

		if ((block.type == BLOCK_TYPE_REDBLOCK ||
					block.type == BLOCK_TYPE_GREENBLOCK ||
					block.type == BLOCK_TYPE_BLUEBLOCK) && 
				block.isAlive)
		{
			block.drawBlock = false;

			if ([Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :TILE_SIZE * drawTileStartX + bgOffsetX :screenWidth + TILE_SIZE :TILE_SIZE * drawTileStartY + bgOffsetY :screenHeight + TILE_SIZE])
			{
				block.drawBlock = true;
			}

			if (block.drawBlock)
			{
				animation = [am.anims objectAtIndex:1];
				img = [am.images objectAtIndex:1];
				animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:block.currentFrame] intValue]] CGRectValue];

				[img renderSubImageAtPoint:CGPointMake(block.x - TILE_SIZE * drawTileStartX + bgOffsetX, screenHeight - (block.y - TILE_SIZE * drawTileStartY) - TILE_SIZE + bgOffsetY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
			}

			if ([self getGameState] == STATE_PORTAL ||
					[self getGameState] == STATE_PLAY ||
					[self getGameState] == STATE_GAMEOVER ||
					[self getGameState] == STATE_RESULTS)
			{
				[block nextFrame];
			}
		}
	}

	//draw player
	if (player.isAlive && [self getGameState] != STATE_PORTAL && [self getGameState] != STATE_COUNTDOWN && [self getGameState] != STATE_LEVEL_INTRO && [self getGameState] != STATE_FADE_IN)
	{
		if (player.animState == ANIM_PLAYER_DANCE)
		{
			drawPlayerX -= 12;
		}

		animation = [am.anims objectAtIndex:0];
		img = [am.images objectAtIndex:0];
		animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:player.currentFrame] intValue]] CGRectValue];
		[img renderSubImageAtPoint:CGPointMake(drawPlayerX, screenHeight - drawPlayerY - player.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

		if ([self getGameState] == STATE_PLAY ||
			[self getGameState] == STATE_RESULTS)
		{
			[player nextFrame];
		}
	}

	//draw rest of blocks
	for (i = 0; i < blockIndex; i++)
	{
		Block *block = [blockQueue objectAtIndex:i];

		if (block.type == BLOCK_TYPE_REDBLOCK ||
				block.type == BLOCK_TYPE_GREENBLOCK ||
				block.type == BLOCK_TYPE_BLUEBLOCK ||
				block.type == BLOCK_TYPE_BLADE ||
				!block.isAlive)
		{
			continue;
		}

		block.drawBlock = false;

		if (block.type == BLOCK_TYPE_LASER || [Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :TILE_SIZE * drawTileStartX + bgOffsetX :screenWidth + TILE_SIZE :TILE_SIZE * drawTileStartY + bgOffsetY :screenHeight + TILE_SIZE])
		{
			block.drawBlock = true;
		}

		float drawBlockX = block.x - TILE_SIZE * drawTileStartX + bgOffsetX;
		float drawBlockY = screenHeight - (block.y - TILE_SIZE * drawTileStartY) - TILE_SIZE + bgOffsetY;

		if (block.drawBlock)
		{
			animation = [am.anims objectAtIndex:1];
			img = [am.images objectAtIndex:1];
			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:block.currentFrame] intValue]] CGRectValue];

			switch (block.type)
			{
				case BLOCK_TYPE_MOVINGSPIKES:
				case BLOCK_TYPE_SPIKES_UP:
				case BLOCK_TYPE_SPIKES_DOWN:
				case BLOCK_TYPE_SPIKES_LEFT:
				case BLOCK_TYPE_SPIKES_RIGHT:
					drawBlockX -= (animRect.size.width - TILE_SIZE) / 2;
					drawBlockY -= (animRect.size.height - TILE_SIZE) / 2;
					break;
			}

			[img renderSubImageAtPoint:CGPointMake(drawBlockX, drawBlockY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
		}

		if (block.type == BLOCK_TYPE_LASER)
		{
			for (j = 0; j < [block.damageZones count]; j++)
			{
				CGRect zone = [[block.damageZones objectAtIndex:j] CGRectValue];
				int numLasers;
				int beamFrame;

				if (zone.size.width == 0 || zone.size.height == 0)
				{
					continue;
				}

				switch (j)
				{
					case 0:
						{
							AnimObject *ao = [animation.framePairs objectAtIndex:ANIM_LASER_HORIZONTAL];
							beamFrame = ao.startFrame;
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];
							numLasers = zone.size.width / animRect.size.width;

							[img renderSubImageAsRect:CGRectMake(drawBlockX + zone.origin.x, drawBlockY + 10 + zone.origin.y, zone.size.width, animRect.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

							ao = [animation.framePairs objectAtIndex:ANIM_LASER_START_RIGHT];
							beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

							[img renderSubImageAtPoint:CGPointMake(drawBlockX + 30, drawBlockY + 6 + zone.origin.y) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

							ao = [animation.framePairs objectAtIndex:ANIM_LASER_END_RIGHT];
							beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

							[img renderSubImageAtPoint:CGPointMake(drawBlockX + zone.origin.x + zone.size.width - animRect.size.width, drawBlockY + 6 + zone.origin.y) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
							break;
						}
					case 1:
						{
							AnimObject *ao = [animation.framePairs objectAtIndex:ANIM_LASER_HORIZONTAL];
							beamFrame = ao.startFrame;
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];
							numLasers = zone.size.width / animRect.size.width;

							[img renderSubImageAsRect:CGRectMake(drawBlockX + zone.origin.x, drawBlockY + 10 + zone.origin.y, zone.size.width, animRect.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

							ao = [animation.framePairs objectAtIndex:ANIM_LASER_START_LEFT];
							beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

							[img renderSubImageAtPoint:CGPointMake(drawBlockX - animRect.size.width + 2, drawBlockY + 6 + zone.origin.y) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

							ao = [animation.framePairs objectAtIndex:ANIM_LASER_END_LEFT];
							beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
							animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

							[img renderSubImageAtPoint:CGPointMake(drawBlockX + zone.origin.x, drawBlockY + 6 + zone.origin.y) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
							break;
						}
					case 2:
					{
						AnimObject *ao = [animation.framePairs objectAtIndex:ANIM_LASER_VERTICAL];
						beamFrame = ao.startFrame;
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];
						numLasers = zone.size.height / animRect.size.height;

						[img renderSubImageAsRect:CGRectMake(drawBlockX + 10 + zone.origin.x, drawBlockY + TILE_SIZE, animRect.size.width, zone.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

						ao = [animation.framePairs objectAtIndex:ANIM_LASER_START_UP];
						beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

						[img renderSubImageAtPoint:CGPointMake(drawBlockX + 5, drawBlockY + TILE_SIZE) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

						ao = [animation.framePairs objectAtIndex:ANIM_LASER_END_UP];
						beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

						[img renderSubImageAtPoint:CGPointMake(drawBlockX + 5, drawBlockY + TILE_SIZE - zone.origin.y - animRect.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
						break;
					}
					case 3:
					{
						AnimObject *ao = [animation.framePairs objectAtIndex:ANIM_LASER_VERTICAL];
						beamFrame = ao.startFrame;
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];
						numLasers = zone.size.height / animRect.size.height;

						[img renderSubImageAsRect:CGRectMake(drawBlockX + 10 + zone.origin.x, drawBlockY - zone.size.height, animRect.size.width, zone.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

						ao = [animation.framePairs objectAtIndex:ANIM_LASER_START_DOWN];
						beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

						[img renderSubImageAtPoint:CGPointMake(drawBlockX + 5, drawBlockY - animRect.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

						ao = [animation.framePairs objectAtIndex:ANIM_LASER_END_DOWN];
						beamFrame = ao.startFrame + [block currentFrame] - [block startFrame];
						animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:beamFrame] intValue]] CGRectValue];

						[img renderSubImageAtPoint:CGPointMake(drawBlockX + 5 + zone.origin.x, drawBlockY - zone.size.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
						break;
					}
				}
			}
		}


		if ([self getGameState] == STATE_PORTAL ||
				[self getGameState] == STATE_PLAY ||
				[self getGameState] == STATE_GAMEOVER ||
				[self getGameState] == STATE_RESULTS)
		{
			[block nextFrame];
		}
	}

	//draw blade block
	for (i = 0; i < blockIndex; i++)
	{
		Block *block = [blockQueue objectAtIndex:i];
		float drawBlockX = block.x - TILE_SIZE * drawTileStartX + bgOffsetX;
		float drawBlockY = screenHeight - (block.y - TILE_SIZE * drawTileStartY) - TILE_SIZE + bgOffsetY;

		if (block.type == BLOCK_TYPE_BLADE &&
				block.isAlive &&
				block.drawBlock)
		{
			animation = [am.anims objectAtIndex:1];
			img = [am.images objectAtIndex:1];
			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:block.currentFrame] intValue]] CGRectValue];

			[img renderSubImageAtPoint:CGPointMake(block.x - TILE_SIZE * drawTileStartX + bgOffsetX, screenHeight - (block.y - TILE_SIZE * drawTileStartY) - TILE_SIZE + bgOffsetY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

			AnimObject *ao = [animation.framePairs objectAtIndex:ANIM_BLADE];

			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:ao.startFrame] intValue]] CGRectValue];

			drawBlockX += (TILE_SIZE >> 1) + sin([block getAngle]) * (animRect.size.height / 2);
			drawBlockY += (TILE_SIZE >> 1) - cos([block getAngle]) * (animRect.size.height / 2);

			[img renderSubImageAtPoint:CGPointMake(drawBlockX, drawBlockY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:false rotation:(2 * M_PI - [block getAngle]) / (2 * M_PI) * 360];

			if ([self getGameState] == STATE_PORTAL ||
					[self getGameState] == STATE_PLAY ||
					[self getGameState] == STATE_GAMEOVER ||
					[self getGameState] == STATE_RESULTS)
			{
				[block nextFrame];
			}
		}
	}

	for (i = 0; i < [projectileArray count]; i++)
	{
		Projectile *p = [projectileArray objectAtIndex:i];

		if (p.isAlive)
		{
			animation = [am.anims objectAtIndex:3];
			img = [am.images objectAtIndex:3];
			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:p.image] intValue]] CGRectValue];

			[img renderSubImageAtPoint:CGPointMake(p.x - TILE_SIZE * drawTileStartX + bgOffsetX, screenHeight - (p.y - TILE_SIZE * drawTileStartY) - animRect.size.height + bgOffsetY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
		}
	}

	if (explosionsCounter >= 0)
	{
		if (explosionsCounter == 4 || explosionsCounter == 8)
		{
			int randX = (float)rand() / RAND_MAX * 20 - 10;
			int randY = (float)rand() / RAND_MAX * 20 - 10;

			Billboard *b = [self getAvailableBillboard];
			[b setupBillboard :player.x + randX :player.y + randY :BILLBOARD_TYPE_EXPLOSION :ANIM_EXPLOSION :0 :0 :0];
		}

		explosionsCounter++;

		if (explosionsCounter > 8)
		{
			explosionsCounter = -1;
		}
	}

	for (i = 0; i < [billboards count]; i++)
	{
		Billboard *b = [billboards objectAtIndex:i];

		if (b.isAlive)
		{
			if (b.type == BILLBOARD_TYPE_EXPLOSION || b.type == BILLBOARD_TYPE_PLAYER_DEATH)
			{
				animation = [am.anims objectAtIndex:1];
				img = [am.images objectAtIndex:1];
			}
			else
			{
				animation = [am.anims objectAtIndex:4];
				img = [am.images objectAtIndex:4];
			}

			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:b.currentFrame] intValue]] CGRectValue];

			if (b.rotation > 0)
			{
				[img renderSubImageAtPoint:CGPointMake(b.x - TILE_SIZE * drawTileStartX + bgOffsetX, screenHeight - (b.y - TILE_SIZE * drawTileStartY) - animRect.size.height + bgOffsetY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:false rotation:360 * b.rotation / 360];
			}
			else
			{
				[img renderSubImageAtPoint:CGPointMake(b.x - TILE_SIZE * drawTileStartX + bgOffsetX, screenHeight - (b.y - TILE_SIZE * drawTileStartY) - animRect.size.height + bgOffsetY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
			}

			[b nextFrame];

			if (b.animFinished)
			{
				switch (b.type)
				{
					case BILLBOARD_TYPE_PLAYER_DEATH:
						imageView.hidden = NO;
						imageSubView.hidden = NO;
						hudView.hidden = YES;
						timerField.hidden = YES;
						mainMessageField.hidden = NO;
						retryField.hidden = NO;
						[self selectButtonGroup:BUTTON_GROUP_NONE];
						currentBlock.drawBlock = false;
						blockNumField.hidden = YES;

						switch (gameType)
						{
							case GAME_TYPE_STOCK_LEVEL:
							case GAME_TYPE_USER_LEVEL:
								returnToLevelsButton.hidden = NO;
								break;
							case GAME_TYPE_EDITOR_LEVEL:
								returnToEditorButton.hidden = NO;
								break;
						}
						break;
					case BILLBOARD_TYPE_INTRO_POOF:
					{
						int blockTotal = 0;
						int firstRowStartX = 0;
						int secondRowStartX = 0;
						int blockY = 98;
						CGRect tempFrame;

						for (j = 0; j < MAX_USER_BLOCKS; j++)
						{
							if (blocksAvailable[j])
							{
								blockTotal++;
							}
						}

						firstRowStartX = (blockTotal > 8) ? (screenWidth - (8 * TILE_SIZE)) / 2 : (screenWidth - (blockTotal * TILE_SIZE)) / 2;
						secondRowStartX = (blockTotal > 8) ? (screenWidth - (blockTotal - 8) * TILE_SIZE) / 2 : 0;
						blockY = (blockTotal > 8) ? 98 : 114;
						blockTotal = 0;

						for (j = 0; j < MAX_USER_BLOCKS; j++)
						{
							if (blocksAvailable[j])
							{
								blockImages[j].hidden = NO;
								tempFrame = blockImages[j].frame;
								tempFrame.origin.x = firstRowStartX;
								tempFrame.origin.y = blockY;
								blockImages[j].frame = tempFrame;

								firstRowStartX += TILE_SIZE;
								blockTotal++;

								if (blockTotal == 8)
								{
									firstRowStartX = secondRowStartX;
									blockY += TILE_SIZE;
								}
							}
						}

						if (blockTotal)
						{
							blocksAvailableField.text = @"Available Blocks";
						}
						else
						{
							blocksAvailableField.text = @"No Blocks Available";
						}

						tempFrame = blocksAvailableField.frame;

						if (!blockTotal)
						{
							tempFrame.origin.y = 118;
						}
						else if (blockTotal <= 8)
						{
							tempFrame.origin.y = 88;
						}
						else
						{
							tempFrame.origin.y = 80;
						}

						blocksAvailableField.frame = tempFrame;
						blocksAvailableField.hidden = NO;

						imageView.hidden = NO;
						currentMessageField.hidden = NO;
						goldTimeField.hidden = NO;
						silverTimeField.hidden = NO;
						bronzeTimeField.hidden = NO;
						[gameState addObject:[NSNumber numberWithInteger:STATE_INTRO_MESSAGE]];
						[gameState addObject:[NSNumber numberWithInteger:STATE_PRINT_INTRO_MESSAGE]];
						break;
					}
				}
			}
		}

		if (b.type == BILLBOARD_TYPE_BODY_PART && (b.x < 0 || b.y < 0 || b.x > TILE_SIZE * MAP_WIDTH || b.y > TILE_SIZE* MAP_HEIGHT))
		{
			b.isAlive = false;
		}
	}

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		if (!button.isActive || ((!currentBlock.drawBlock || !blocksAvailable[blocksAvailableIndex]) && button.type == BUTTON_TYPE_BLOCK && [self getGameState] != STATE_CONFIG_BUTTONS))
		{
			continue;
		}

		animation = [am.anims objectAtIndex:2];
		img = [am.images objectAtIndex:2];
		animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:button.currentFrame] intValue]] CGRectValue];

		[img renderSubImageAtPoint:CGPointMake(button.bounds.origin.x + (button.bounds.size.width - animRect.size.width) / 2, screenHeight - (button.bounds.origin.y + button.bounds.size.height)) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
	}

	if (currentBlock.drawBlock)
	{
		float drawBlockX = currentBlock.x;
		float drawBlockY = screenHeight - currentBlock.y;

		if (currentBlock.animFinished)
		{
			[currentBlock resetAnim];
		}
		else if (currentBlock.type == BLOCK_TYPE_LEFTRIGHT ||
			currentBlock.type == BLOCK_TYPE_UPDOWN ||
			currentBlock.type == BLOCK_TYPE_FIRE ||
			currentBlock.type == BLOCK_TYPE_SPRINGBOARD ||
			currentBlock.type == BLOCK_TYPE_GUN)
		{
			if (currentBlock.currentFrame == (currentBlock.endFrame - 1))
			{
				[currentBlock nextState];
			}
		}

		animation = [am.anims objectAtIndex:1];
		img = [am.images objectAtIndex:1];
		animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:currentBlock.currentFrame] intValue]] CGRectValue];

		if (currentBlock.type == BLOCK_TYPE_MOVINGSPIKES)
		{
			drawBlockX -= (animRect.size.width - TILE_SIZE) / 2;
			drawBlockY -= (animRect.size.height - TILE_SIZE) / 2;
		}

		[img renderSubImageAtPoint:CGPointMake(drawBlockX, drawBlockY) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

		[currentBlock nextFrame];
	}

	[(EAGLView *)self.view presentFramebuffer];
}

- (void)drawEditor
{
	int i, j;

	[(EAGLView *)self.view setFramebuffer];

	glClear(GL_COLOR_BUFFER_BIT);

	CGRect gridFrame = gridView.frame;
	gridFrame.origin.x = bgOffsetX;
	gridFrame.origin.y = bgOffsetY;
	gridView.frame = gridFrame;

	[bgImage renderAtPoint:CGPointMake(-((drawTileStartX + (abs(bgOffsetX) / (float)TILE_SIZE)) * 8), -(bgImage.imageHeight - (screenHeight + (drawTileStartY - (abs(bgOffsetY) / (float)TILE_SIZE)) * 8))) centerOfImage:NO];

	for (i = 0; i <= drawTileHeight; i++)
	{
		for (j = 0; j <= drawTileWidth; j++)
		{
			if (i + drawTileStartY >= MAP_HEIGHT || j + drawTileStartX >= MAP_WIDTH)
			{
				continue;
			}

			int tile = map[i + drawTileStartY][j + drawTileStartX];

			if (tile)
			{
				int imgX = [Tile getImageX:tile] * TILE_SIZE;
				int imgY = [Tile getImageY:tile] * TILE_SIZE;

				[mapTiles renderSubImageAtPoint:CGPointMake(j * 32 + bgOffsetX, screenHeight - i * 32 - TILE_SIZE + bgOffsetY) offset:CGPointMake(imgX, imgY) subImageWidth:32.0f subImageHeight:32.0f centerOfImage:NO];
			}

			int specialTile = special[i + drawTileStartY][j + drawTileStartX];

			if (specialTile)
			{
				int imgX = (int)(specialTile % 5) * TILE_SIZE;
				int imgY = (int)(specialTile  / 5) * TILE_SIZE;
				int xOffset = 0;
				int yOffset = 0;

				switch (specialTile)
				{
					case SPECIAL_SPIKES_UP:
						yOffset = -21;
						break;
					case SPECIAL_SPIKES_LEFT:
						xOffset = -21;
						yOffset = 2;
						break;
					case SPECIAL_SPIKES_RIGHT:
						xOffset = 21;
						yOffset = 2;
						break;
					case SPECIAL_SPIKES_DOWN:
						yOffset = 21;
						break;
				}

				[specialTiles renderSubImageAtPoint:CGPointMake(j * 32 + bgOffsetX + xOffset, screenHeight - i * 32 - TILE_SIZE + bgOffsetY - yOffset) offset:CGPointMake(imgX, imgY) subImageWidth:32.0f subImageHeight:32.0f centerOfImage:NO];
			}
		}
	}

	if ((int)selection.size.width != 0 && (int)selection.size.height != 0)
	{
		CGRect drawRect = CGRectMake(selection.origin.x, selection.origin.y, selection.size.width, selection.size.height);

		drawRect.origin.x -= TILE_SIZE * drawTileStartX - bgOffsetX;
		drawRect.origin.y -= TILE_SIZE * drawTileStartY + bgOffsetY;

		GLfloat line1[] = {drawRect.origin.x, screenHeight - drawRect.origin.y, drawRect.origin.x + drawRect.size.width,screenHeight -  drawRect.origin.y};
		GLfloat line2[] = {drawRect.origin.x + drawRect.size.width, screenHeight - drawRect.origin.y, drawRect.origin.x + drawRect.size.width, screenHeight - (drawRect.origin.y + drawRect.size.height)};
		GLfloat line3[] = {drawRect.origin.x + drawRect.size.width, screenHeight - (drawRect.origin.y + drawRect.size.height), drawRect.origin.x, screenHeight - (drawRect.origin.y + drawRect.size.height)};
		GLfloat line4[] = {drawRect.origin.x, screenHeight - (drawRect.origin.y + drawRect.size.height), drawRect.origin.x, screenHeight - drawRect.origin.y};

		glPushMatrix();
		glLineWidth(4);
		glColor4f(1.0f, 1.0f, 1.0f, 0.0f);
		glVertexPointer(2, GL_FLOAT, 0, line1);
		glDrawArrays(GL_LINES, 0, 2);
		glVertexPointer(2, GL_FLOAT, 0, line2);
		glDrawArrays(GL_LINES, 0, 2);
		glVertexPointer(2, GL_FLOAT, 0, line3);
		glDrawArrays(GL_LINES, 0, 2);
		glVertexPointer(2, GL_FLOAT, 0, line4);
		glDrawArrays(GL_LINES, 0, 2);
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glPopMatrix();
	}

	[(EAGLView *)self.view presentFramebuffer];
}

- (void)setupCutscene
{
	[blockQueue removeAllObjects];
	blockIndex = 0;

	[billboards removeAllObjects];

	[bgImage release];
	bgImage = [[Image alloc] initWithString:@"EndingBG480x320.png"];

	player.x = -64;
	player.y = 160;
	[player setAnim:ANIM_PLAYER_RUN_RIGHT];

	Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_GOAL WithAssetManager:am];
	addedBlock.x = 7 * TILE_SIZE;
	addedBlock.y = 192;
	[blockQueue addObject:addedBlock];
	blockIndex++;
	[addedBlock release];

	cutsceneFrames = 0;
	congratsAdded = false;
	[self playSong:0 repeats:YES];
}

- (void)updateCutscene
{
	Billboard *b;
	int i;

	player.x += player.speed;

	if (player.x >= 7 * TILE_SIZE)
	{
		player.x = 7 * TILE_SIZE;
		[player setAnim:ANIM_PLAYER_DANCE];
	}

	if (cutsceneFrames == 10)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_DEFAULT WithAssetManager:am];
		addedBlock.x = 2 * TILE_SIZE;
		addedBlock.y = 192;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 17)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_DEFAULT WithAssetManager:am];
		addedBlock.x = 3 * TILE_SIZE;
		addedBlock.y = 192;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 24)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_DEFAULT WithAssetManager:am];
		addedBlock.x = 4 * TILE_SIZE;
		addedBlock.y = 192;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 31)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_DEFAULT WithAssetManager:am];
		addedBlock.x = 5 * TILE_SIZE;
		addedBlock.y = 192;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 38)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_DEFAULT WithAssetManager:am];
		addedBlock.x = 6 * TILE_SIZE;
		addedBlock.y = 192;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 70)
	{
		b = [self getAvailableBillboard];
		[b setupBillboard :2 * TILE_SIZE :screenHeight :BILLBOARD_TYPE_FIREWORK :ANIM_FIREWORK_UP :-16 :0 :M_PI / 2];
	}
	if (cutsceneFrames == 78)
	{
		b = [self getAvailableBillboard];
		[b setupBillboard :8 * TILE_SIZE :screenHeight :BILLBOARD_TYPE_FIREWORK2 :ANIM_FIREWORK_UP :-16 :0 :M_PI / 2];
	}
	if (cutsceneFrames == 86)
	{
		b = [self getAvailableBillboard];
		[b setupBillboard :5 * TILE_SIZE :screenHeight :BILLBOARD_TYPE_FIREWORK :ANIM_FIREWORK_UP :-16 :0 :M_PI / 2];
	}
	if (cutsceneFrames == 92)
	{
		b = [self getAvailableBillboard];
		[b setupBillboard : 10 * TILE_SIZE :screenHeight :BILLBOARD_TYPE_FIREWORK2 :ANIM_FIREWORK_UP :-16 :0 :M_PI / 2];
	}

	if (cutsceneFrames == 128)
	{
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT3]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT2]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT1]];
	}

	if (cutsceneFrames == 140)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 150)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 3 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 160)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 5 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 170)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 7 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 180)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 9 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 190)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 11 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}
	if (cutsceneFrames == 200)
	{
		Block *addedBlock = [[Block alloc] initBlock:BLOCK_TYPE_CAKE WithAssetManager:am];
		addedBlock.x = 13 * TILE_SIZE;
		addedBlock.y = 96;
		[blockQueue addObject:addedBlock];
		blockIndex++;

		b = [self getAvailableBillboard];
		[b setupBillboard :addedBlock.x :addedBlock.y :BILLBOARD_TYPE_POOF :ANIM_EFFECT_POOF :0 :0 :0];
		[addedBlock release];
		[self playSound:SOUND_ADD_BLOCK];
	}

	if (cutsceneFrames == 232)
	{
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT7]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT6]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT5]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE_TEXT4]];
	}

	if (cutsceneFrames == 300)
	{
		[gameState removeLastObject];
	}

	int maxBillboards = [billboards count];

	for (i = 0; i < maxBillboards; i++)
	{
		Billboard *b = [billboards objectAtIndex:i];

		if (b.isAlive)
		{
			switch (b.type)
			{
				case BILLBOARD_TYPE_FIREWORK:
				case BILLBOARD_TYPE_FIREWORK2:
				{
					if (b.y < 76)
					{
						if (b.type == BILLBOARD_TYPE_FIREWORK)
						{
							[self playSound:SOUND_FIREWORKS];
						}

						b.isAlive = false;
						[b setupBillboard :b.x :76 :BILLBOARD_TYPE_FIREWORK :ANIM_FIREWORK_EXPLODE :0 :0 :0];

						if (!congratsAdded)
						{
							Billboard *congrats = [self getAvailableBillboard];
							[congrats setupBillboard :24 :48 :BILLBOARD_TYPE_CONGRATS :ANIM_CONGRATS :0 :0 :0];
							congratsAdded = true;
						}
					}
					break;
				}
			}
		}
	}

	if ([self getGameState] == STATE_CUTSCENE)
	{
		cutsceneFrames++;
	}
}

- (void)drawCutscene
{
	Animation *animation;
	Image *img;
	CGRect animRect;
	int i;
	int drawCutsceneX = player.x;

	if (player.animState == ANIM_PLAYER_DANCE)
	{
		drawCutsceneX -= 12;
	}

	[bgImage renderAtPoint:CGPointMake(0, 0) centerOfImage:NO];

	animation = [am.anims objectAtIndex:0];
	img = [am.images objectAtIndex:0];
	animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:player.currentFrame] intValue]] CGRectValue];
	[img renderSubImageAtPoint:CGPointMake(drawCutsceneX, screenHeight - player.y - player.height) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

	[player nextFrame];

	for (i = 0; i < blockIndex; i++)
	{
		Block *block = [blockQueue objectAtIndex:i];

		animation = [am.anims objectAtIndex:1];
		img = [am.images objectAtIndex:1];
		animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:block.currentFrame] intValue]] CGRectValue];

		[img renderSubImageAtPoint:CGPointMake(block.x, screenHeight - block.y - TILE_SIZE) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];
		
		[block nextFrame];
	}

	for (i = 0; i < [billboards count]; i++)
	{
		Billboard *b = [billboards objectAtIndex:i];

		if (b.isAlive)
		{
			int animIndex = 4;

			switch (b.type)
			{
				case BILLBOARD_TYPE_FIREWORK:
					animIndex = 5;
					break;
				case BILLBOARD_TYPE_FIREWORK2:
					animIndex = 6;
					break;
				case BILLBOARD_TYPE_CONGRATS:
					animIndex = 7;
					break;
			}

			animation = [am.anims objectAtIndex:animIndex];
			img = [am.images objectAtIndex:animIndex];
			animRect = [[animation.animBounds objectAtIndex:[[animation.frameList objectAtIndex:b.currentFrame] intValue]] CGRectValue];

			[img renderSubImageAtPoint:CGPointMake(b.x, screenHeight - b.y - TILE_SIZE) offset:animRect.origin subImageWidth:animRect.size.width subImageHeight:animRect.size.height centerOfImage:NO];

			[b nextFrame];
		}
	}
}

- (void)centerWorld
{
	int tileX = player.x / TILE_SIZE;
	int tileY = player.y / TILE_SIZE;
	int diffX = tileX - (drawTileWidth >> 1);
	int diffY = tileY - (drawTileHeight >> 1);

	drawTileStartX = 0;
	drawTileStartY = 0;
	bgOffsetX = 0;
	bgOffsetY = 0;
	drawPlayerX = player.x;
	drawPlayerY = player.y;

	if ((diffX + 1) > 0 && (MAP_WIDTH > drawTileWidth))
	{
		drawTileStartX = diffX;
		drawPlayerX = (drawTileWidth >> 1) * TILE_SIZE;

		if (drawTileStartX + drawTileWidth >= MAP_WIDTH)
		{
			drawTileStartX = MAP_WIDTH - drawTileWidth;
			drawPlayerX = player.x - (MAP_WIDTH - drawTileWidth) * TILE_SIZE;
		}
		else
		{
			bgOffsetX -= player.x % TILE_SIZE;
		}
	}
	if ((diffY + 1) > 0 && (MAP_HEIGHT > drawTileHeight))
	{
		drawTileStartY = diffY;
		drawPlayerY = (drawTileHeight >> 1) * TILE_SIZE;

		if (drawTileStartY + drawTileHeight >= MAP_HEIGHT)
		{
			drawTileStartY = MAP_HEIGHT - drawTileHeight;
			drawPlayerY = player.y - (MAP_HEIGHT - drawTileHeight) * TILE_SIZE;
		}
		else
		{
			bgOffsetY = player.y % TILE_SIZE;
		}
	}
}

- (BOOL)playerMoveDown:(int)dist
{
	int i, j;
	int tileX = player.x / TILE_SIZE;
	int tileY = (player.y + player.height + dist) / TILE_SIZE;
	Block *block;
	int closestIndex = 0;
	int closestDistance = INT_MAX;
	BOOL resetSlide = true;
	BOOL onTile = false;
	BOOL onBlock = false;
	int yFinalPos = INT_MAX;
	int nudgeX = 0;
	int xOffset = player.x % TILE_SIZE;
	int nudgeThreshold = 2;

	if (!player.isAlive)
	{
		return false;
	}

	setBoost = 0;

	if ((player.y / TILE_SIZE) > MAP_HEIGHT)
	{
		[self killPlayer:DEATH_FALLING];
		return false;
	}

	if (tileY >= MAP_HEIGHT)
	{
		player.y += dist;
		return true;
	}
	
	if (xOffset && (xOffset <= nudgeThreshold) && [Tile hasFlag:map[tileY][tileX + 1] :WALL] && ![Tile hasFlag:map[tileY][tileX] :WALL])
	{
		nudgeX = -xOffset;
	}
	else if (xOffset >= (TILE_SIZE - nudgeThreshold) && [Tile hasFlag:map[tileY][tileX] :WALL] && ![Tile hasFlag:map[tileY][tileX + 1] :WALL])
	{
		nudgeX = (TILE_SIZE - xOffset);
	}
	else
	{
		if ([Tile hasFlag:map[tileY][tileX] :WALL] || ((player.x % TILE_SIZE > 0) && [Tile hasFlag:map[tileY][tileX + 1] :WALL]))
		{
			yFinalPos = player.y = (tileY * TILE_SIZE) - player.height;
			onTile = true;
		}
	}

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		if (!block.isVisible || !block.isAlive || !block.drawBlock)
		{
			continue;
		}

		if ([Utils boxInBox:player.x :player.width :player.y + dist :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
		{
			if (yFinalPos >= (block.y - player.height))
			{
				xOffset = player.x - block.x;

				if ((xOffset < 0) && ((player.x + player.width - block.x) <= nudgeThreshold))
				{
					nudgeX = -(player.x + player.width - block.x);
				}
				else if ((xOffset > 0) && ((TILE_SIZE - xOffset) <= nudgeThreshold))
				{
					nudgeX = block.x + TILE_SIZE - player.x;
				}
				else
				{
					yFinalPos = (block.y - player.height);
					onBlock = true;
					nudgeX = 0;
				}
			}
		}

		[vec initVector2D:(block.x + (TILE_SIZE >> 1)) - (player.x + (player.width >> 1)) :block.y - (player.y + (player.height >> 1))];
		float diff = [vec squaredDistance];

		if (block.y > player.y && diff < closestDistance)
		{
			closestDistance = diff;
			closestIndex = i;
		}
	}

	block = [blockQueue objectAtIndex:closestIndex];

	if (onBlock)
	{
		player.boost = 0;

		//standing on a block, so handle player actions here
		if (player.state & PLAYER_ACTION)
		{
			[self downButtonUp];

			if ([Utils pointInBox:player.x + (player.width >> 1) :player.y + dist + player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
			{
				switch (block.type)
				{
					case BLOCK_TYPE_REDPORTAL:
					case BLOCK_TYPE_GREENPORTAL:
					case BLOCK_TYPE_BLUEPORTAL:
					{
						int checkIndex = closestIndex;
						checkIndex = ((checkIndex  + 1) < blockIndex) ? checkIndex + 1 : 0;

						while (checkIndex != closestIndex)
						{
							Block *tempBlock = [blockQueue objectAtIndex:checkIndex];

							if (tempBlock.type == block.type)
							{
								destPortalIndex = checkIndex;
								playerDestX = tempBlock.x;
								playerDestY = (tempBlock.y - player.height);
								[block nextState];

								if (resetSlide)
								{
									player.slide = 0;
								}

								[gameState addObject:[NSNumber numberWithInteger:STATE_PORTAL]];
								[self playSound:SOUND_PORTAL];
								return false;
							}

							checkIndex = ((checkIndex + 1) < blockIndex) ? checkIndex + 1 : 0;
						}
						break;
					}
					case BLOCK_TYPE_REDSWITCH:
					case BLOCK_TYPE_GREENSWITCH:
					case BLOCK_TYPE_BLUESWITCH:
					{	
						if ([block getAnim] != ANIM_REDSWITCH_ON &&
							[block getAnim] != ANIM_GREENSWITCH_ON)
						{
							if (block.type == BLOCK_TYPE_BLUESWITCH)
							{
								if (switchCounter)
								{
									break;
								}
								else
								{
									switchCounter = SWITCH_COUNTER_FRAMES;
								}
							}

							[self playSound:SOUND_SWITCH];
							[block nextState];

							for (j = 0; j < blockIndex; j++)
							{
								if (j == closestIndex)
								{
									continue;
								}

								Block *tempBlock = [blockQueue objectAtIndex:j];

								if (tempBlock.type == (block.type + 1) || tempBlock.type == block.type)
								{
									if ([Utils boxInBox:player.x :player.width :player.y :player.height :tempBlock.x :TILE_SIZE :tempBlock.y :TILE_SIZE])
									{
										[self killPlayer:DEATH_SQUISH];
									}

									[tempBlock nextState];
									[self resetLasers:tempBlock];
								}
							}
						}
						break;
					}
					case BLOCK_TYPE_GOAL:
					{
						[self goalPlayer];
						break;
					}
				}
			}
		}

		switch (block.type)
		{
			case BLOCK_TYPE_FIRE:
				if (!(player.state & PLAYER_JUMP) && [block getAnim] == ANIM_FIRE_ACTION)
				{
					[self killPlayer:DEATH_FIRE];
				}		
				break;
			case BLOCK_TYPE_SPRINGBOARD:
				player.state |= PLAYER_SPRING;
				[block nextState];
				[self playSound:SOUND_SPRINGBOARD];
				break;
			case BLOCK_TYPE_RIGHTCONVEYOR:
				[self playerMoveRight:block.heading.x];
				if (player.state & (PLAYER_LEFT | PLAYER_RIGHT))
				{
					setBoost = block.heading.x;
				}
				break;
			case BLOCK_TYPE_LEFTCONVEYOR:
				[self playerMoveLeft:abs(block.heading.x)];
				if (player.state & (PLAYER_LEFT | PLAYER_RIGHT))
				{
					setBoost = block.heading.x;
				}
				break;
			case BLOCK_TYPE_LEFTRIGHT:
				if (block.heading.x < 0)
				{
					[self playerMoveLeft:abs(block.heading.x)];
				}
				else
				{
					[self playerMoveRight:block.heading.x];
				}
				break;
			case BLOCK_TYPE_BOMB:
				if ([block getAnim] == ANIM_BOMB)
				{
					[block nextState];
				}
				break;
			case BLOCK_TYPE_BUBBLE:
				if (!block.counter && block.heading.y != 1)
				{
					block.counter = BLOCK_BUBBLE_IDLE_TIME;
				}
				break;
			case BLOCK_TYPE_ICE:
				resetSlide = false;
				if (player.state & PLAYER_LEFT)
				{
					player.slide = -player.speed;
				}
				else if (player.state & PLAYER_RIGHT)
				{
					player.slide = player.speed;
				}
				break;
		}

		//check for player deaths
		switch (block.type)
		{
			
		}

		if (resetSlide)
		{
			player.slide = 0;
		}
	}

	if (resetSlide)
	{
		player.slide = 0;
	}	
	if (onTile)
	{
		player.boost = 0;
	}
	if (!onTile && !onBlock)
	{
		if (nudgeX < 0)
		{
			[self playerMoveLeft:abs(nudgeX)];
		}
		else if (nudgeX > 0)
		{
			[self playerMoveRight:nudgeX];
		}

		player.y += dist;
		return true;
	}
	else
	{
		player.y = yFinalPos;
		canJump &= ~JUMP_IN_AIR;
		return false;
	}
}

- (BOOL)playerMoveUp:(int)dist
{
	int i;
	int tileX = player.x / TILE_SIZE;
	int tileY = (player.y - dist) / TILE_SIZE;
	Block *block;
	int nudgeX = 0;
	int xOffset = player.x % TILE_SIZE;
	int nudgeThreshold = 12;

	if (!player.isAlive)
	{
		return false;
	}

	if (xOffset && (xOffset <= nudgeThreshold) && [Tile hasFlag:map[tileY][tileX + 1] :WALL] && ![Tile hasFlag:map[tileY][tileX] :WALL])
	{
		nudgeX = -xOffset;
	}
	else if (xOffset >= TILE_SIZE - nudgeThreshold && [Tile hasFlag:map[tileY][tileX] :WALL] && ![Tile hasFlag:map[tileY][tileX + 1] :WALL])
	{
		nudgeX = (TILE_SIZE - xOffset);
	}
	else
	{
		if (tileY < 1 || [Tile hasFlag:map[tileY][tileX] :WALL] || (xOffset && [Tile hasFlag:map[tileY][tileX + 1] :WALL]))
		{
			player.y = (tileY * TILE_SIZE) + TILE_SIZE;
			return false;
		}
	}

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		if (!block.isVisible || !block.isAlive || !block.drawBlock)
		{
			continue;
		}

		if ([Utils boxInBox:player.x :player.width :player.y - dist :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
		{
			xOffset = player.x - block.x;

			if ((xOffset < 0) && ((player.x + player.width - block.x) <= nudgeThreshold))
			{
				nudgeX = -(player.x + player.width - block.x);
			}
			else if ((xOffset > 0) && ((TILE_SIZE - xOffset) <= nudgeThreshold))
			{
				nudgeX = block.x + TILE_SIZE - player.x;
			}
			else
			{
				player.y = block.y + TILE_SIZE;
				return false;
			}
		}
	}

	player.y -= dist;

	if (nudgeX < 0)
	{
		[self playerMoveLeft :abs(nudgeX)];
	}
	else if (nudgeX > 0)
	{
		[self playerMoveRight :nudgeX];
	}

	return true;
}

- (BOOL)playerMoveLeft:(int)dist
{
	int i;
	int tileX = (player.x - dist) / TILE_SIZE;
	int tileY = player.y / TILE_SIZE;
	Block *block;

	if (!player.isAlive)
	{
		return false;
	}

	if (tileY + 1 >= MAP_HEIGHT)
	{
		if (tileX >= MAP_WIDTH || [Tile hasFlag:map[MAP_HEIGHT - 1][tileX] :WALL])
		{
			player.x = (tileX * TILE_SIZE) + TILE_SIZE;
			return false;
		}
		else
		{
			player.x -= dist;
			return true;
		}
	}

	if (tileX < 1 || [Tile hasFlag:map[tileY][tileX] : WALL] || ((player.y % TILE_SIZE > 0) && [Tile hasFlag:map[tileY + 1][tileX] :WALL]))
	{
		player.x = (tileX * TILE_SIZE) + TILE_SIZE;
		return false;
	}

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		if (!block.isVisible || !block.isAlive || !block.drawBlock)
		{
			continue;
		}

		if ([Utils boxInBox:player.x - dist :player.width :player.y :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
		{
			player.x = (block.x + TILE_SIZE);
			return false;
		}
	}

	player.x -= dist;
	return true;
}

- (BOOL)playerMoveRight:(int)dist
{
	int i;
	int tileX = (player.x + player.width + dist) / TILE_SIZE;
	int tileY = player.y / TILE_SIZE;
	Block *block;

	if (!player.isAlive)
	{
		return false;
	}

	if (tileY + 1 >= MAP_HEIGHT)
	{
		if (tileX >= MAP_WIDTH || [Tile hasFlag:map[MAP_HEIGHT - 1][tileX] :WALL])
		{
			player.x = (tileX * TILE_SIZE) - player.width;
			return false;
		}
		else
		{
			player.x += dist;
			return true;
		}
	}

	if (tileX >= MAP_WIDTH || [Tile hasFlag:map[tileY][tileX] :WALL] || ((player.y % TILE_SIZE > 0) && [Tile hasFlag:map[tileY + 1][tileX] :WALL]))
	{
		player.x = (tileX * TILE_SIZE) - player.width;
		return false;
	}

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		if (!block.isVisible || !block.isAlive || !block.drawBlock)
		{
			continue;
		}

		if ([Utils boxInBox:player.x + dist :player.width :player.y :player.height :block.x :TILE_SIZE :block.y :TILE_SIZE])
		{
			player.x = (block.x - player.width);
			return false;
		}
	}

	player.x += dist;
	return true;
}

- (void)goalPlayer
{
	checkpointX = -1;
	checkpointY = -1;
	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_RESULTS]];

	frames = 0;
	[self setImageView:@"levelresults.png" :imageView :INT_MAX :INT_MAX];

	int sec = counter * 33 / 1000;
	int medalType = MEDAL_TYPE_NONE;

	if (sec < goldTime)
	{
		[self setImageView:@"medals_gold.png" :imageSubView :286 :INT_MAX];
		medalType = MEDAL_TYPE_GOLD;
	}
	else if (sec < silverTime)
	{
		[self setImageView:@"medals_silver.png" :imageSubView :286 :INT_MAX];
		medalType = MEDAL_TYPE_SILVER;
	}
	else if (sec < bronzeTime)
	{
		[self setImageView:@"medals_bronze.png" :imageSubView :286 :INT_MAX];
		medalType = MEDAL_TYPE_BRONZE;
	}
	else
	{
		[self setImageView:@"medals_bronze.png" :imageSubView :screenWidth :screenHeight];
	}

	imageView.hidden = YES;
	imageSubView.hidden = YES;

	if (gameType == GAME_TYPE_STOCK_LEVEL)
	{
		if (levelTimes[currentLevel] < 0 || counter < levelTimes[currentLevel])
		{
			levelProgress[currentLevel] = medalType;
			levelTimes[currentLevel] = counter;
		}

		if (currentLevel + 1 < MAX_MAPS && levelProgress[currentLevel + 1] < 0)
		{
			levelProgress[currentLevel + 1] = 0;
		}

		[self saveProgress];

        /*
		switch (currentLevel)
		{
			case 6: //last grass
				[[OFAchievement achievement:@"1482462"] updateProgressionComplete:100.0f andShowNotification:YES];
				break;
			case 16: //last factory
				[[OFAchievement achievement:@"1482442"] updateProgressionComplete:100.0f andShowNotification:YES];
				break;
			case 22: //last space
				[[OFAchievement achievement:@"1482472"] updateProgressionComplete:100.0f andShowNotification:YES];
				break;
			case 27: //last underground
				[[OFAchievement achievement:@"1482482"] updateProgressionComplete:100.0f andShowNotification:YES];
				break;
			case 34: //last city
				[[OFAchievement achievement:@"1482432"] updateProgressionComplete:100.0f andShowNotification:YES];
			break;
		}
         */
	}

	hudView.hidden = YES;
	[self selectButtonGroup:BUTTON_GROUP_NONE];
	currentBlock.drawBlock = false;
	blockNumField.hidden = YES;
	timerField.hidden = YES;

	[self playSound:SOUND_GOAL];
}

- (void)setupCrystals
{
	int i, j;

	for (i = 0; i < blockIndex; i++)
	{
		Block *crystalBlock = [blockQueue objectAtIndex:i];

		if (!crystalBlock.isAlive || crystalBlock.type != BLOCK_TYPE_CRYSTAL)
		{
			continue;
		}
		
		crystalBlock.numLasers = 0;

		for (j = 0; j < blockIndex; j++)
		{
			Block *laserBlock = [blockQueue objectAtIndex:j];

			if (!laserBlock.isAlive || laserBlock.type != BLOCK_TYPE_LASER)
			{
				continue;
			}

			CGRect zone = CGRectMake(0, 0, 0, 0);

			if (crystalBlock.y - laserBlock.y == 0 && //crystal is to the right
				crystalBlock.x > laserBlock.x)
			{
				zone = [[laserBlock.damageZones objectAtIndex:0] CGRectValue];

				if ([Utils boxInBox:crystalBlock.x :TILE_SIZE :crystalBlock.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width + 1 :laserBlock.y + zone.origin.y :zone.size.height])
				{
					crystalBlock.numLasers++;
				}
			}
			else if (crystalBlock.y - laserBlock.y == 0 && //crystal is to the left
				crystalBlock.x < laserBlock.x)
			{
				zone = [[laserBlock.damageZones objectAtIndex:1] CGRectValue];

				if ([Utils boxInBox:crystalBlock.x :TILE_SIZE :crystalBlock.y :TILE_SIZE :laserBlock.x + zone.origin.x - 1 :zone.size.width :laserBlock.y + zone.origin.y :zone.size.height])
				{
					crystalBlock.numLasers++;
				}
			}
			else if (crystalBlock.x - laserBlock.x == 0 && //crystal is above
					crystalBlock.y < laserBlock.y)
			{
				zone = [[laserBlock.damageZones objectAtIndex:2] CGRectValue];

				if ([Utils boxInBox:crystalBlock.x :TILE_SIZE :crystalBlock.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width :laserBlock.y + zone.origin.y - 1 :zone.size.height])
				{
					crystalBlock.numLasers++;
				}
			}
			else if (crystalBlock.x - laserBlock.x == 0 && //crystal is below
					crystalBlock.y > laserBlock.y)
			{
				zone = [[laserBlock.damageZones objectAtIndex:3] CGRectValue];

				if ([Utils boxInBox:crystalBlock.x :TILE_SIZE :crystalBlock.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width :laserBlock.y + zone.origin.y :zone.size.height + 1])
				{
					crystalBlock.numLasers++;
				}
			}
		}
	}
}

- (void)setupLasers
{
	int i, j, k;
	Block *block;
	Block *collideBlock;

	for (i = 0; i < blockIndex; i++)
	{
		block = [blockQueue objectAtIndex:i];

		switch (block.type)
		{
			case BLOCK_TYPE_LASER:
			{
				NSMutableArray *zones = [NSMutableArray array];

				for (j = 0; j < 4; j++)
				{
					int beamLength = 0;
					int startX = block.x / TILE_SIZE;
					int startY = block.y / TILE_SIZE;

					switch (j)
					{
						case 0: //check for right extent
							for (k = startX + 1; k <= MAP_WIDTH; k++)
							{
								if (k >= MAP_WIDTH || [Tile hasFlag:map[startY][k] :WALL])
								{
									[zones addObject:[NSValue valueWithCGRect:CGRectMake(TILE_SIZE, 0, beamLength, TILE_SIZE)]];
									block.rightExtent = beamLength;
									break;
								}
								else 
								{
									beamLength += TILE_SIZE;
								}
							}
							break;
						case 1: //check for left extent
							for (k = (startX - 1); k >= -1; k--)
							{
								if (k == -1 || [Tile hasFlag:map[startY][k] :WALL])
								{
									[zones addObject:[NSValue valueWithCGRect:CGRectMake(-beamLength, 0, beamLength, TILE_SIZE)]];
									block.leftExtent = beamLength;
									break;
								}
								else
								{
									beamLength += TILE_SIZE;
								}
							}
							break;
						case 2: //check for up extent
							for (k = (startY - 1); k >= -1; k--)
							{
								if (k == -1 || [Tile hasFlag:map[k][startX] :WALL])
								{
									[zones addObject:[NSValue valueWithCGRect:CGRectMake(0, -beamLength, TILE_SIZE, beamLength)]];
									block.upExtent  = beamLength;
									break;
								}
								else
								{
									beamLength += TILE_SIZE;
								}
							}
							break;
						case 3: //check for down extent
							for (k = (startY + 1); k <= MAP_HEIGHT; k++)
							{
								if (k >= MAP_HEIGHT || [Tile hasFlag:map[k][startX] :WALL])
								{
									[zones addObject:[NSValue valueWithCGRect:CGRectMake(0, TILE_SIZE, TILE_SIZE, beamLength)]];
									block.downExtent = beamLength;
									break;
								}	
								else
								{
									beamLength += TILE_SIZE;
								}
							}
							break;
					}
				}

				for (j = 0; j < 4; j++)
				{
					for (k = 0; k < blockIndex; k++)
					{
						collideBlock = [blockQueue objectAtIndex:k];

						if (i == k || !collideBlock.isVisible || !collideBlock.isAlive)
						{
							continue;
						}

						CGRect rect = [[zones objectAtIndex:j] CGRectValue];

						if ([Utils boxInBox:block.x + rect.origin.x :rect.size.width :block.y + rect.origin.y :rect.size.height :collideBlock.x :TILE_SIZE :collideBlock.y :TILE_SIZE])
						{
							BOOL blockImpassable = false;

							switch ([collideBlock getAnim])
							{
								case ANIM_REDBLOCK_VISIBLE:
								case ANIM_BLUEBLOCK_VISIBLE:
								case ANIM_GREENBLOCK_VISIBLE:
									blockImpassable = true;
									break;
							}

							switch (collideBlock.type)
							{
								case BLOCK_TYPE_LASER:
								case BLOCK_TYPE_GOAL:
								case BLOCK_TYPE_CRYSTAL:
									blockImpassable = true;
									break;
							}

							if (blockImpassable) //resize the extents
							{
								switch (j)
								{
									case 0: //collision to right
										rect.size.width = abs((block.x + TILE_SIZE) - collideBlock.x);
										break;
									case 1:
										rect.size.width = abs(block.x - (collideBlock.x + TILE_SIZE));
										rect.origin.x = -rect.size.width;
										break;
									case 2:
										rect.size.height = abs(block.y - (collideBlock.y + TILE_SIZE));
										rect.origin.y = -rect.size.height;
										break;
									case 3:
										rect.size.height = abs((block.y + TILE_SIZE) - collideBlock.y);
										break;
								}
							}
						}

						[zones replaceObjectAtIndex:j withObject:[NSValue valueWithCGRect:rect]];
					}
				}

				[block.damageZones removeAllObjects];
				[block.damageZones setArray:zones];
				break;
			}
		}
	}
}

- (void)resetLasers:(Block *)block
{
	int i, j;

	for (i = 0; i < blockIndex; i++)
	{
		Block *laserBlock = [blockQueue objectAtIndex:i];

		if (!laserBlock.isAlive || laserBlock.type != BLOCK_TYPE_LASER)
		{
			continue;
		}

		CGRect zone = CGRectMake(0, 0, 0, 0);

		if (block.y - laserBlock.y == 0 && //block is to the right
			block.x > laserBlock.x)
		{
			zone = [[laserBlock.damageZones objectAtIndex:0] CGRectValue];

			if ([Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width + 1 :laserBlock.y + zone.origin.y :zone.size.height])
			{
				zone.size.width = laserBlock.rightExtent;

				for (j = 0; j < blockIndex; j++)
				{
					Block *checkBlock = [blockQueue objectAtIndex:j];

					if (!checkBlock.isAlive || 
						(checkBlock.type != BLOCK_TYPE_LASER &&
						checkBlock.type != BLOCK_TYPE_CRYSTAL && 
						checkBlock.type != BLOCK_TYPE_GOAL &&
						[checkBlock getAnim] != ANIM_REDBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_GREENBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_BLUEBLOCK_VISIBLE))
					{
						continue;	
					}

					if (laserBlock.y - checkBlock.y == 0 &&
						checkBlock.x > laserBlock.x &&
						checkBlock.x <= (laserBlock.x + zone.size.width))
					{
						zone.size.width = abs((laserBlock.x + TILE_SIZE) - checkBlock.x);
					}
				}

				[laserBlock.damageZones replaceObjectAtIndex:0 withObject:[NSValue valueWithCGRect:zone]];
			}
		}
		else if (block.y - laserBlock.y == 0 && //block is to the left
			block.x < laserBlock.x)
		{
			zone = [[laserBlock.damageZones objectAtIndex:1] CGRectValue];

			if ([Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :laserBlock.x + zone.origin.x - 1 :zone.size.width :laserBlock.y + zone.origin.y :zone.size.height])
			{
				zone.size.width = laserBlock.leftExtent;
				zone.origin.x = -zone.size.width;

				for (j = 0; j < blockIndex; j++)
				{
					Block *checkBlock = [blockQueue objectAtIndex:j];

					if (!checkBlock.isAlive || 
						(checkBlock.type != BLOCK_TYPE_CRYSTAL && 
						checkBlock.type != BLOCK_TYPE_LASER &&
						checkBlock.type != BLOCK_TYPE_GOAL &&
						[checkBlock getAnim] != ANIM_REDBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_GREENBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_BLUEBLOCK_VISIBLE))
					{
						continue;	
					}

					if (laserBlock.y - checkBlock.y == 0 &&
						checkBlock.x < laserBlock.x &&
						checkBlock.x >= (laserBlock.x + zone.origin.x))
					{
						zone.size.width = abs(checkBlock.x + TILE_SIZE - laserBlock.x);
						zone.origin.x = -zone.size.width;
					}
				}

				zone.origin.x = -zone.size.width;
				[laserBlock.damageZones replaceObjectAtIndex:1 withObject:[NSValue valueWithCGRect:zone]];
			}
		}
		else if (block.x - laserBlock.x == 0 && //block is above
				block.y < laserBlock.y)
		{
			zone = [[laserBlock.damageZones objectAtIndex:2] CGRectValue];

			if ([Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width :laserBlock.y + zone.origin.y - 1 :zone.size.height])
			{
				zone.size.height = laserBlock.upExtent;
				zone.origin.y = -zone.size.height;

				for (j = 0; j < blockIndex; j++)
				{
					Block *checkBlock = [blockQueue objectAtIndex:j];

					if (!checkBlock.isAlive || 
						(checkBlock.type != BLOCK_TYPE_CRYSTAL && 
						checkBlock.type != BLOCK_TYPE_LASER &&
						checkBlock.type != BLOCK_TYPE_GOAL &&
						[checkBlock getAnim] != ANIM_REDBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_GREENBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_BLUEBLOCK_VISIBLE))
					{
						continue;	
					}

					if (laserBlock.x - checkBlock.x == 0 &&
						checkBlock.y < laserBlock.y &&
						checkBlock.y >= (laserBlock.y + zone.origin.y))
					{
						zone.size.height = abs(laserBlock.y - (checkBlock.y + TILE_SIZE));
						zone.origin.y = -zone.size.height;
					}
				}

				zone.origin.y = -zone.size.height;
				[laserBlock.damageZones replaceObjectAtIndex:2 withObject:[NSValue valueWithCGRect:zone]];
			}
		}
		else if (block.x - laserBlock.x == 0 && //block is below
				block.y > laserBlock.y)
		{
			zone = [[laserBlock.damageZones objectAtIndex:3] CGRectValue];

			if ([Utils boxInBox:block.x :TILE_SIZE :block.y :TILE_SIZE :laserBlock.x + zone.origin.x :zone.size.width :laserBlock.y + zone.origin.y :zone.size.height + 1])
			{
				zone.size.height = laserBlock.downExtent;

				for (j = 0; j < blockIndex; j++)
				{
					Block *checkBlock = [blockQueue objectAtIndex:j];

					if (!checkBlock.isAlive || 
						(checkBlock.type != BLOCK_TYPE_CRYSTAL && 
						checkBlock.type != BLOCK_TYPE_LASER &&
						checkBlock.type != BLOCK_TYPE_GOAL &&
						[checkBlock getAnim] != ANIM_REDBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_GREENBLOCK_VISIBLE &&
						[checkBlock getAnim] != ANIM_BLUEBLOCK_VISIBLE))
					{
						continue;	
					}

					if (laserBlock.x - checkBlock.x == 0 &&
						checkBlock.y > laserBlock.y &&
						checkBlock.y <= (laserBlock.y + zone.size.height))
					{
						zone.size.height = abs((laserBlock.y + TILE_SIZE) - checkBlock.y);
					}
				}

				[laserBlock.damageZones replaceObjectAtIndex:3 withObject:[NSValue valueWithCGRect:zone]];
			}
		}
	}

	[self setupCrystals];
}

- (void)showIntroBlock :(int)blockType
{
	int imageIndex = 0;

	switch (blockType)
	{
		case BLOCK_TYPE_BLADE:
			imageIndex = INTRO_BLADE;
			break;
		case BLOCK_TYPE_BOMB:	
			imageIndex = INTRO_BOMB;
			break;
		case BLOCK_TYPE_RIGHTCONVEYOR:
		case BLOCK_TYPE_LEFTCONVEYOR:
			imageIndex = INTRO_CONVEYOR;
			break;
		case BLOCK_TYPE_CRYSTAL:
			imageIndex = INTRO_CRYSTAL;
			break;
		case BLOCK_TYPE_DEFAULT:
			imageIndex = INTRO_DEFAULT;
			break;
		case BLOCK_TYPE_FIRE:
			imageIndex = INTRO_FIRE;
			break;
		case BLOCK_TYPE_GUN:
			imageIndex = INTRO_GUN;
			break;
		case BLOCK_TYPE_INVISIBLE:
			imageIndex = INTRO_INVISIBLE;
			break;
		case BLOCK_TYPE_UPDOWN:
		case BLOCK_TYPE_LEFTRIGHT:
			imageIndex = INTRO_LEFTRIGHT;
			break;
		case BLOCK_TYPE_GREENPORTAL:
		case BLOCK_TYPE_BLUEPORTAL:
		case BLOCK_TYPE_REDPORTAL:
			imageIndex = INTRO_PORTAL;
			break;
		case BLOCK_TYPE_MOVINGSPIKES:
			imageIndex = INTRO_SPIKE;
			break;
		case BLOCK_TYPE_SPRINGBOARD:
			imageIndex = INTRO_SPRING;
			break;
		case BLOCK_TYPE_CHECKPOINT:
			imageIndex = INTRO_CHECKPOINT;
			break;
	}

	if (!introBlocks[imageIndex])
	{
		GameButton *button;
		introBlocks[imageIndex] = true;

		if (imageIndex != INTRO_CHECKPOINT)
		{
			[self setImageView:@"gameOverAndBlocksBG.png" :imageView :INT_MAX :INT_MAX];
			[self setImageView:[blockIntroPaths objectAtIndex:imageIndex] :imageSubView :INT_MAX :40];
		}
		else
		{
			[self setImageView:@"messageWindow.png" :imageView :INT_MAX :INT_MAX];
		}

		[gameState addObject:[NSNumber numberWithInteger:STATE_CHECKPOINT_INTRO]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_PRINT_INTRO_MESSAGE]];
		[message release];
		message = [[NSString alloc] initWithFormat:@"%@", [blockText objectAtIndex:imageIndex]];
		textIndex = 0;
		currentMessageField = mainMessageField;
		mainMessageField.text = @"";
		mainMessageField.hidden = NO;
		hudView.hidden = YES;
		timerField.hidden = YES;
		currentBlock.drawBlock = false;
		blockNumField.hidden = YES;

		button = [buttonsArray objectAtIndex:BUTTON_NEXT_MAP_INDEX];
		button.isActive = false;
		button = [buttonsArray objectAtIndex:BUTTON_SELF_DESTRUCT_INDEX];
		button.isActive = false;
		button = [buttonsArray objectAtIndex:BUTTON_PREV_BLOCK_INDEX];
		button.isActive = false;
		button = [buttonsArray objectAtIndex:BUTTON_NEXT_BLOCK_INDEX];
		button.isActive = false;
		[self drawGame];
	}
}

- (void)setImageView:(NSString *)imagePath :(UIImageView *)view :(int)x :(int)y
{
	view.image = [UIImage imageNamed:imagePath];
	CGRect tempFrame = view.frame;
	tempFrame.size = view.image.size;
	tempFrame.origin.x = x;
	tempFrame.origin.y = y;

	if (x == INT_MAX)
	{
		tempFrame.origin.x = (screenWidth - tempFrame.size.width) / 2;
	}
	if (y == INT_MAX)
	{
		tempFrame.origin.y = (screenHeight - tempFrame.size.height) / 2;
	}

	view.frame = tempFrame;
	view.hidden = NO;
}

- (void)setupMessage:(NSString *)msg :(UITextView *)view
{
	[message release];
	message = [[NSString alloc] initWithFormat:@"%@", msg];
	textIndex = 0;
	currentMessageField = view;
	currentMessageField.hidden = NO;
	currentMessageField.text = @"";

	if ([self getGameState] != STATE_PRINT_INTRO_MESSAGE)
	{
		[gameState addObject:[NSNumber numberWithInteger:STATE_PRINT_INTRO_MESSAGE]];
	}
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

- (void)copyBlock:(Block *)dest :(Block *)src
{
	dest.x = src.x;
	dest.y = src.y;
	dest.timerMax = src.timerMax;
	dest.timer = src.timer;
	dest.heading.x = src.heading.x;
	dest.heading.y = src.heading.y;
	dest.stateIndex = src.stateIndex;
	dest.isAlive = src.isAlive;
	dest.animState = src.animState;
	dest.animFinished = src.animFinished;
	dest.loopType = src.loopType;
	dest.isVisible = src.isVisible;
	dest.health = src.health;
	dest.currentFrame = src.currentFrame;
	dest.startFrame = src.startFrame;
	dest.endFrame = src.endFrame;
	dest.numLasers = src.numLasers;
}

//Button listeners! 
- (void)leftButtonDown
{
	player.state |= PLAYER_LEFT;
	player.state &= ~PLAYER_RIGHT;
}

- (void)leftButtonUp
{
	player.state &= ~PLAYER_LEFT;
}

- (void)rightButtonDown
{
	player.state |= PLAYER_RIGHT;
	player.state &= ~PLAYER_LEFT;
}

- (void)rightButtonUp
{
	player.state &= ~PLAYER_RIGHT;
}

- (void)upButtonDown
{
	if (!(player.state & PLAYER_FALL) && !(player.state & PLAYER_SPRING) && !canJump)
	{
		player.state |= PLAYER_JUMP;
		canJump |= (JUMP_IN_AIR | JUMP_BUTTON_DOWN);
		[self playSound:SOUND_JUMP];
	}
	else
	{
		canJump |= JUMP_BUTTON_DOWN;
	}
}

- (void)upButtonUp
{
	if (!(player.state & PLAYER_SPRING))
	{
		player.state &= ~PLAYER_JUMP;
		player.jump = 0;
		canJump &= ~JUMP_BUTTON_DOWN;
	}
}

- (void)downButtonDown
{
	player.state |= PLAYER_ACTION;
}

- (void)downButtonUp
{
	player.state &= ~PLAYER_ACTION;
}

- (void)setupButtons
{
	startButton = [UIButton buttonWithType:UIButtonTypeCustom];
	startButton.frame = CGRectMake(165, 255, 151, 52);
	[startButton addTarget:self action:@selector(startButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[startButton setImage:[UIImage imageNamed:@"btn_MainMenuStart.png"] forState:UIControlStateNormal];
	[startButton setImage:[UIImage imageNamed:@"btn_MainMenuStartPressed.png"] forState:UIControlStateHighlighted];
	startButton.hidden = YES;

	editorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	editorButton.frame = CGRectMake(37, 268, 97, 32);
	[editorButton addTarget:self action:@selector(editorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[editorButton setImage:[UIImage imageNamed:@"btn_MainMenuEditor.png"] forState:UIControlStateNormal];
	[editorButton setImage:[UIImage imageNamed:@"btn_MainMenuEditorPressed.png"] forState:UIControlStateHighlighted];
	editorButton.hidden = YES;

	creditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creditsButton.frame = CGRectMake(338, 268, 112, 32);
	[creditsButton addTarget:self action:@selector(creditsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[creditsButton setImage:[UIImage imageNamed:@"btn_MainMenuCredits.png"] forState:UIControlStateNormal];
	[creditsButton setImage:[UIImage imageNamed:@"btn_MainMenuCreditsPressed.png"] forState:UIControlStateHighlighted];
	creditsButton.hidden = YES;

	menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	menuButton.frame = CGRectMake(0, 288, 65, 32);
	[menuButton addTarget:self action:@selector(menuButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[menuButton setImage:[UIImage imageNamed:@"btn_LevelSelectMenu.png"] forState:UIControlStateNormal];
	[menuButton setImage:[UIImage imageNamed:@"btn_LevelSelectMenuPressed.png"] forState:UIControlStateHighlighted];
	menuButton.hidden = YES;

	userLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	userLevelsButton.frame = CGRectMake(307, 288, 173, 32);
	[userLevelsButton addTarget:self action:@selector(userLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[userLevelsButton setImage:[UIImage imageNamed:@"btn_LevelSelectLoadUser.png"] forState:UIControlStateNormal];
	[userLevelsButton setImage:[UIImage imageNamed:@"btn_LevelSelectLoadUserPressed.png"] forState:UIControlStateHighlighted];
	userLevelsButton.hidden = YES;

	backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0, 288, 65, 32);
	[backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[backButton setImage:[UIImage imageNamed:@"btn_LevelSelectBack.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"btn_LevelSelectBackPressed.png"] forState:UIControlStateHighlighted];
	backButton.hidden = YES;

	okConfigButton = [UIButton buttonWithType:UIButtonTypeCustom];
	okConfigButton.frame = CGRectMake(0, 0, 65, 32);
	[okConfigButton addTarget:self action:@selector(okConfigButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[okConfigButton setImage:[UIImage imageNamed:@"btn_OK.png"] forState:UIControlStateNormal];
	[okConfigButton setImage:[UIImage imageNamed:@"btn_OKPressed.png"] forState:UIControlStateHighlighted];
	okConfigButton.hidden = YES;

	defaultConfigButton = [UIButton buttonWithType:UIButtonTypeCustom];
	defaultConfigButton.frame = CGRectMake(screenWidth / 2 - 42, 0, 84, 32);
	[defaultConfigButton addTarget:self action:@selector(defaultConfigButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[defaultConfigButton setImage:[UIImage imageNamed:@"btn_Default.png"] forState:UIControlStateNormal];
	[defaultConfigButton setImage:[UIImage imageNamed:@"btn_DefaultPressed.png"] forState:UIControlStateHighlighted];
	defaultConfigButton.hidden = YES;

	ratingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ratingButton.frame = CGRectMake(394, 210, 84, 32);
	[ratingButton addTarget:self action:@selector(ratingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[ratingButton setImage:[UIImage imageNamed:@"btn_Rate.png"] forState:UIControlStateNormal];
	[ratingButton setImage:[UIImage imageNamed:@"btn_RatePressed.png"] forState:UIControlStateHighlighted];
	ratingButton.hidden = YES;

	okButton = [UIButton buttonWithType:UIButtonTypeCustom];
	okButton.frame = CGRectMake(0, 288, 65, 32);
	[okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[okButton setImage:[UIImage imageNamed:@"btn_OK.png"] forState:UIControlStateNormal];
	[okButton setImage:[UIImage imageNamed:@"btn_OKPressed.png"] forState:UIControlStateHighlighted];
	okButton.hidden = YES;

	cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(screenWidth - 84, 288, 84, 32);
	[cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setImage:[UIImage imageNamed:@"btn_Cancel.png"] forState:UIControlStateNormal];
	[cancelButton setImage:[UIImage imageNamed:@"btn_CancelPressed.png"] forState:UIControlStateHighlighted];
	cancelButton.hidden = YES;

	loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
	loginButton.frame = CGRectMake(0, 288, 65, 32);
	[loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[loginButton setImage:[UIImage imageNamed:@"btn_Login.png"] forState:UIControlStateNormal];
	[loginButton setImage:[UIImage imageNamed:@"btn_LoginPressed.png"] forState:UIControlStateHighlighted];
	loginButton.hidden = YES;

	registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	registerButton.frame = CGRectMake(screenWidth / 2 - 55, 288, 101, 32);
	[registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[registerButton setImage:[UIImage imageNamed:@"btn_Register.png"] forState:UIControlStateNormal];
	[registerButton setImage:[UIImage imageNamed:@"btn_RegisterPressed.png"] forState:UIControlStateHighlighted];
	registerButton.hidden = YES;

	searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	searchButton.frame = CGRectMake(397, 288, 83, 32);
	[searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[searchButton setImage:[UIImage imageNamed:@"btn_LevelSelectSearch.png"] forState:UIControlStateNormal];
	[searchButton setImage:[UIImage imageNamed:@"btn_LevelSelectSearchPressed.png"] forState:UIControlStateHighlighted];
	searchButton.hidden = YES;

	prevSortButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevSortButton.frame = CGRectMake(255, 48, 32, 32);
	[prevSortButton addTarget:self action:@selector(prevSortButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[prevSortButton setImage:[UIImage imageNamed:@"btn_ArrowPrev.png"] forState:UIControlStateNormal];
	[prevSortButton setImage:[UIImage imageNamed:@"btn_ArrowPrevPressed.png"] forState:UIControlStateHighlighted];
	prevSortButton.hidden = YES;

	nextSortButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextSortButton.frame = CGRectMake(415, 48,  32, 32);
	[nextSortButton addTarget:self action:@selector(nextSortButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextSortButton setImage:[UIImage imageNamed:@"btn_ArrowNext.png"] forState:UIControlStateNormal];
	[nextSortButton setImage:[UIImage imageNamed:@"btn_ArrowNextPressed.png"] forState:UIControlStateHighlighted];
	nextSortButton.hidden = YES;

	prevFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevFilterButton.frame = CGRectMake(255, 127, 32, 32);
	[prevFilterButton addTarget:self action:@selector(prevFilterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[prevFilterButton setImage:[UIImage imageNamed:@"btn_ArrowPrev.png"] forState:UIControlStateNormal];
	[prevFilterButton setImage:[UIImage imageNamed:@"btn_ArrowPrevPressed.png"] forState:UIControlStateHighlighted];
	prevFilterButton.hidden = YES;

	nextFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextFilterButton.frame = CGRectMake(415, 127,  32, 32);
	[nextFilterButton addTarget:self action:@selector(nextFilterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextFilterButton setImage:[UIImage imageNamed:@"btn_ArrowNext.png"] forState:UIControlStateNormal];
	[nextFilterButton setImage:[UIImage imageNamed:@"btn_ArrowNextPressed.png"] forState:UIControlStateHighlighted];
	nextFilterButton.hidden = YES;

	prevDirectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevDirectButton.frame = CGRectMake(255, 227, 32, 32);
	[prevDirectButton addTarget:self action:@selector(prevDirectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[prevDirectButton setImage:[UIImage imageNamed:@"btn_ArrowPrev.png"] forState:UIControlStateNormal];
	[prevDirectButton setImage:[UIImage imageNamed:@"btn_ArrowPrevPressed.png"] forState:UIControlStateHighlighted];
	prevDirectButton.hidden = YES;

	nextDirectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextDirectButton.frame = CGRectMake(415, 227,  32, 32);
	[nextDirectButton addTarget:self action:@selector(nextDirectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextDirectButton setImage:[UIImage imageNamed:@"btn_ArrowNext.png"] forState:UIControlStateNormal];
	[nextDirectButton setImage:[UIImage imageNamed:@"btn_ArrowNextPressed.png"] forState:UIControlStateHighlighted];
	nextDirectButton.hidden = YES;

	prevUserLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevUserLevelsButton.frame = CGRectMake(25, 246,  32, 32);
	[prevUserLevelsButton addTarget:self action:@selector(prevUserLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[prevUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowPrev.png"] forState:UIControlStateNormal];
	[prevUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowPrevPressed.png"] forState:UIControlStateHighlighted];
	prevUserLevelsButton.hidden = YES;

	nextUserLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextUserLevelsButton.frame = CGRectMake(423, 246,  32, 32);
	[nextUserLevelsButton addTarget:self action:@selector(nextUserLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowNext.png"] forState:UIControlStateNormal];
	[nextUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowNextPressed.png"] forState:UIControlStateHighlighted];
	nextUserLevelsButton.hidden = YES;

	firstUserLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	firstUserLevelsButton.frame = CGRectMake(89, 246,  32, 32);
	[firstUserLevelsButton addTarget:self action:@selector(firstUserLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[firstUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowFirst.png"] forState:UIControlStateNormal];
	[firstUserLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowFirstPressed.png"] forState:UIControlStateHighlighted];
	firstUserLevelsButton.hidden = YES;

	prevLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prevLevelsButton.frame = CGRectMake(25, 246,  32, 32);
	[prevLevelsButton addTarget:self action:@selector(prevLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[prevLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowPrev.png"] forState:UIControlStateNormal];
	[prevLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowPrevPressed.png"] forState:UIControlStateHighlighted];
	prevLevelsButton.hidden = YES;

	nextLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextLevelsButton.frame = CGRectMake(423, 246,  32, 32);
	[nextLevelsButton addTarget:self action:@selector(nextLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowNext.png"] forState:UIControlStateNormal];
	[nextLevelsButton setImage:[UIImage imageNamed:@"btn_ArrowNextPressed.png"] forState:UIControlStateHighlighted];
	nextLevelsButton.hidden = YES;

	returnToEditorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnToEditorButton.frame = CGRectMake((screenWidth - 84) / 2, screenHeight - 32, 83, 32);
	[returnToEditorButton addTarget:self action:@selector(returnToEditorButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[returnToEditorButton setImage:[UIImage imageNamed:@"btn_Editor.png"] forState:UIControlStateNormal];
	[returnToEditorButton setImage:[UIImage imageNamed:@"btn_EditorPressed.png"] forState:UIControlStateHighlighted];
	returnToEditorButton.hidden = YES;

	retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	retryButton.frame = CGRectMake(0, screenHeight - 32, 74, 32);
	[retryButton addTarget:self action:@selector(retryButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[retryButton setImage:[UIImage imageNamed:@"btn_Retry.png"] forState:UIControlStateNormal];
	[retryButton setImage:[UIImage imageNamed:@"btn_RetryPressed.png"] forState:UIControlStateHighlighted];
	retryButton.hidden = YES;

	returnToLevelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnToLevelsButton.frame = CGRectMake((screenWidth - 84) / 2, screenHeight - 32, 83, 32);
	[returnToLevelsButton addTarget:self action:@selector(returnToLevelsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[returnToLevelsButton setImage:[UIImage imageNamed:@"btn_Levels.png"] forState:UIControlStateNormal];
	[returnToLevelsButton setImage:[UIImage imageNamed:@"btn_LevelsPressed.png"] forState:UIControlStateHighlighted];
	returnToLevelsButton.hidden = YES;

	nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(screenWidth - 65, screenHeight - 32, 65, 32);
	[nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[nextButton setImage:[UIImage imageNamed:@"btn_Next.png"] forState:UIControlStateNormal];
	[nextButton setImage:[UIImage imageNamed:@"btn_NextPressed.png"] forState:UIControlStateHighlighted];
	nextButton.hidden = YES;

	leftDifficultyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftDifficultyButton.frame = CGRectMake(57, 227, 32, 32);
	[leftDifficultyButton addTarget:self action:@selector(leftDifficultyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftDifficultyButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftDifficultyButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	leftDifficultyButton.hidden = YES;

	rightDifficultyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightDifficultyButton.frame = CGRectMake(170, 227, 32, 32);
	[rightDifficultyButton addTarget:self action:@selector(rightDifficultyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightDifficultyButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightDifficultyButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	rightDifficultyButton.hidden = YES;

	leftGoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftGoldButton.frame = CGRectMake(280, 248, 32, 32);
	[leftGoldButton addTarget:self action:@selector(leftGoldButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftGoldButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftGoldButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	leftGoldButton.hidden = YES;

	rightGoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightGoldButton.frame = CGRectMake(386, 248, 32, 32);
	[rightGoldButton addTarget:self action:@selector(rightGoldButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightGoldButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightGoldButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	rightGoldButton.hidden = YES;

	leftSilverButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftSilverButton.frame = CGRectMake(280, 214, 32, 32);
	[leftSilverButton addTarget:self action:@selector(leftSilverButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftSilverButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftSilverButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	leftSilverButton.hidden = YES;

	rightSilverButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightSilverButton.frame = CGRectMake(386, 214, 32, 32);
	[rightSilverButton addTarget:self action:@selector(rightSilverButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightSilverButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightSilverButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	rightSilverButton.hidden = YES;

	leftBronzeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBronzeButton.frame = CGRectMake(280, 180, 32, 32);
	[leftBronzeButton addTarget:self action:@selector(leftBronzeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftBronzeButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftBronzeButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	leftBronzeButton.hidden = YES;

	rightBronzeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightBronzeButton.frame = CGRectMake(386, 180, 32, 32);
	[rightBronzeButton addTarget:self action:@selector(rightBronzeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightBronzeButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightBronzeButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	rightBronzeButton.hidden = YES;

	leftBGTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftBGTypeButton.frame = CGRectMake(136, 242, 32, 32);
	[leftBGTypeButton addTarget:self action:@selector(leftBGTypeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[leftBGTypeButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmall.png"] forState:UIControlStateNormal];
	[leftBGTypeButton setImage:[UIImage imageNamed:@"btn_ArrowPrevSmallPressed.png"] forState:UIControlStateHighlighted];
	leftBGTypeButton.hidden = YES;

	rightBGTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightBGTypeButton.frame = CGRectMake(310, 242, 32, 32);
	[rightBGTypeButton addTarget:self action:@selector(rightBGTypeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[rightBGTypeButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmall.png"] forState:UIControlStateNormal];
	[rightBGTypeButton setImage:[UIImage imageNamed:@"btn_ArrowNextSmallPressed.png"] forState:UIControlStateHighlighted];
	rightBGTypeButton.hidden = YES;

	oneStar = [UIButton buttonWithType:UIButtonTypeCustom];
	oneStar.frame = CGRectMake(screenWidth / 2 - 115, screenHeight / 2 - 17, 34, 34);
	[oneStar addTarget:self action:@selector(oneStarPressed) forControlEvents:UIControlEventTouchUpInside];
	[oneStar setImage:[UIImage imageNamed:@"RatingButtonOneStar.png"] forState:UIControlStateNormal];
	[oneStar setImage:[UIImage imageNamed:@"RatingButtonOneStar_OVER.png"] forState:UIControlStateHighlighted];
	oneStar.hidden = YES;

	twoStar = [UIButton buttonWithType:UIButtonTypeCustom];
	twoStar.frame = CGRectMake(screenWidth / 2 - 67, screenHeight / 2 - 17, 34, 34);
	[twoStar addTarget:self action:@selector(twoStarPressed) forControlEvents:UIControlEventTouchUpInside];
	[twoStar setImage:[UIImage imageNamed:@"RatingButtonTwoStar.png"] forState:UIControlStateNormal];
	[twoStar setImage:[UIImage imageNamed:@"RatingButtonTwoStar_OVER.png"] forState:UIControlStateHighlighted];
	twoStar.hidden = YES;

	threeStar = [UIButton buttonWithType:UIButtonTypeCustom];
	threeStar.frame = CGRectMake(screenWidth / 2 - 17, screenHeight / 2 - 17, 34, 34);
	[threeStar addTarget:self action:@selector(threeStarPressed) forControlEvents:UIControlEventTouchUpInside];
	[threeStar setImage:[UIImage imageNamed:@"RatingButtonThreeStar.png"] forState:UIControlStateNormal];
	[threeStar setImage:[UIImage imageNamed:@"RatingButtonThreeStar_OVER.png"] forState:UIControlStateHighlighted];
	threeStar.hidden = YES;

	fourStar = [UIButton buttonWithType:UIButtonTypeCustom];
	fourStar.frame = CGRectMake(screenWidth / 2 + 32, screenHeight / 2 - 17, 34, 34);
	[fourStar addTarget:self action:@selector(fourStarPressed) forControlEvents:UIControlEventTouchUpInside];
	[fourStar setImage:[UIImage imageNamed:@"RatingButtonFourStar.png"] forState:UIControlStateNormal];
	[fourStar setImage:[UIImage imageNamed:@"RatingButtonFourStar_OVER.png"] forState:UIControlStateHighlighted];
	fourStar.hidden = YES;

	fiveStar = [UIButton buttonWithType:UIButtonTypeCustom];
	fiveStar.frame = CGRectMake(screenWidth / 2 + 81, screenHeight / 2 - 17, 34, 34);
	[fiveStar addTarget:self action:@selector(fiveStarPressed) forControlEvents:UIControlEventTouchUpInside];
	[fiveStar setImage:[UIImage imageNamed:@"RatingButtonFiveStar.png"] forState:UIControlStateNormal];
	[fiveStar setImage:[UIImage imageNamed:@"RatingButtonFiveStar_OVER.png"] forState:UIControlStateHighlighted];
	fiveStar.hidden = YES;

	pauseRetryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pauseRetryButton.frame = CGRectMake(screenWidth / 2 - 112, screenHeight / 2 - 16, 224, 32);
	[pauseRetryButton addTarget:self action:@selector(pauseMenuRetryPressed) forControlEvents:UIControlEventTouchUpInside];
	[pauseRetryButton setImage:[UIImage imageNamed:@"btn_PauseMenuRestart.png"] forState:UIControlStateNormal];
	[pauseRetryButton setImage:[UIImage imageNamed:@"btn_PauseMenuRestartPressed.png"] forState:UIControlStateHighlighted];
	pauseRetryButton.hidden = YES;

	pauseExitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pauseExitButton.frame = CGRectMake(screenWidth / 2 - 112, screenHeight / 2 + 16, 224, 32);
	[pauseExitButton addTarget:self action:@selector(pauseMenuExitPressed) forControlEvents:UIControlEventTouchUpInside];
	[pauseExitButton setImage:[UIImage imageNamed:@"btn_PauseMenuExit.png"] forState:UIControlStateNormal];
	[pauseExitButton setImage:[UIImage imageNamed:@"btn_PauseMenuExitPressed.png"] forState:UIControlStateHighlighted];
	pauseExitButton.hidden = YES;

	pauseConfigButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pauseConfigButton.frame = CGRectMake(screenWidth / 2 - 112, screenHeight / 2 + 48, 224, 32);
	[pauseConfigButton addTarget:self action:@selector(pauseMenuConfigPressed) forControlEvents:UIControlEventTouchUpInside];
	[pauseConfigButton setImage:[UIImage imageNamed:@"btn_PauseMenuConfig.png"] forState:UIControlStateNormal];
	[pauseConfigButton setImage:[UIImage imageNamed:@"btn_PauseMenuConfigPressed.png"] forState:UIControlStateHighlighted];
	pauseConfigButton.hidden = YES;

	pauseReturnButton = [UIButton buttonWithType:UIButtonTypeCustom];
	pauseReturnButton.frame = CGRectMake(screenWidth / 2 - 112, screenHeight / 2 + 80, 224, 32);
	[pauseReturnButton addTarget:self action:@selector(pauseMenuReturnPressed) forControlEvents:UIControlEventTouchUpInside];
	[pauseReturnButton setImage:[UIImage imageNamed:@"btn_PauseMenuResume.png"] forState:UIControlStateNormal];
	[pauseReturnButton setImage:[UIImage imageNamed:@"btn_PauseMenuResumePressed.png"] forState:UIControlStateHighlighted];
	pauseReturnButton.hidden = YES;

	[self.view addSubview:startButton];
	[self.view addSubview:creditsButton];
	[self.view addSubview:editorButton];
	[self.view addSubview:menuButton];
	[self.view addSubview:userLevelsButton];
	[self.view addSubview:backButton];
	[self.view addSubview:searchButton];
	[self.view addSubview:prevSortButton];
	[self.view addSubview:nextSortButton];
	[self.view addSubview:prevFilterButton];
	[self.view addSubview:nextFilterButton];
	[self.view addSubview:prevDirectButton];
	[self.view addSubview:nextDirectButton];
	[self.view addSubview:prevUserLevelsButton];
	[self.view addSubview:nextUserLevelsButton];
	[self.view addSubview:firstUserLevelsButton];
	[self.view addSubview:prevLevelsButton];
	[self.view addSubview:nextLevelsButton];
	[self.view addSubview:returnToEditorButton];
	[self.view addSubview:retryButton];
	[self.view addSubview:returnToLevelsButton];
	[self.view addSubview:nextButton];
	[self.view addSubview:leftDifficultyButton];
	[self.view addSubview:rightDifficultyButton];
	[self.view addSubview:leftGoldButton];
	[self.view addSubview:rightGoldButton];
	[self.view addSubview:leftSilverButton];
	[self.view addSubview:rightSilverButton];
	[self.view addSubview:leftBronzeButton];
	[self.view addSubview:rightBronzeButton];
	[self.view addSubview:leftBGTypeButton];
	[self.view addSubview:rightBGTypeButton];
	[self.view addSubview:okButton];
	[self.view addSubview:ratingButton];
	[self.view addSubview:cancelButton];
	[self.view addSubview:okConfigButton];
	[self.view addSubview:defaultConfigButton];
	[self.view addSubview:loginButton];
	[self.view addSubview:registerButton];
	[self.view addSubview:oneStar];
	[self.view addSubview:twoStar];
	[self.view addSubview:threeStar];
	[self.view addSubview:fourStar];
	[self.view addSubview:fiveStar];
	[self.view addSubview:pauseReturnButton];
	[self.view addSubview:pauseExitButton];
	[self.view addSubview:pauseConfigButton];
	[self.view addSubview:pauseRetryButton];
}

- (void)startButtonPressed
{
	[self playSound:SOUND_BUTTON];
	currentLevel = 0;

	gameType = GAME_TYPE_STOCK_LEVEL;

	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_SELECT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_LEVEL_SELECT_ELEMENTS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
}

- (void)menuButtonPressed
{
	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_LEVEL_SELECT_ELEMENTS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];

	[self playSound:SOUND_CLICK];
}

- (void)userLevelsButtonPressed
{
	[self playSound:SOUND_BUTTON];

	[gameState addObject:[NSNumber numberWithInteger:STATE_USER_LEVELS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_USER_LEVEL_ELEMENTS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
}

- (void)defaultConfigButtonPressed
{
	[self playSound:SOUND_CLICK];

	CGRect tempBounds;
	GameButton *button;

	//left button
	button = [buttonsArray objectAtIndex:BUTTON_LEFT_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = 0;
	tempBounds.origin.y = screenHeight - 56;
	button.bounds = tempBounds;

	//right button
	button = [buttonsArray objectAtIndex:BUTTON_RIGHT_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = 88;
	tempBounds.origin.y = screenHeight - 56;
	button.bounds = tempBounds;

	//down button
	button = [buttonsArray objectAtIndex:BUTTON_DOWN_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = screenWidth - 176;;
	tempBounds.origin.y = screenHeight - 56;
	button.bounds = tempBounds;

	//up button
	button = [buttonsArray objectAtIndex:BUTTON_UP_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = screenWidth - 88;;
	tempBounds.origin.y = screenHeight - 56;
	button.bounds = tempBounds;

	//block buttons
	button = [buttonsArray objectAtIndex:BUTTON_BLOCKLEFT_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = 54;
	tempBounds.origin.y = screenHeight - 120;
	button.bounds = tempBounds;

	button = [buttonsArray objectAtIndex:BUTTON_BLOCKRIGHT_INDEX];
	tempBounds = button.bounds;
	tempBounds.origin.x = screenWidth - 116;
	tempBounds.origin.y = screenHeight - 120;
	button.bounds = tempBounds;
}

- (void)okConfigButtonPressed
{
	int i;

	[self playSound:SOUND_CLICK];
	[gameState removeLastObject];
	[self setImageView:@"UI_HUD.png" :hudView :INT_MAX :INT_MAX];

	okConfigButton.hidden = YES;
	defaultConfigButton.hidden = YES;

	timerField.hidden = NO;

	if (blocksAvailable[blocksAvailableIndex])
	{
		blockNumField.hidden = NO;
	}

	[self selectButtonGroup:BUTTON_GROUP_PLAY];

	for (i = 0; i < 6; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];
		buttonPos[i * 2] = (int)button.bounds.origin.x;
		buttonPos[i * 2 + 1] = (int)button.bounds.origin.y;

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_UP];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_UP];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_UP];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_UP];
				break;
			case BUTTON_TYPE_BLOCK:
				[button setAnim:ANIM_BLOCK_BUTTON];
				break;
		}
	}

	self.view.multipleTouchEnabled = true;
	[self saveProgress];
}

- (void)okButtonPressed
{
	helpSubView.hidden = YES;
	mainMessageField.hidden = YES;
	okButton.hidden = YES;
	cancelButton.hidden = YES;

	if (okCancelState != OK_CANCEL_STATE_REGISTER)
	{
		[gameState removeLastObject];
	}

	[self playSound:SOUND_CLICK];

	switch (okCancelState)
	{
		case OK_CANCEL_STATE_SAVE:
			[self saveEditorFile];
			break;
		case OK_CANCEL_STATE_NEW:
			[self resetMap];
			break;
		case OK_CANCEL_STATE_QUIT:
			[gameState removeAllObjects];
			[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_MAIN_MENU]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_EDITOR]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
			break;
		case OK_CANCEL_STATE_REGISTER:
			okButton.hidden = YES;
			cancelButton.hidden = YES;
			[self validateRegistration];
			break;
		case OK_CANCEL_STATE_TWITTER:
		{
			[twitView setInitialText:[NSString stringWithFormat:@"Hey, @GreenPixelDev! Please consider level %d for the first update! #ios #blockhopper", levelID]];
			[self presentModalViewController:twitView animated:YES];
			break;
		}
	}
}

- (void)cancelButtonPressed
{
	if (connectionInUse)
	{
		return;
	}

	helpSubView.hidden = YES;
	mainMessageField.hidden = YES;
	okButton.hidden = YES;
	cancelButton.hidden = YES;
	loginButton.hidden = YES;
	registerButton.hidden = YES;
	usernameField.hidden = YES;
	passwordField.hidden = YES;
	registerUsernameField.hidden = YES;
	registerEmailField.hidden = YES;
	registerPasswordField1.hidden = YES;
	registerPasswordField2.hidden = YES;

	if ([self getGameState] == STATE_LOGIN)
	{
		[self setImageView:@"editorSelection.png" :imageSubView :-32 :0];
	}

	[gameState removeLastObject];

	[self playSound:SOUND_CLICK];
}

- (void)loginButtonPressed
{
	connectionInUse = true;
	connectionType = CONNECTION_TYPE_LOGIN_USER;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/login.php?pwd=%@&uname=%@", [passwordField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [usernameField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
	[request setHTTPMethod:@"GET"];
	[connection release];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
	timeoutFrames = 0;

	[username release];
	username = [[NSString alloc] initWithFormat:@"%@", usernameField.text];
	[password release];
	password = [[NSString alloc] initWithFormat:@"%@", passwordField.text];

	loginButton.hidden = YES;
	registerButton.hidden = YES;
	cancelButton.hidden = YES;
	usernameField.hidden = YES;
	passwordField.hidden = YES;

	[self playSound:SOUND_BUTTON];
}

- (void)registerButtonPressed
{
	[self setImageView:@"UI_Register.png" :imageSubView :INT_MAX :INT_MAX];
	loginButton.hidden = YES;
	registerButton.hidden = YES;
	usernameField.hidden = YES;
	passwordField.hidden = YES;

	registerEmailField.hidden = NO;
	registerUsernameField.hidden = NO;
	registerPasswordField1.hidden = NO;
	registerPasswordField2.hidden = NO;

	okButton.hidden = NO;
	okCancelState = OK_CANCEL_STATE_REGISTER;

	[self playSound:SOUND_BUTTON];
}

- (void)backButtonPressed
{
	int i;

	connectionInUse = false;
	bitView.hidden = YES;
	[self playSound:SOUND_CLICK];

	switch ([self getGameState])
	{
		case STATE_USER_LEVELS:
			[gameState removeLastObject];
			[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_SELECT]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_USER_LEVEL_ELEMENTS]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
			break;
		case STATE_USER_LEVELS_SEARCH:
		{
			BOOL error = false;

			if (!directIndex)
			{
				if (directInputField.text)
				{
					const char *c = [directInputField.text UTF8String];

					for (i = 0; i < [directInputField.text length]; i++)
					{
						if (!isdigit(c[i]))
						{
							error = true;
							break;
						}
					}
				}
			}

			if (error)
			{
				NSString *errorString = @"The Level ID can only contain numbers.";

				[self playSound:SOUND_CLICK];
				[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INPUT_ERROR]];
				helpSubView.hidden = NO;
				mainMessageField.text = errorString;
				mainMessageField.hidden = NO;
				currentMessageField = mainMessageField;
				searchButton.hidden = YES;
				backButton.hidden = YES;
				directField.hidden = YES;
				directInputField.hidden = YES;
				prevDirectButton.hidden = YES;
				nextDirectButton.hidden = YES;
			}
			else
			{
				connectionInUse = true;
				connectionType = CONNECTION_TYPE_USER_LEVELS;

				pageNumber = 0;

				NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getuserlevelsiOS.php?filter=%d&sort=%d&page=0&resultsPerPage=%d&directSearch=%@&directSearchType=%d", filterIndex, sortIndex, (MAX_USER_LEVELS + 1), (directInputField.text) ? [directInputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: @"", directInputField.text ? (directIndex + 1) : 0];
				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
				[request setHTTPMethod:@"GET"];

				[connection release];
				connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
				[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
				timeoutFrames = 0;
			}

			break;
		}
		case STATE_EDITOR:
			editorState = editorOldState;
			[self setImageView:@"editorSelection.png" :imageSubView :editorState * 32 :0];
			[self setImageView:@"btn_EditorButtons.png" :imageView :0 :0];
			backButton.hidden = YES;

			for (i = 0; i < MAX_USER_BLOCKS; i++)
			{
				blockAmounts[i].hidden = YES;
			}

			editorGoldTimeField.hidden = YES;
			editorSilverTimeField.hidden = YES;
			editorBronzeTimeField.hidden = YES;
			diffField.hidden = YES;
			diffTextField.hidden = YES;
			leftDifficultyButton.hidden = YES;
			rightDifficultyButton.hidden = YES;
			leftGoldButton.hidden = YES;
			rightGoldButton.hidden = YES;
			leftSilverButton.hidden = YES;
			rightSilverButton.hidden = YES;
			leftBronzeButton.hidden = YES;
			rightBronzeButton.hidden = YES;
			leftBGTypeButton.hidden = YES;
			rightBGTypeButton.hidden = YES;
			editorBGTypeField.hidden = YES;
			editorBGField.hidden = YES;
			gridView.hidden = NO;
			break;
		case STATE_CREDITS:
			[gameState removeLastObject];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_MAIN_MENU]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_CREDITS]];
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
			break;
	}
}

- (void)searchButtonPressed
{
	switch ([self getGameState])
	{
		case STATE_USER_LEVELS:
			prevSortButton.hidden = NO;
			nextSortButton.hidden = NO;
			prevFilterButton.hidden = NO;
			nextFilterButton.hidden = NO;
			prevDirectButton.hidden = NO;
			nextDirectButton.hidden = NO;
			sortField.hidden = NO;
			filterField.hidden = NO;
			directField.hidden = NO;
			directInputField.hidden = NO;

			searchButton.hidden = YES;
			userField1.hidden = YES;
			userField2.hidden = YES;
			userField3.hidden = YES;
			userField4.hidden = YES;

			prevUserLevelsButton.hidden = YES;
			nextUserLevelsButton.hidden = YES;
			firstUserLevelsButton.hidden = YES;
			pageField.hidden = YES;

			sortField.text = [sortText objectAtIndex:sortIndex];
			filterField.text = [filterText objectAtIndex:filterIndex];
			directField.text = [directText objectAtIndex:directIndex];

			[self setImageView:@"UI_LevelSelectUsersSearch.png" :imageView :INT_MAX :INT_MAX];
			[gameState addObject:[NSNumber numberWithInteger:STATE_USER_LEVELS_SEARCH]];
			[self playSound:SOUND_BUTTON];
			break;
	}
}

- (void)creditsButtonPressed
{
	[self playSound:SOUND_BUTTON];

	[gameState addObject:[NSNumber numberWithInteger:STATE_CREDITS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_CREDITS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
}

- (void)editorButtonPressed
{
	[self playSound:SOUND_BUTTON];

	[gameState addObject:[NSNumber numberWithInteger:STATE_EDITOR]];
	if (!showEditorWarning)
	{
		[gameState addObject:[NSNumber numberWithInteger:STATE_EDITOR_POPUP]];
	}
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_EDITOR]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
}

- (void)setupEditor
{
	[mapTiles release];
	mapTiles = [[Image alloc] initWithString:@"userblocks.png"];

	editorBGIndex = 1;
	diffIndex = 0;

	gridView.hidden = NO;

	[self resetMap];
	[self loadEditorFile];
	[self setEditorBG];

	memcpy(undoMap, map, MAP_WIDTH * MAP_HEIGHT * sizeof(int));
	memcpy(undoSpecial, special, MAP_WIDTH * MAP_HEIGHT * sizeof(int));

	[self setImageView:@"btn_EditorButtons.png" :imageView :0 :0];
	[self setImageView:@"editorSelection.png" :imageSubView :0 :0];
	[self setImageView:@"UI_GameGrid.png" :gridView :0 :0];

//	helpSubView.hidden = NO;
//	[self setupMessage:@"Welcome to the editor! Here you can create levels to share with other players! Press The Help Icon [?] for more information on the buttons at the top of the screen. Tap to continue." :mainMessageField];

	startButton.hidden = YES;
	editorButton.hidden = YES;
	creditsButton.hidden = YES;
	ratingButton.hidden = YES;
	fxVolumeView.hidden = YES;
	musicVolumeView.hidden = YES;

	imageSubView.hidden = NO;
	editorState = EDITOR_STATE_SELECTION;
	editorOldState = EDITOR_STATE_SELECTION;
	selectedTile = (1 << TILE_YPOS_SHIFT) | WALL;

	gameType = GAME_TYPE_EDITOR_LEVEL;

	selection = CGRectMake(0, 0, 0, 0);
	copyBounds = CGRectMake(0, 0, 0, 0);
	editorStartX = 0.0f;
	editorStartY = 0.0f;
	drawTileStartX = 0;
	drawTileStartY = 0;
	bgOffsetX = 0;
	bgOffsetY = 0;
	editorButtonsRow = 0;

	[self drawEditor];
}

- (void)prevSortButtonPressed
{
	sortIndex = (sortIndex > 0) ? sortIndex - 1 : [sortText count] - 1;
	sortField.text = [sortText objectAtIndex:sortIndex];
	[self playSound:SOUND_CLICK];
}

- (void)nextSortButtonPressed
{
	sortIndex = (sortIndex < [sortText count] - 1) ? sortIndex + 1 : 0;
	sortField.text = [sortText objectAtIndex:sortIndex];
	[self playSound:SOUND_CLICK];
}

- (void)prevFilterButtonPressed
{
	filterIndex = (filterIndex > 0) ? filterIndex - 1 : [filterText count] - 1;
	filterField.text = [filterText objectAtIndex:filterIndex];
	[self playSound:SOUND_CLICK];
}

- (void)nextFilterButtonPressed
{
	filterIndex = (filterIndex < [filterText count] - 1) ? filterIndex + 1 : 0;
	filterField.text = [filterText objectAtIndex:filterIndex];
	[self playSound:SOUND_CLICK];
}

- (void)prevDirectButtonPressed
{
	directIndex = (directIndex > 0) ? directIndex - 1 : [directText count] - 1;
	directField.text = [directText objectAtIndex:directIndex];
	[self playSound:SOUND_CLICK];
}

- (void)nextDirectButtonPressed
{
	directIndex = (directIndex < [directText count] - 1) ? directIndex + 1 : 0;
	directField.text = [directText objectAtIndex:directIndex];
	[self playSound:SOUND_CLICK];
}

- (void)prevUserLevelsButtonPressed
{
	[self playSound:SOUND_CLICK];

	if (!connectionInUse)
	{
		connectionInUse = true;
		connectionType = CONNECTION_TYPE_USER_LEVELS;

		pageNumber--;

		if (pageNumber < 0)
		{
			pageNumber = 0;
		}	

		NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getuserlevelsiOS.php?filter=%d&sort=%d&page=%d&resultsPerPage=%d&directSearch=%@&directSearchType=%d", filterIndex, sortIndex, pageNumber * MAX_USER_LEVELS, (MAX_USER_LEVELS + 1), directInputField.text ? [directInputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: @"", directInputField.text ? (directIndex + 1) : 0];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
		[connection release];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
		timeoutFrames = 0;
	}
}

- (void)nextUserLevelsButtonPressed
{
	[self playSound:SOUND_CLICK];

	if (!connectionInUse)
	{
		if (userLevelIDs[0] < 0)
		{
			return;
		}

		connectionInUse = true;
		connectionType = CONNECTION_TYPE_USER_LEVELS;

		pageNumber++;

		NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getuserlevelsiOS.php?filter=%d&sort=%d&page=%d&resultsPerPage=%d&directSearch=%@&directSearchType=%d", filterIndex, sortIndex, (pageNumber * MAX_USER_LEVELS), (MAX_USER_LEVELS + 1), directInputField.text ? [directInputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: @"", directInputField.text ? (directIndex + 1) : 0];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
		[connection release];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
		timeoutFrames = 0;
	}
}

- (void)firstUserLevelsButtonPressed
{
	[self playSound:SOUND_CLICK];

	if (!connectionInUse)
	{
		connectionInUse = true;
		connectionType = CONNECTION_TYPE_USER_LEVELS;

		pageNumber = 0;

		NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/getuserlevelsiOS.php?filter=%d&sort=%d&page=%d&resultsPerPage=%d&directSearch=%@&directSearchType=%d", filterIndex, sortIndex, pageNumber * MAX_USER_LEVELS, (MAX_USER_LEVELS + 1), directInputField.text ? [directInputField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: @"", directInputField.text ? (directIndex + 1) : 0];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"GET"];
		[connection release];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
		timeoutFrames = 0;
	}
}

- (void)prevLevelsButtonPressed
{
	int i;

	[self playSound:SOUND_CLICK];

	levelsPage--;

	prevLevelsButton.hidden = YES;
	nextLevelsButton.hidden = NO;

	for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
	{
		if (levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)] > -1)
		{
			levelButtons[i].hidden = NO;
			[self setImageView:[medalImagePaths objectAtIndex:levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)]] :levelButtons[i] :levelButtons[i].frame.origin.x :levelButtons[i].frame.origin.y];
			levelText[i].hidden = NO;
			levelText[i].text = [NSString stringWithFormat:@"%d", (i + (levelsPage * MAX_LEVELS_PER_PAGE) + 1)];
		}
	}
}

- (void)nextLevelsButtonPressed
{
	int i;

	[self playSound:SOUND_CLICK];

	levelsPage++;
	prevLevelsButton.hidden = NO;
	nextLevelsButton.hidden = YES;

	for (i = 0; i < MAX_LEVELS_PER_PAGE; i++)
	{
		levelButtons[i].hidden = YES;
		levelText[i].hidden = YES;

		if (i + (levelsPage * MAX_LEVELS_PER_PAGE) < 35)
		{
			if (levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)] > -1)
			{
				levelButtons[i].hidden = NO;
				[self setImageView:[medalImagePaths objectAtIndex:levelProgress[i + (levelsPage * MAX_LEVELS_PER_PAGE)]] :levelButtons[i] :levelButtons[i].frame.origin.x :levelButtons[i].frame.origin.y];
				levelText[i].hidden = NO;
				levelText[i].text = [NSString stringWithFormat:@"%d", (i + (levelsPage * MAX_LEVELS_PER_PAGE) + 1)];
			}
		}
	}
}

- (void)returnToEditorButtonPressed
{
	drawTileStartX = editorDrawStartX;
	drawTileStartY = editorDrawStartY;
	bgOffsetX = editorBGOffsetX;
	bgOffsetY = editorBGOffsetY;

	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_EDITOR]];
	returnToEditorButton.hidden = YES;
	retryButton.hidden = YES;
	retryField.hidden = YES;

	[self setImageView:@"btn_EditorButtons.png" :imageView :0 :0];
	[self setImageView:@"editorSelection.png" :imageSubView :0 :0];

	gridView.hidden = NO;
	imageSubView.hidden = NO;
	timerField.hidden = YES;
	blockNumField.hidden = YES;
	mainMessageField.hidden = YES;

	bronzeTimeField.hidden = YES;
	silverTimeField.hidden = YES;
	goldTimeField.hidden = YES;
	pauseExitButton.hidden = YES;
	pauseConfigButton.hidden = YES;
	pauseReturnButton.hidden = YES;
	pauseRetryButton.hidden = YES;
	musicVolumeView.hidden = YES;
	fxVolumeView.hidden = YES;
	editorState = EDITOR_STATE_SELECTION;

	self.view.multipleTouchEnabled = false;

	[self playSound:SOUND_CLICK];
}

- (void)retryButtonPressed
{
	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_RELOAD_MAP]];
	checkpointX = -1;
	checkpointY = -1;

	[self playSound:SOUND_CLICK];
}

- (void)returnToLevelsButtonPressed
{
	if (lockButtons)
	{
		return;
	}

	lockButtons = true;

	[gameState removeAllObjects];
	[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_SELECT]];
	if (gameType == GAME_TYPE_USER_LEVEL)
	{
		[gameState addObject:[NSNumber numberWithInteger:STATE_USER_LEVELS]];
	}
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_LEVEL_SELECT_ELEMENTS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_UI_ELEMENTS]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_CLEAR_OPENGL]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];

	[self playSong:0 repeats:YES];
	[self playSound:SOUND_CLICK];
}

- (void)nextButtonPressed
{
	if (lockButtons)
	{
		return;
	}

	lockButtons = true;
	showIntro = true;

	if (currentLevel == MAX_MAPS - 1)
	{
		[gameState removeAllObjects];

		[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_SELECT]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_LEVEL_SELECT_ELEMENTS]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CUTSCENE]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_SETUP_CUTSCENE]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CLEAR_OPENGL]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_UI_ELEMENTS]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
		cutsceneFrames = 0;
	}
	else
	{
		[gameState removeAllObjects];
		[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_LOAD_MAP]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_INCREMENT_LEVEL]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_CLEAR_OPENGL]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_UI_ELEMENTS]];
		[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_OUT]];
	}

	[self playSound:SOUND_BUTTON];
}

- (void)leftDifficultyButtonPressed
{
	diffIndex = (diffIndex > 0) ? diffIndex - 1 : [diffText count] - 1;
	diffField.text = [diffText objectAtIndex:diffIndex];
	[self playSound:SOUND_CLICK];
}

- (void)rightDifficultyButtonPressed
{
	diffIndex = (diffIndex < [diffText count] - 1) ? diffIndex + 1 : 0;
	diffField.text = [diffText objectAtIndex:diffIndex];
	[self playSound:SOUND_CLICK];
}

- (void)leftGoldButtonPressed
{
	goldTime = (goldTime >= 5) ? goldTime - 5 : 0;
	[self convertUserTime:editorGoldTimeField :goldTime];
	[self playSound:SOUND_CLICK];
}

- (void)rightGoldButtonPressed
{
	goldTime = ((goldTime + 5) < silverTime) ? goldTime + 5 : (silverTime - 5);
	[self convertUserTime:editorGoldTimeField :goldTime];
	[self playSound:SOUND_CLICK];
}

- (void)leftSilverButtonPressed
{
	silverTime = ((silverTime - 5) > goldTime) ? silverTime - 5 : goldTime + 5;
	[self convertUserTime:editorSilverTimeField :silverTime];
	[self playSound:SOUND_CLICK];
}

- (void)rightSilverButtonPressed
{
	silverTime = ((silverTime + 5) < bronzeTime) ? silverTime + 5 : (bronzeTime - 5);
	[self convertUserTime:editorSilverTimeField :silverTime];
	[self playSound:SOUND_CLICK];
}

- (void)leftBronzeButtonPressed
{
	bronzeTime = ((bronzeTime - 5) > silverTime) ? bronzeTime - 5 : silverTime + 5;
	[self convertUserTime:editorBronzeTimeField :bronzeTime];
	[self playSound:SOUND_CLICK];
}

- (void)rightBronzeButtonPressed
{
	bronzeTime = (bronzeTime < MAX_COUNTER) ? bronzeTime + 5 : MAX_COUNTER;
	[self convertUserTime:editorBronzeTimeField :bronzeTime];
	[self playSound:SOUND_CLICK];
}

- (void)leftBGTypeButtonPressed
{
	[self playSound:SOUND_CLICK];
	editorBGIndex = (editorBGIndex > 0) ? editorBGIndex - 1 : [bgText count] - 1;
	editorBGTypeField.text = [bgText objectAtIndex:editorBGIndex];
	[self setEditorBG];
}

- (void)rightBGTypeButtonPressed
{
	[self playSound:SOUND_CLICK];
	editorBGIndex = (editorBGIndex < [bgText count] - 1) ? editorBGIndex + 1 : 0;
	editorBGTypeField.text = [bgText objectAtIndex:editorBGIndex];
	[self setEditorBG];
}

- (void)pauseMenuReturnPressed
{
	[self playSound:SOUND_CLICK];
	[gameState removeLastObject];

	CGRect temp = goldTimeField.frame;
	temp.origin.y -= 32;
	goldTimeField.frame = temp;
	goldTimeField.hidden = YES;

	temp = silverTimeField.frame;
	temp.origin.y -= 32;
	silverTimeField.frame = temp;
	silverTimeField.hidden = YES;

	temp = bronzeTimeField.frame;
	temp.origin.y -= 32;
	bronzeTimeField.frame = temp;
	bronzeTimeField.hidden = YES;

	pauseReturnButton.hidden = YES;
	pauseExitButton.hidden = YES;
	pauseConfigButton.hidden = YES;
	pauseRetryButton.hidden = YES;
	musicVolumeView.hidden = YES;
	fxVolumeView.hidden = YES;
	imageView.hidden = YES;
}

- (void)pauseMenuRetryPressed
{
	[gameState removeLastObject];

	CGRect temp = goldTimeField.frame;
	temp.origin.y -= 32;
	goldTimeField.frame = temp;
	goldTimeField.hidden = YES;

	temp = silverTimeField.frame;
	temp.origin.y -= 32;
	silverTimeField.frame = temp;
	silverTimeField.hidden = YES;

	temp = bronzeTimeField.frame;
	temp.origin.y -= 32;
	bronzeTimeField.frame = temp;
	bronzeTimeField.hidden = YES;

	pauseReturnButton.hidden = YES;
	pauseExitButton.hidden = YES;
	pauseConfigButton.hidden = YES;
	pauseRetryButton.hidden = YES;
	musicVolumeView.hidden = YES;
	fxVolumeView.hidden = YES;
	imageView.hidden = YES;

	[self retryButtonPressed];
}

- (void)pauseMenuConfigPressed
{
	int i;

	[self playSound:SOUND_CLICK];
	[gameState removeLastObject];
	[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
	[gameState addObject:[NSNumber numberWithInteger:STATE_CONFIG_BUTTONS]];

	[self setImageView:@"UI_ConfigControls.png" :hudView :INT_MAX :INT_MAX];

	CGRect temp = goldTimeField.frame;
	temp.origin.y -= 32;
	goldTimeField.frame = temp;
	goldTimeField.hidden = YES;

	temp = silverTimeField.frame;
	temp.origin.y -= 32;
	silverTimeField.frame = temp;
	silverTimeField.hidden = YES;

	temp = bronzeTimeField.frame;
	temp.origin.y -= 32;
	bronzeTimeField.frame = temp;
	bronzeTimeField.hidden = YES;

	pauseReturnButton.hidden = YES;
	pauseExitButton.hidden = YES;
	pauseConfigButton.hidden = YES;
	pauseRetryButton.hidden = YES;
	musicVolumeView.hidden = YES;
	fxVolumeView.hidden = YES;
	imageView.hidden = YES;

	timerField.hidden = YES;
	blockNumField.hidden = YES;

	okConfigButton.hidden = NO;
	defaultConfigButton.hidden = NO;

	[self selectButtonGroup:BUTTON_GROUP_CONFIG];

	for (i = 0; i < [buttonsArray count]; i++)
	{
		GameButton *button = [buttonsArray objectAtIndex:i];

		switch (button.type)
		{
			case BUTTON_TYPE_LEFT:
				[button setAnim:ANIM_LEFT_BUTTON_DOWN];
				break;
			case BUTTON_TYPE_RIGHT:
				[button setAnim:ANIM_RIGHT_BUTTON_DOWN];
				break;
			case BUTTON_TYPE_UP:
				[button setAnim:ANIM_UP_BUTTON_DOWN];
				break;
			case BUTTON_TYPE_DOWN:
				[button setAnim:ANIM_DOWN_BUTTON_DOWN];
				break;
			case BUTTON_TYPE_BLOCK:
				[button setAnim:ANIM_OK_BUTTON];
				break;
		}
	}

	self.view.multipleTouchEnabled = false;
}

- (void)pauseMenuExitPressed
{
	[gameState removeLastObject];

	CGRect temp = goldTimeField.frame;
	temp.origin.y -= 32;
	goldTimeField.frame = temp;
	goldTimeField.hidden = YES;

	temp = silverTimeField.frame;
	temp.origin.y -= 32;
	silverTimeField.frame = temp;
	silverTimeField.hidden = YES;

	temp = bronzeTimeField.frame;
	temp.origin.y -= 32;
	bronzeTimeField.frame = temp;
	bronzeTimeField.hidden = YES;

	pauseReturnButton.hidden = YES;
	pauseExitButton.hidden = YES;
	pauseConfigButton.hidden = YES;
	pauseRetryButton.hidden = YES;
	musicVolumeView.hidden = YES;
	fxVolumeView.hidden = YES;
	imageView.hidden = YES;

	if (gameType == GAME_TYPE_EDITOR_LEVEL)
	{
		[self returnToEditorButtonPressed];
		[self selectButtonGroup:BUTTON_GROUP_NONE];
		hudView.hidden = YES;
	}
	else
	{
		[self returnToLevelsButtonPressed];
	}
}

- (void)oneStarPressed
{
	[self sendRating:1];
}

- (void)twoStarPressed
{
	[self sendRating:2];
}

- (void)threeStarPressed
{
	[self sendRating:3];
}

- (void)fourStarPressed
{
	[self sendRating:4];
}

- (void)fiveStarPressed
{
	[self sendRating:5];
}

- (void)sendRating:(int)rating
{
//	[[OFAchievement achievement:@"1482502"] updateProgressionComplete:100.0f andShowNotification:YES];

	[self playSound:SOUND_BUTTON];

	oneStar.hidden = YES;
	twoStar.hidden = YES;
	threeStar.hidden = YES;
	fourStar.hidden = YES;
	fiveStar.hidden = YES;
	helpSubView.hidden = YES;
	mainMessageField.hidden = YES;

	NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/rate.php?id=%d&rating=%d", userLevelIDs[selectedUser], rating];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"GET"];

	[connection release];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	connectionInUse = false; //we don't really care if this succeeds.
	[gameState removeLastObject];
}

- (void)ratingButtonPressed
{
	[self playSound:SOUND_BUTTON];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=490861957"]];
}

- (void)playSound:(int)index
{
	int i;

	if (!fxOn)
	{
		return;
	}

	for (i = 0; i < MAX_SOUNDS; i++)
	{
		if (!(soundFlags & (index << 1)))
		{
			alSourcePlay([[soundEffects objectAtIndex:index] unsignedIntValue]);
			soundFlags |= (index << 1);
			return;
		}
	}
}

- (void)playSong:(int)index repeats:(BOOL)rpt
{
	if (!musicPlaying ||!musicPlaying || currentSong != index)
	{
		if (musicPlaying)
		{
			[musicPlayer stop];
			[musicPlayer release];
		}

		NSString *filePath = [[NSBundle mainBundle] pathForResource:[songPaths objectAtIndex:index] ofType:@"mp3"];
		NSData *song = [NSData dataWithContentsOfFile:filePath];

		musicPlayer = [[AVAudioPlayer alloc] initWithData:song error:NULL];

		if (!musicOn)
		{
			musicPlayer.volume = 0.0f;
		}

		if (musicPlayer)
		{
			musicPlayer.delegate = self;

			if (rpt)
			{
				musicPlayer.numberOfLoops = -1;
			}
			else
			{
				musicPlayer.numberOfLoops = 0;
			}

			[musicPlayer play];
			currentSong = index;
			musicPlaying = true;
		}
	}
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	alcMakeContextCurrent(NULL);
	alcSuspendContext(mContext);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	UInt32 category = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	AudioSessionSetActive(YES);
	alcMakeContextCurrent(mContext);
	alcProcessContext(mContext);

	[musicPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	musicPlaying = false;
	int choice = (float)rand() / RAND_MAX * [songPaths count];

	if (choice == [songPaths count])
	{
		choice--;
	}

	[self playSong:choice repeats:NO];
}

- (void)resetMap
{
	int i, j;

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{

			if (i > 2 && j && j < (MAP_WIDTH - 1))
			{
				special[i][j] = 0;
				map[i][j] = 0;
			}
		}
	}

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		blockAmounts[i].amount = 0;
	}

	goldTime = 30;
	silverTime = 45;
	bronzeTime = 60;
}

- (void)setEditorBG
{
	int i, j;
	
	[bgImage release];
	NSString *mapPath;

	switch (editorBGIndex)
	{
		case 0:
			bgImage = [[Image alloc] initWithString:@"BGFactoryLevel.png"];
			mapPath = @"template_factory";
			break;
		case 1:
			bgImage = [[Image alloc] initWithString:@"BGGrassLevel.png"];
			mapPath = @"template_grass";
			break;
		case 2:
			bgImage = [[Image alloc] initWithString:@"BGCityLevel.png"];
			mapPath = @"template_city";
			break;
		case 3:
			bgImage = [[Image alloc] initWithString:@"BGSpaceLevel.png"];
			mapPath = @"template_space";
			break;
		case 4: 
			bgImage = [[Image alloc] initWithString:@"BGUndergroundLevel.png"];
			mapPath = @"template_underground";
			break;
		case 5:
			bgImage = [[Image alloc] initWithString:@"BGErrorLevel.png"];
			mapPath = @"template_error";
			break;
	}

	NSString *filePath = [[NSBundle mainBundle] pathForResource:mapPath ofType:@"dat"];
	NSData *mapFile = [NSData dataWithContentsOfFile:filePath];
	Byte *mapData = (Byte *)[mapFile bytes];

	mapData += sizeof(int);
	mapData += sizeof(int);
	mapData += sizeof(int);
	mapData += sizeof(int);

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		mapData += sizeof(int);
	}

	short msgLength = OSReadBigInt16(mapData, 0);
	mapData += sizeof(short);
	mapData += msgLength;

	msgLength = OSReadBigInt16(mapData, 0);
	mapData += sizeof(short);
	mapData += msgLength;

	//old data no longer used
	mapData += sizeof(int); //tile size
	mapData += sizeof(int); //width
	mapData += sizeof(int); //height
	//end data no longer used

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			if (i <= 2 || j == 0 || j == (MAP_WIDTH - 1))
			{
				special[i][j] = OSReadBigInt32(mapData, 0);
				mapData += sizeof(int);
				map[i][j] = OSReadBigInt32(mapData, 0);
				mapData += sizeof(int);
			}			
			else
			{
				mapData += sizeof(int);
				mapData += sizeof(int);
			}
		}
	}
}

- (void)removeDuplicatePlayerAndGoal
{
	int i, j;
	int goalAndPlayerStatus = EDITOR_NO_PLAYER_NO_GOAL;

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			switch (special[i][j])
			{
				case SPECIAL_PLAYER:
					if (!(goalAndPlayerStatus & EDITOR_PLAYER))
					{
						goalAndPlayerStatus |= EDITOR_PLAYER;
					}
					else
					{
						special[i][j] = 0;
					}
					break;
				case SPECIAL_GOAL:
					if (!(goalAndPlayerStatus & EDITOR_GOAL))
					{
						goalAndPlayerStatus |= EDITOR_GOAL;
					}
					else
					{
						special[i][j] = 0;
					}
					break;
			}
		}
	}
}

- (int)checkForGoalAndPlayerStart
{
	int i, j;
	int goalAndPlayerStatus = EDITOR_NO_PLAYER_NO_GOAL;

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			switch (special[i][j])
			{
				case SPECIAL_PLAYER:
					goalAndPlayerStatus |= EDITOR_PLAYER;
					break;
				case SPECIAL_GOAL:
					goalAndPlayerStatus |= EDITOR_GOAL;
					break;
			}
		}
	}

	return goalAndPlayerStatus;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	activeTextFieldOrigin.origin.x = textField.frame.origin.x;
	activeTextFieldOrigin.origin.y = textField.frame.origin.y;

	CGRect tempFrame = textField.frame;

	tempFrame.origin.x = (screenWidth - textField.frame.size.width) / 2;
	tempFrame.origin.y = usernameField.frame.origin.y;

	textField.frame = tempFrame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	CGRect tempFrame = textField.frame;

	tempFrame.origin.x = activeTextFieldOrigin.origin.x;
	tempFrame.origin.y = activeTextFieldOrigin.origin.y;

	textField.frame = tempFrame;
}

- (void)uploadUserLevel
{
	int i, j;

	NSString *mapString = [NSString stringWithFormat:@"%d|%d|%d|%d", goldTime, silverTime, bronzeTime, editorBGIndex];

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		mapString = [NSString stringWithFormat:@"%@|%d", mapString, blockAmounts[i].amount];
	}

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			mapString = [NSString stringWithFormat:@"%@|%d", mapString, map[i][j]];
		}
	}

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			mapString = [NSString stringWithFormat:@"%@|%d", mapString, special[i][j]];
		}
	}

	NSString *bodyString = [NSString stringWithFormat:@"difficulty=%d&level_data=%@&uname=%@&pwd=%@", diffIndex, mapString, [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/sendiOS.php"];

	connectionInUse = true;
	connectionType = CONNECTION_TYPE_UPLOAD_USER_LEVEL;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[NSData dataWithBytes:[bodyString UTF8String] length:[bodyString length]]];
	[connection release];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
	timeoutFrames = 0;
	uploadTime = time(NULL);
	[self saveProgress]; //record the last upload time
}

- (void)cancelConnection
{
	int i;
	bitView.hidden = YES;
	connectionInUse = false;

	[connection cancel];

	switch (connectionType)
	{
		case CONNECTION_TYPE_USER_LEVELS:
		{
			userField1.text = @"";
			userField2.text = @"";
			userField3.text = @"";
			userField4.text = @"";
			pageNumber = 0;
			pageField.text = [NSString stringWithFormat:@"Page: %d", (pageNumber + 1)];

			userField1.hidden = NO;
			userField2.hidden = NO;
			userField3.hidden = NO;
			userField4.hidden = NO;

			for (i = 0 ; i < 4; i++)
			{
				userLevelIDs[i] = -1;
				[userList[i] release];
				userList[i] = @"";
			}

			prevUserLevelsButton.hidden = YES;
			firstUserLevelsButton.hidden = YES;
			nextUserLevelsButton.hidden = YES;

			if ([self getGameState] == STATE_USER_LEVELS_SEARCH)
			{
				prevSortButton.hidden = YES;
				nextSortButton.hidden = YES;
				prevFilterButton.hidden = YES;
				nextFilterButton.hidden = YES;
				prevDirectButton.hidden = YES;
				nextDirectButton.hidden = YES;
				sortField.hidden = YES;
				filterField.hidden = YES;
				directField.hidden = YES;
				directInputField.hidden = YES;

				searchButton.hidden = NO;
				pageField.hidden = NO;

				[self setImageView:@"UI_LevelSelectUsers.png" :imageView :INT_MAX :INT_MAX];
				[gameState removeLastObject];
			}
			break;
		}
		case CONNECTION_TYPE_LOGIN_USER:
			loginButton.hidden = NO;
			registerButton.hidden = NO;
			cancelButton.hidden = NO;
			usernameField.hidden = NO;
			passwordField.hidden = NO;
			break;
		case CONNECTION_TYPE_REGISTER_USER:
			cancelButton.hidden = NO;
			registerPasswordField1.hidden = NO;
			registerPasswordField2.hidden = NO;
			registerUsernameField.hidden = NO;
			registerEmailField.hidden = NO;
			break;
		case CONNECTION_TYPE_UPLOAD_USER_LEVEL:
			if ([self getGameState] == STATE_LOGIN)
			{
				cancelButton.hidden = NO;
			}
			break;
		case CONNECTION_TYPE_LOAD_USER_LEVEL:
			[gameState addObject:[NSNumber numberWithInteger:STATE_FADE_IN]];
			break;
	}

	//pop up error box
	networkErrorView.hidden = NO;
	errorMessageField.hidden = NO;
	[gameState addObject:[NSNumber numberWithInteger:STATE_NETWORK_ERROR]];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	timeoutFrames = 0;
	[serverData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[serverData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (!connectionInUse)
	{
		return;
	}

	[gameState removeLastObject];
	[self cancelConnection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	int i;

	if (!connectionInUse)
	{
		return;
	}

	[gameState removeLastObject];
	bitView.hidden = YES;
	connectionInUse = false;

	if ([serverData length] == 0)
	{
		[self cancelConnection];
		return;
	}

	switch (connectionType)
	{
		case CONNECTION_TYPE_UPLOAD_USER_LEVEL:
		{
			NSString *mapData = [[NSString alloc] initWithData:serverData encoding:NSASCIIStringEncoding];

			if (![[mapData substringToIndex:7] isEqualToString:@"levelID"])
			{
				[self cancelConnection];
			}
			else
			{
				levelID = [[mapData substringFromIndex:8] intValue];

				if (levelID < 0)
				{
					//login is incorrect. Start the login cycle again.
					[self setImageView:@"UI_Login.png" :imageSubView :INT_MAX :INT_MAX];
					helpSubView.hidden = NO;
					mainMessageField.hidden = NO;
					mainMessageField.text = @"The saved username or password does not match a valid Green Pixel account. Please log in again. If you have forgotten your password, please go to www.greenpixel.ca to reset it.";
					[gameState removeAllObjects];
					[gameState addObject:[NSNumber numberWithInteger:STATE_MAIN_MENU]];
					[gameState addObject:[NSNumber numberWithInteger:STATE_EDITOR]];
					[gameState addObject:[NSNumber numberWithInteger:STATE_LOGIN]];
					[gameState addObject:[NSNumber numberWithInteger:STATE_INVALID_PASSWORD]];
				}
				else
				{
					//level went through
					helpSubView.hidden = NO;
					currentMessageField = mainMessageField;
					mainMessageField.hidden = NO;
					mainMessageField.text = [NSString stringWithFormat:@"Upload successful! The map ID is %d! Other users can find it by searching for the ID or for your username. You can also share it with the community at the www.greenpixel.ca forums! :)", levelID];
					[self playSound:SOUND_CLICK];
		//			[[OFAchievement achievement:@"1482522"] updateProgressionComplete:100.0f andShowNotification:YES];

					if (twitterIsSupported)
					{
						[gameState addObject:[NSNumber numberWithInteger:STATE_ADD_TWITTER_DIALOG]];
					}

					[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_UPLOAD_SUCCESS]];
				}
			}

			[mapData release];
			break;
		}
		case CONNECTION_TYPE_LOGIN_USER:
		{
			NSString *mapData = [[NSString alloc] initWithData:serverData encoding:NSASCIIStringEncoding];

			if (![[mapData substringToIndex:6] isEqualToString:@"userID"])
			{
				[self cancelConnection];
			}
			else
			{
				int userID = [[mapData substringFromIndex:7] intValue];

				if (userID < 0)
				{
					helpSubView.hidden = NO;
					mainMessageField.hidden = NO;
					mainMessageField.text = @"Username or password does not match a valid Green Pixel account. Please check to make sure of spelling and capitalization. If you have forgotten your password, please go to www.greenpixel.ca to reset it.";
					[self playSound:SOUND_CLICK];
					[gameState addObject:[NSNumber numberWithInteger:STATE_INVALID_PASSWORD]];
				}
				else //authenticated, upload the level.
				{
					[gameState addObject:[NSNumber numberWithInteger:STATE_SAVE_AND_UPLOAD]];
				}
			}

			[mapData release];
			break;
		}
		case CONNECTION_TYPE_USER_LEVELS:
		{
			NSString *mapData = [[NSString alloc] initWithData:serverData encoding:NSASCIIStringEncoding];
			NSString *error;
			NSData *listData = [mapData dataUsingEncoding:NSUTF8StringEncoding];
			NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:listData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];

			BOOL showNext = false;
			userField1.text = @"";
			userField2.text = @"";
			userField3.text = @"";
			userField4.text = @"";
			pageField.text = [NSString stringWithFormat:@"Page: %d", (pageNumber + 1)];

			if (!dict)
			{
				[error release];
				pageNumber = 0;
				[self cancelConnection];
			}
			else
			{
				int size = [[dict valueForKey:@"size"] intValue];

				if (size > MAX_USER_LEVELS)
				{
					showNext = true;
				}	

				for (i = 0 ; i < 4; i++)
				{
					userLevelIDs[i] = -1;
					[userList[i] release];
					userList[i] = @"";

					if (i < size)
					{
						int diff = 1;
						float ratingViews;
						float rating;
						int intRating;

						switch (i)
						{
							case 0:
								ratingViews = [[dict valueForKey:@"ratingViews0"] intValue];	
								rating = [[dict valueForKey:@"rating0"] intValue];
								[userList[0] release];
								userList[0] = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"username0"]];

								if (ratingViews > 0)
								{
									rating /= ratingViews;
								}
								else
								{
									rating = 0;
								}

								intRating = rating * 20;

								diff += [[dict valueForKey:@"diff0"] intValue];
								userField1.text = [NSString stringWithFormat:@"ID: %@ Author: %@ Date: %@\n  Completed: %@  Difficulty: %@  Rating: %d%%", [dict valueForKey:@"id0"], [dict valueForKey:@"username0"], [dict valueForKey:@"date0"], [dict valueForKey:@"ratingViews0"], [filterText objectAtIndex:diff], intRating];
								userLevelIDs[0] = [[dict valueForKey:@"id0"] intValue];
								break;
							case 1:
								ratingViews = [[dict valueForKey:@"ratingViews1"] intValue];	
								rating = [[dict valueForKey:@"rating1"] intValue];
								[userList[1] release];
								userList[1] = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"username1"]];

								if (ratingViews > 0)
								{
									rating /= ratingViews;
								}
								else
								{
									rating = 0;
								}

								intRating = rating * 20;

								diff += [[dict valueForKey:@"diff1"] intValue];
								userField2.text = [NSString stringWithFormat:@"ID: %@ Author: %@ Date: %@\n Completed: %@  Difficulty: %@  Rating: %d%%", [dict valueForKey:@"id1"], [dict valueForKey:@"username1"], [dict valueForKey:@"date1"], [dict valueForKey:@"ratingViews1"], [filterText objectAtIndex:diff], intRating];
								userLevelIDs[1] = [[dict valueForKey:@"id1"] intValue];
								break;
							case 2:
								ratingViews = [[dict valueForKey:@"ratingViews2"] intValue];	
								rating = [[dict valueForKey:@"rating2"] intValue];
								[userList[2] release];
								userList[2] = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"username2"]];

								if (ratingViews > 0)
								{
									rating /= ratingViews;
								}
								else
								{
									rating = 0;
								}

								intRating = rating * 20;

								diff += [[dict valueForKey:@"diff2"] intValue];
								userField3.text = [NSString stringWithFormat:@"ID: %@ Author: %@ Date: %@\n Completed: %@  Difficulty: %@  Rating: %d%%", [dict valueForKey:@"id2"], [dict valueForKey:@"username2"], [dict valueForKey:@"date2"], [dict valueForKey:@"ratingViews2"], [filterText objectAtIndex:diff], intRating];
								userLevelIDs[2] = [[dict valueForKey:@"id2"] intValue];
								break;
							case 3:
								ratingViews = [[dict valueForKey:@"ratingViews3"] intValue];	
								rating = [[dict valueForKey:@"rating3"] intValue];
								[userList[3] release];
								userList[3] = [[NSString alloc] initWithFormat:@"%@", [dict valueForKey:@"username3"]];

								if (ratingViews > 0)
								{
									rating /= ratingViews;
								}
								else
								{
									rating = 0;
								}

								intRating = rating * 20;

								diff += [[dict valueForKey:@"diff3"] intValue];
								userField4.text = [NSString stringWithFormat:@"ID: %@ Author: %@ Date: %@\n Completed: %@  Difficulty: %@  Rating: %d%%", [dict valueForKey:@"id3"], [dict valueForKey:@"username3"], [dict valueForKey:@"date3"], [dict valueForKey:@"ratingViews3"], [filterText objectAtIndex:diff], intRating];
								userLevelIDs[3] = [[dict valueForKey:@"id3"] intValue];
								break;
						}
					}
				}
			}

			userField1.hidden = NO;
			userField2.hidden = NO;
			userField3.hidden = NO;
			userField4.hidden = NO;

			if (pageNumber > 0)
			{
				prevUserLevelsButton.hidden = NO;
				firstUserLevelsButton.hidden = NO;
			}
			else
			{
				prevUserLevelsButton.hidden = YES;
				firstUserLevelsButton.hidden = YES;
			}

			if (showNext)
			{
				nextUserLevelsButton.hidden = NO;
			}
			else
			{
				nextUserLevelsButton.hidden = YES;
			}

			if ([self getGameState] == STATE_USER_LEVELS_SEARCH)
			{
				prevSortButton.hidden = YES;
				nextSortButton.hidden = YES;
				prevFilterButton.hidden = YES;
				nextFilterButton.hidden = YES;
				prevDirectButton.hidden = YES;
				nextDirectButton.hidden = YES;
				sortField.hidden = YES;
				filterField.hidden = YES;
				directField.hidden = YES;
				directInputField.hidden = YES;

				searchButton.hidden = NO;
				pageField.hidden = NO;

				[self setImageView:@"UI_LevelSelectUsers.png" :imageView :INT_MAX :INT_MAX];
				[gameState removeLastObject];
			}

			[mapData release];
			break;
		}
		case CONNECTION_TYPE_LOAD_USER_LEVEL:
		{
			NSString *mapData = [[NSString alloc] initWithData:serverData encoding:NSASCIIStringEncoding];

			if (![[mapData substringToIndex:9] isEqualToString:@"levelData"])
			{
				[mapData release];
				[self cancelConnection];
			}
			else
			{
				backButton.hidden = YES;
				searchButton.hidden = YES;

				imageView.hidden = YES;
				startButton.hidden = YES;
				editorButton.hidden = YES;
				creditsButton.hidden = YES;
				ratingButton.hidden = YES;
				fxVolumeView.hidden = YES;
				musicVolumeView.hidden = YES;

				userField1.hidden = YES;
				userField2.hidden = YES;
				userField3.hidden = YES;
				userField4.hidden = YES;

				prevUserLevelsButton.hidden = YES;
				nextUserLevelsButton.hidden = YES;
				firstUserLevelsButton.hidden = YES;
				pageField.hidden = YES;

				showIntro = true;
				showBlockIntro = false;

				[gameState removeAllObjects];
				[gameState addObject:[NSNumber numberWithInteger:STATE_PLAY]];
				[gameState addObject:[NSNumber numberWithInteger:STATE_LEVEL_INIT]];
				[gameState addObject:[NSNumber numberWithInteger:STATE_TAP_TO_CONTINUE]];
				[self loadUserLevel:[mapData substringFromIndex:10]];
				[mapData release];

				gameType = GAME_TYPE_USER_LEVEL;
				textIndex = 0;
				currentMessageField.text = @"";
				[message release];
				message = [[NSString alloc] initWithFormat:@"Level #%d was designed by %@!", userLevelIDs[selectedUser], userList[selectedUser]];
			}
			break;
		}
		case CONNECTION_TYPE_REGISTER_USER:
		{
			NSString *mapData = [[NSString alloc] initWithData:serverData encoding:NSASCIIStringEncoding];

			if (![[mapData substringToIndex:6] isEqualToString:@"userID"])
			{
				[self cancelConnection];
			}
			else
			{
				int userID = [[mapData substringFromIndex:7] intValue];

				mainMessageField.text = @"";

				switch (userID)
				{
					case -1:
						mainMessageField.text = @"Sorry, the email you entered was invalid. Please check to make sure it is entered correctly!";
						break;
					case -2:
						mainMessageField.text = @"Sorry, the email you entered is already in our system. If you have forgotten your password, you can reset it by going to www.greenpixel.ca";
						break;
					case -3:
						mainMessageField.text = @"Sorry, that username has already been taken. :(";
						break;
					default:
						mainMessageField.text = [NSString stringWithFormat:@"Welcome aboard, %@! We sent a confirmation email to your address. If you would like to join our forums at www.greenpixel.ca, just click the confirm link; if not, just ignore it! We won't send any more. :) Your username and password were saved.", registerUsernameField.text];
						break;
				}

				mainMessageField.hidden = NO;
				helpSubView.hidden = NO;
				registerPasswordField1.hidden = YES;
				registerPasswordField2.hidden = YES;
				registerUsernameField.hidden = YES;
				registerEmailField.hidden = YES;
				[self playSound:SOUND_CLICK];

				if (userID < 0)
				{
					[gameState addObject:[NSNumber numberWithInteger:STATE_REGISTER_ERROR]];
				}
				else
				{
					[username release];
					username = [[NSString alloc] initWithFormat:@"%@", registerUsernameField.text];
					[password release];
					password = [[NSString alloc] initWithFormat:@"%@", registerPasswordField1.text];
					[gameState addObject:[NSNumber numberWithInteger:STATE_SAVE_AND_UPLOAD]];
					[gameState addObject:[NSNumber numberWithInteger:STATE_REGISTER_SUCCESS]];
				}
			}

			break;
		}
	}

	connectionInUse = false;
}

- (void)validateRegistration
{
	NSString *pwd1 = registerPasswordField1.text;
	NSString *pwd2 = registerPasswordField2.text;
	NSString *uname = registerUsernameField.text;
	NSString *email = registerEmailField.text;
	currentMessageField = mainMessageField;
	helpSubView.hidden = YES;
	mainMessageField.hidden = YES;
	mainMessageField.text = @"";

	if (![pwd1 isEqualToString:pwd2])
	{
		mainMessageField.text = @"Passwords do not match!";
	}
	if ([uname length] < 4)
	{
		mainMessageField.text = [NSString stringWithFormat:@"%@\nUsernames must be 3 or more characters.", mainMessageField.text];;
	}
	if ([pwd1 length] < 6)
	{
		mainMessageField.text = [NSString stringWithFormat:@"%@\nPasswords must be 6 or more characters.", mainMessageField.text];
	}

	if ([mainMessageField.text length])
	{
		helpSubView.hidden = NO;
		mainMessageField.hidden = NO;
		okButton.hidden = YES;
		cancelButton.hidden = YES;
		registerPasswordField1.hidden = YES;
		registerPasswordField2.hidden = YES;
		registerUsernameField.hidden = YES;
		registerEmailField.hidden = YES;
		[self playSound:SOUND_CLICK];

		[gameState addObject:[NSNumber numberWithInteger:STATE_REGISTER_ERROR]];
	}
	else
	{
		NSString *bodyString = [NSString stringWithFormat:@"email=%@&uname=%@&pwd=%@", [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [uname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [pwd1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSString *urlString = [NSString stringWithFormat:@"http://flash.greenpixel.ca/blockhopper/php/register.php"];

		connectionInUse = true;
		connectionType = CONNECTION_TYPE_REGISTER_USER;
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[NSData dataWithBytes:[bodyString UTF8String] length:[bodyString length]]];
		[connection release];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[gameState addObject:[NSNumber numberWithInteger:STATE_WAITING_FOR_NETWORK]];
		timeoutFrames = 0;
	}
}

- (BOOL)allLevelsHaveGold
{
	int i;

	for (i = 0; i < MAX_MAPS; i++)
	{
		if (levelProgress[i] < MEDAL_TYPE_GOLD)
		{
			return false;
		}
	}

	return true;
}

- (void)saveProgress
{
	int i;
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"data.dat"];
	NSMutableDictionary *saveFile = [[NSMutableDictionary alloc] init];

	for (i = 0; i < MAX_MAPS; i++)
	{
		NSString *keyString = [NSString stringWithFormat:@"medal%d", i];
		[saveFile setValue:[NSNumber numberWithInt:levelProgress[i]] forKey:keyString];

		keyString = [NSString stringWithFormat:@"time%d", i];
		[saveFile setValue:[NSNumber numberWithInt:levelTimes[i]] forKey:keyString];
	}

	for (i = 0; i < MAX_INTRO_BLOCKS; i++)
	{
		NSString *keyString = [NSString stringWithFormat:@"block%d", i];
		[saveFile setValue:[NSNumber numberWithInt:introBlocks[i]] forKey:keyString];
	}

	NSString *keyString = [NSString stringWithFormat:@"editorWarning"];
	[saveFile setValue:[NSNumber numberWithInt:showEditorWarning] forKey:keyString];

	keyString = [NSString stringWithFormat:@"playerHasGold"];
	[saveFile setValue:[NSNumber numberWithInt:playerHasGold] forKey:keyString];

	keyString = [NSString stringWithFormat:@"playerHasDeaths"];
	[saveFile setValue:[NSNumber numberWithInt:playerHasDeaths] forKey:keyString];

	keyString = [NSString stringWithFormat:@"uploadTime"];
	[saveFile setValue:[NSNumber numberWithInt:uploadTime] forKey:keyString];

	keyString = [NSString stringWithFormat:@"musicOn"];
	[saveFile setValue:[NSNumber numberWithInt:musicOn] forKey:keyString];

	keyString = [NSString stringWithFormat:@"fxOn"];
	[saveFile setValue:[NSNumber numberWithInt:fxOn] forKey:keyString];

	for (i = 0; i < 12; i++)
	{
		keyString = [NSString stringWithFormat:@"button%d", i];
		[saveFile setValue:[NSNumber numberWithInt:buttonPos[i]] forKey:keyString];
	}

	[saveFile writeToFile:filePath atomically:YES];
	[saveFile release];
}

- (void)loadProgress
{
	int i;
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"data.dat"];
	NSDictionary *loadFile = [[NSDictionary alloc] initWithContentsOfFile:filePath];

	if (loadFile)
	{
		for (i = 0; i < MAX_MAPS; i++)
		{
			NSString *keyString = [NSString stringWithFormat:@"medal%d", i];
			levelProgress[i] = [[loadFile valueForKey:keyString] intValue];

			keyString = [NSString stringWithFormat:@"time%d", i];
			levelTimes[i] = [[loadFile valueForKey:keyString] intValue];
		}

		for (i = 0; i < MAX_INTRO_BLOCKS; i++)
		{
			NSString *keyString = [NSString stringWithFormat:@"block%d", i];
			introBlocks[i] = [[loadFile valueForKey:keyString] intValue];
		}

		NSString *keyString = [NSString stringWithFormat:@"editorWarning"];
		showEditorWarning = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"playerHasGold"];
		playerHasGold = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"playerHasDeaths"];
		playerHasDeaths = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"uploadTime"];
		uploadTime = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"musicOn"];
		musicOn = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"fxOn"];
		fxOn = [[loadFile valueForKey:keyString] intValue];

		for (i = 0; i < 12; i++)
		{
			keyString = [NSString stringWithFormat:@"button%d", i];
			buttonPos[i] = [[loadFile valueForKey:keyString] intValue];
		}
	}

	[loadFile release];
}

- (void)saveEditorFile
{
	int i, j;
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;
	int tileCounter = 0;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"level.dat"];
	NSMutableDictionary *saveFile = [[NSMutableDictionary alloc] initWithCapacity:0];

	for (i = 0; i < MAP_HEIGHT; i++)
	{
		for (j = 0; j < MAP_WIDTH; j++)
		{
			NSString *keyString = [NSString stringWithFormat:@"mapTile%d", tileCounter];
			[saveFile setValue:[NSNumber numberWithInt:map[i][j]] forKey:keyString];

			keyString = [NSString stringWithFormat:@"specialTile%d", tileCounter];
			[saveFile setValue:[NSNumber numberWithInt:special[i][j]] forKey:keyString];
			tileCounter++;
		}
	}

	for (i = 0; i < MAX_USER_BLOCKS; i++)
	{
		NSString *keyString = [NSString stringWithFormat:@"block%d", i];
		[saveFile setValue:[NSNumber numberWithInt:blockAmounts[i].amount] forKey:keyString];
	}

	NSString *keyString = [NSString stringWithFormat:@"goldTime"];
	[saveFile setValue:[NSNumber numberWithInt:goldTime] forKey:keyString];

	keyString = [NSString stringWithFormat:@"silverTime"];
	[saveFile setValue:[NSNumber numberWithInt:silverTime] forKey:keyString];

	keyString = [NSString stringWithFormat:@"bronzeTime"];
	[saveFile setValue:[NSNumber numberWithInt:bronzeTime] forKey:keyString];

	keyString = [NSString stringWithFormat:@"editorBG"];
	[saveFile setValue:[NSNumber numberWithInt:editorBGIndex] forKey:keyString];

	keyString = [NSString stringWithFormat:@"diff"];
	[saveFile setValue:[NSNumber numberWithInt:diffIndex] forKey:keyString];

	if ([saveFile writeToFile:filePath atomically:YES])
	{
		helpSubView.hidden = NO;
		currentMessageField = mainMessageField;
		currentMessageField.text = @"Level saved successfully! Next time you open the editor, it will be loaded.";
		currentMessageField.hidden = NO;
		[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
	}
	else
	{
		helpSubView.hidden = NO;
		currentMessageField = mainMessageField;
		currentMessageField.text = @"Level could not be saved!!! Try freeing up space on the device.";
		currentMessageField.hidden = NO;
		[gameState addObject:[NSNumber numberWithInteger:STATE_REMOVE_HELP_MESSAGE]];
	}

	[saveFile release];
}

- (void)loadEditorFile
{
	int i, j;
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;
	int tileCounter = 0;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"level.dat"];
	NSDictionary *loadFile = [[NSDictionary alloc] initWithContentsOfFile:filePath];

	if (loadFile)
	{
		for (i = 0; i < MAP_HEIGHT; i++)
		{
			for (j = 0; j < MAP_WIDTH; j++)
			{
				NSString *keyString = [NSString stringWithFormat:@"mapTile%d", tileCounter];
				map[i][j] = [[loadFile valueForKey:keyString] intValue];

				keyString = [NSString stringWithFormat:@"specialTile%d", tileCounter];
				special[i][j] = [[loadFile valueForKey:keyString] intValue];
				tileCounter++;
			}
		}

		for (i = 0; i < MAX_USER_BLOCKS; i++)
		{
			NSString *keyString = [NSString stringWithFormat:@"block%d", i];
			[blockAmounts[i] setAmount:[[loadFile valueForKey:keyString] intValue]];
		}

		NSString *keyString = [NSString stringWithFormat:@"goldTime"];
		goldTime = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"silverTime"];
		silverTime = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"bronzeTime"];
		bronzeTime = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"editorBG"];
		editorBGIndex = [[loadFile valueForKey:keyString] intValue];

		keyString = [NSString stringWithFormat:@"diff"];
		diffIndex = [[loadFile valueForKey:keyString] intValue];
	}

	[loadFile release];
}

- (BOOL)loadLogin
{
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"login.dat"];
	NSDictionary *loadFile = [[NSDictionary alloc] initWithContentsOfFile:filePath];

	if (loadFile)
	{
		NSString *keyString = [NSString stringWithFormat:@"username"];
		[username release];
		username = [[NSString alloc] initWithFormat:@"%@", [loadFile valueForKey:keyString]];

		keyString = [NSString stringWithFormat:@"password"];
		[password release];
		password = [[NSString alloc] initWithFormat:@"%@", [loadFile valueForKey:keyString]];
		return true;
	}

	[loadFile release];

	return false;
}

- (void)saveLogin
{
	NSArray *dirPaths;
	NSString *docsDir;
	NSString *filePath;

	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	docsDir = [dirPaths objectAtIndex:0];
	filePath = [NSString stringWithFormat:@"%@/%@", docsDir, @"login.dat"];
	NSMutableDictionary *saveFile = [[NSMutableDictionary alloc] init];

	NSString *keyString = [NSString stringWithFormat:@"username"];
	[saveFile setValue:username forKey:keyString];

	keyString = [NSString stringWithFormat:@"password"];
	[saveFile setValue:password forKey:keyString];

	[saveFile writeToFile:filePath atomically:YES];
	[saveFile release];
}

- (IBAction)showAchievements
{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];

	if (achievements)
	{
		achievements.achievementDelegate = self;
		[self presentModalViewController:achievements animated:YES];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];
	[viewController release];
}

@end
