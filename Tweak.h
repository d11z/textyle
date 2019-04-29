@interface UICalloutBar : UIView
@property (nonatomic, retain) NSArray *extraItems;
@property (nonatomic, retain) UIMenuItem *txtMainMenuItem;
@property (nonatomic, retain) NSArray *txtStyleMenuItems;
+ (id)sharedCalloutBar;
+ (void)_releaseSharedInstance;
- (void)update;
- (void)resetPage;
@end

@interface UICalloutBarButton : UIButton
@property (nonatomic, assign) SEL action;
- (void)setupWithTitle:(id)arg1 action:(SEL)arg2 type:(int)arg3;
- (void)setupWithImage:(id)arg1 action:(SEL)arg2 type:(int)arg3;
@end

@interface UIMenuItem (Textyle)
@property (assign, nonatomic) BOOL dontDismiss;
@end

@interface UIResponder (Textyle)
- (NSRange)_selectedNSRange;
- (id)_fullText;
- (id)_textRangeFromNSRange:(NSRange)arg1;
- (void)replaceRange:(id)arg1 withText:(id)arg2;
- (void)txtDidSelectStyle:(NSString *)name;
- (void)txtReplaceSelectedText:(NSDictionary *)map;
@end

@interface UIImageView (Textyle)
- (long long)_defaultRenderingMode;
@end

@interface UIKeyboardDockItemButton : UIButton
@end

@interface UIKeyboardDockItem : NSObject
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL enabled;
- (UIKeyboardDockItemButton *)button;
- (id)initWithImageName:(id)arg1 identifier:(id)arg2;
- (void)setEnabled:(BOOL)arg1;
- (void)setImage:(UIImage *)arg1;
@end

@interface UISystemKeyboardDockController : UIViewController
- (void)loadView;
- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2;
- (void)txtToggleActive;
- (void)txtLongPress:(UILongPressGestureRecognizer *)gesture;
@end

@interface UIKeyboardImpl : UIView
- (void)insertText:(id)arg1;
@end

@interface UIRemoteKeyboardWindow : UIWindow
- (double)windowLevel;
- (double)defaultWindowLevel;
@end

@class TXTStyleManager, TXTStyleSelectionWindow;

static TXTStyleManager *styleManager;
static UIColor *defaultMenuColor;
static TXTStyleSelectionWindow *selectionWindow;

static BOOL enabled;
static BOOL toggleMenu;
static BOOL tintMenu;
static BOOL menuIcon;
static BOOL tintIcon;
static NSString *menuLabel;
static NSDictionary *blacklist;

static BOOL menuOpen;
static BOOL active;
static int spongebobCounter;
