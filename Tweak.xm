#import "Tweak.h"
#import "TXTConstants.h"
#import "TXTStyleManager.h"
#import "TXTStyleSelectionWindow.h"
#import "NSString+Stylize.h"
#import "SparkAppList.h"

static UIImage * resizeImage(UIImage *original, CGSize size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [original drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

%group Textyle

%hook UICalloutBar

%property (nonatomic, retain) UIMenuItem *txtMainMenuItem;
%property (nonatomic, retain) NSArray *txtStyleMenuItems;

- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;

    if (!self.txtMainMenuItem) {
        self.txtMainMenuItem = [[UIMenuItem alloc] initWithTitle:menuLabel action:@selector(txtOpenStyleMenu:)];
        self.txtMainMenuItem.dontDismiss = YES;
    }

    if (!self.txtStyleMenuItems) {
        NSMutableArray *items = [NSMutableArray array];

        NSArray *styles = [styleManager enabledStyles];
        for (NSDictionary *style in styles) {
            NSString *action = [NSString stringWithFormat:@"txt_%@", style[@"name"]];
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:style[@"label"] action:NSSelectorFromString(action)];

            [items addObject:item];
        }

        self.txtStyleMenuItems = items;
    }

    return self;
}

- (void)updateAvailableButtons {
    %orig;

    if (!self.extraItems) self.extraItems = @[];

    BOOL isSelected = NO;
    NSMutableArray *currentSystemButtons = MSHookIvar<NSMutableArray *>(self, "m_currentSystemButtons");
    for (UICalloutBarButton *btn in currentSystemButtons) {
        if (btn.action == @selector(cut:)) isSelected = YES;
    }

    NSMutableArray *items = [self.extraItems mutableCopy];

    if (isSelected && enabled) {
        if (![items containsObject:self.txtMainMenuItem]) [items addObject:self.txtMainMenuItem];
    } else [items removeObject:self.txtMainMenuItem];

    if (menuOpen) {
        items = [NSMutableArray array];
        for (UIMenuItem *item in self.txtStyleMenuItems) {
            if (![items containsObject:item]) [items addObject:item];
        }
    } else for (UIMenuItem *item in self.txtStyleMenuItems) {
        [items removeObject:item];
    }

    self.extraItems = items;

    %orig;

    if (menuOpen) {
        for (UICalloutBarButton *btn in currentSystemButtons) {
            [btn removeFromSuperview];
        }
        [currentSystemButtons removeAllObjects];
    }
}

%end

%hook UICalloutBarBackground

- (void)layoutSubviews {
    %orig;

    UIVisualEffectView *tint = MSHookIvar<UIVisualEffectView *>(self, "_tintView");

    if (!defaultMenuColor) defaultMenuColor = tint.backgroundColor;

    if (menuOpen && tintMenu) tint.backgroundColor = kAccentColorAlpha;
    else tint.backgroundColor = defaultMenuColor;
}

%end

%subclass TXTImageView : UIImageView

-(long long)_defaultRenderingMode {
    return 2;
}

%end

%hook UICalloutBarButton

- (void)setupWithTitle:(id)arg1 action:(SEL)arg2 type:(int)arg3 {
    if (menuIcon && arg2 == @selector(txtOpenStyleMenu:)) {
        UIImage *image = resizeImage([UIImage imageWithContentsOfFile:kMenuIcon], CGSizeMake(18, 18));
        [self setupWithImage:image action:arg2 type:arg3];

        if (tintIcon) {
            object_setClass(self.imageView, %c(TXTImageView));
            [self.imageView setTintColor:kAccentColor];
        }
    } else %orig;
}

%end

%hook UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (menuOpen) return match.location == 0;
    else return %orig;
}

%new
- (void)txtOpenStyleMenu:(UIResponder *)sender {
    menuOpen = YES;

    UICalloutBar *calloutBar = [UICalloutBar sharedCalloutBar];
    [calloutBar resetPage];
    [calloutBar update];
}

%new
- (void)txtCloseStyleMenu {
    menuOpen = NO;
}

- (BOOL)becomeFirstResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtCloseStyleMenu) name:UIMenuControllerDidHideMenuNotification object:nil];
    return %orig;
}

%new
- (void)txtDidSelectStyle:(NSString *)name {
    menuOpen = NO;

    NSDictionary *style = [styleManager styleWithName:name];
    NSRange selectedRange = [self _selectedNSRange];
    NSString *original = [self _fullText];
    NSString *selectedText = [original substringWithRange:selectedRange];
    UITextRange *textRange = [self _textRangeFromNSRange:selectedRange];

    [self replaceRange:textRange withText:[NSString stylizeText:selectedText withStyle:style]];
}

%end

%hook UITextField

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return %orig(sel) ?: %orig(@selector(txtDidSelectStyle:));
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (match.location == 0) [self txtDidSelectStyle:[sel substringFromIndex:4]];
    else %orig(invocation);
}

%end

%hook UITextView

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return %orig(sel) ?: %orig(@selector(txtDidSelectStyle:));
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (match.location == 0) [self txtDidSelectStyle:[sel substringFromIndex:4]];
    else %orig(invocation);
}

%end

%end

%group ToggleMenu

%hook UIKeyboardDockItem

- (id)initWithImageName:(id)arg1 identifier:(id)arg2 {
    return %orig(arg1, [arg2 isEqualToString:@"dictation"] ? @"textyle" : arg2);
}

- (void)setEnabled:(BOOL)arg1 {
    %orig([self.identifier isEqualToString:@"textyle"] ?: arg1);
}

%end

%subclass TXTDockItemButton : UIKeyboardDockItemButton

- (void)setTintColor:(UIColor *)arg1 {
    %orig(active ? kAccentColorAlpha : arg1);
}

%end

%hook UISystemKeyboardDockController

- (void)loadView {
    %orig;

    UIKeyboardDockItem *dockItem = MSHookIvar<UIKeyboardDockItem *>(self, "_dictationDockItem");
    object_setClass(dockItem.button, %c(TXTDockItemButton));

    UIImage *image = resizeImage([UIImage imageWithContentsOfFile:kMenuIcon], CGSizeMake(27, 27));
    [dockItem.button setImage:image forState:UIControlStateNormal];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtLongPress:)];
    longPress.cancelsTouchesInView = NO;
    longPress.minimumPressDuration = 0.3f;
    [dockItem.button addGestureRecognizer:longPress];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txtToggleActive)];
    singleTap.numberOfTapsRequired = 1;
    [dockItem.button addGestureRecognizer:singleTap];
}

- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 {
    return;
}

%new
- (void)txtToggleActive {
    active = !active;
    if (active) spongebobCounter = 0;

    UIKeyboardDockItem *dockItem = MSHookIvar<UIKeyboardDockItem *>(self, "_dictationDockItem");
    [dockItem.button setTintColor:kAccentColorAlpha];
}

%new
- (void)txtLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (!active) [self txtToggleActive];

        UIImpactFeedbackGenerator *hapticFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [hapticFeedbackGenerator prepare];
        [hapticFeedbackGenerator impactOccurred];
        hapticFeedbackGenerator = nil;

        if (!selectionWindow) selectionWindow = [[TXTStyleSelectionWindow alloc] init];
        [selectionWindow show];
    }
}

%end

%hook UIKeyboardImpl

- (void)insertText:(id)arg1 {
    NSString *text = arg1;

    if (active) {
        NSDictionary *activeStyle = [styleManager activeStyle];
        NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
        BOOL isLetter = [letters characterIsMember:[arg1 characterAtIndex:0]];

        if ([activeStyle[@"function"] isEqualToString:@"spongebob"]) {
            text = isLetter ? [NSString stylizeTextSpongebobActive:arg1 counter:&spongebobCounter] : arg1;
        } else {
            text = [NSString stylizeText:arg1 withStyle:activeStyle];
        }
    }

    %orig(text);
}

%end

%hook UIRemoteKeyboardWindow
- (double)windowLevel { return 999999; }
- (double)defaultWindowLevel { return 999999; }
- (void)setWindowLevel:(double)arg1 { %orig(999999); }
- (void)_setWindowLevel:(double)arg1 { %orig(999999); }
- (void)setDefaultWindowLevel:(double)arg1 { %orig(999999); }
- (void)setLevel:(double)arg1 { %orig(999999); }
- (double)level { return 999999; }
%end

%end

static void loadPrefs() {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefsPath];

    enabled = [([preferences objectForKey:@"Enabled"] ?: @(YES)) boolValue];
    toggleMenu = [([preferences objectForKey:@"ToggleMenu"] ?: @(YES)) boolValue];
    tintMenu = [([preferences objectForKey:@"TintMenu"] ?: @(YES)) boolValue];
    menuIcon = [([preferences objectForKey:@"MenuIcon"] ?: @(YES)) boolValue];
    tintIcon = [([preferences objectForKey:@"TintIcon"] ?: @(NO)) boolValue];
    menuLabel = ([preferences objectForKey:@"MenuLabel"] ?: kDefaultMenuLabel);
}

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

static void enabledStylesNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [UICalloutBar _releaseSharedInstance];
    [selectionWindow reload];
}

static void activeStyleNotificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [selectionWindow reload];
    [selectionWindow hideWithDelay:0.15];
}

__attribute__((always_inline)) bool check_crack() {
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.d11z.textyle.list"];
}

%ctor {
    NSString *const identifier = [NSBundle mainBundle].bundleIdentifier;
    NSArray *const args = [[NSProcessInfo processInfo] arguments];
    BOOL const isSpringBoard = [identifier isEqualToString:@"com.apple.springboard"];
    BOOL shouldLoad = NO;

    if (args.count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
            shouldLoad = isSpringBoard || isApplication;
        }
    }

    if ([SparkAppList doesIdentifier:@"com.d11z.textyle" andKey:@"Blacklist" containBundleIdentifier:identifier]) {
        shouldLoad = NO;
    }

    if (!shouldLoad || !check_crack()) return;

    styleManager = [TXTStyleManager sharedManager];
    if (isSpringBoard) [styleManager initForSpringBoard];

    loadPrefs();

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)notificationCallback,
        CFSTR("com.d11z.textyle/preferences"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)enabledStylesNotificationCallback,
        CFSTR("com.d11z.textyle.styles/enabledStyles"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)activeStyleNotificationCallback,
        CFSTR("com.d11z.textyle.styles/activeStyle"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );

    menuOpen = NO;
    active = NO;
    spongebobCounter = 0;

    %init(Textyle);

    if (enabled && toggleMenu) {
        %init(ToggleMenu);
    }
}
