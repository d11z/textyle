#import "Tweak.h"
#import "TXTConstants.h"
#import "TXTStyleManager.h"
#import "TXTStyleSelectionWindow.h"
#import "NSString+Stylize.h"
#import "SparkAppList.h"
#import <CommonCrypto/CommonCrypto.h>

static UIImage * resizeImage(UIImage *original, CGSize size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [original drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static const unsigned char _key[] = { 0x1C, 0x46, 0x55, 0x46, 0x1D, 0x5B, 0x50, 0x7, 0x4A, 0x56, 0x12, 0x5E, 0x50, 0x49, 0x51, 0x5A, 0x5E, 0xD, 0x19, 0x56, 0x5D, 0x8, 0x4C, 0x6, 0x3, 0x2, 0x49, 0x4D, 0x4C, 0x51, 0x49, 0x46, 0x1D, 0x5A, 0x4, 0x4C, 0x5E, 0xA, 0x46, 0x4C, 0x00 };
static const unsigned char *key = &_key[0];
static const NSString *salt;

inline NSString * __attribute__((always_inline)) NS_REQUIRES_NIL_TERMINATION createSalt(Class clazz, ...) {
    NSMutableString *classes;
    id eachClass;
    va_list argumentList;

    if (clazz) {
        classes = [[NSMutableString alloc] initWithString:NSStringFromClass(clazz)];
        va_start(argumentList, clazz);
        while ((eachClass = va_arg(argumentList, id))) {
            [classes appendString:NSStringFromClass(eachClass)];
        }
        va_end(argumentList);
    }

    NSData *d = [[classes copy] dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char obfuscator[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(d.bytes, (CC_LONG)d.length, obfuscator);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", obfuscator[i]];
    }

    return [output copy];
}

inline NSString * __attribute__((always_inline)) decode(const unsigned char *string) {
    if (!salt) {
        salt = createSalt([SparkAppList class], [UICalloutBar class], [TXTStyleSelectionWindow class], [TXTStyleManager class], nil);
    }

    NSData *data = [[[NSString alloc] initWithFormat:@"%s", string] dataUsingEncoding:NSUTF8StringEncoding];
    char *dataPtr = (char *)[data bytes];
    char *keyData = (char *)[[salt dataUsingEncoding:NSUTF8StringEncoding] bytes];
    char *keyPtr = keyData;
    int keyIndex = 0;

    for (int x = 0; x < [data length]; x++) {
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;

        if (++keyIndex == [salt length]) {
            keyIndex = 0, keyPtr = keyData;
        }
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

inline bool __attribute__((always_inline)) check_crack() {
    return [[NSFileManager defaultManager] fileExistsAtPath:decode(key)];
}

%group Textyle

%hook UICalloutBar

%property (nonatomic, retain) UIMenuItem *txtMainMenuItem;
%property (nonatomic, retain) NSArray *txtStyleMenuItems;

- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;

    if (!check_crack()) return self;

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

    if (!check_crack()) return;

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

static void addObservers() {
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
    addObservers();

    menuOpen = NO;
    active = NO;
    spongebobCounter = 0;

    %init(Textyle);

    if (enabled && toggleMenu) {
        %init(ToggleMenu);
    }
}
