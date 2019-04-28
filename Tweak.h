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
- (void)setLongPressGestureRecognizer:(UILongPressGestureRecognizer *)arg1;
@end

@interface UIKeyboardDockView : UIView
@property (nonatomic, retain) UIKeyboardDockItem *rightDockItem;
- (void)setRightDockItem:(UIKeyboardDockItem *)arg1;
- (void)_dockItemButtonWasTapped:(id)arg1 withEvent:(id)arg2;
@end

@interface UISystemKeyboardDockController : UIViewController
- (void)loadView;
- (void)keyboardDockView:(id)arg1 didPressDockItem:(id)arg2 withEvent:(id)arg3;
- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2;
- (void)txtToggleActive;
- (void)longPress:(UILongPressGestureRecognizer *)gesture;
@end

@interface UIKeyboardImpl : UIView
- (void)insertText:(id)arg1;
@end

@interface UIRemoteKeyboardWindow : UIWindow
- (double)windowLevel;
- (double)defaultWindowLevel;
@end
