#import "Tweak.h"

static NSString *stylizeTextWithMap(NSString *text, NSDictionary *map) {
    NSMutableString *stylized = [NSMutableString string];
    NSUInteger length = text.length;
    unichar buffer[length+1];

    [text getCharacters:buffer range:NSMakeRange(0, length)];

    for (int i = 0; i < length; i++) {
        NSString *key = [NSString stringWithFormat:@"%C", buffer[i]];

        if ([map objectForKey:key]) {
            [stylized appendString:map[key]];
        } else {
            [stylized appendString:key];
        }
    }

    return stylized;
}

static NSArray *styles;
static BOOL menuOpen = NO;

%group Textyle

%hook UICalloutBar

%property (nonatomic, retain) UIMenuItem *txtMainMenuItem;
%property (nonatomic, retain) NSArray *txtStyleMenuItems;

- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;

    if (!self.txtMainMenuItem) {
        self.txtMainMenuItem = [[UIMenuItem alloc] initWithTitle:@"Styles" action:@selector(txtOpenStyleMenu:)];
        self.txtMainMenuItem.dontDismiss = YES;
    }

    if (!self.txtStyleMenuItems) {
        NSMutableArray *items = [NSMutableArray array];

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

    if (!self.extraItems) {
        self.extraItems = @[];
    }

    BOOL isSelected = NO;
    NSMutableArray *currentSystemButtons = MSHookIvar<NSMutableArray *>(self, "m_currentSystemButtons");
    for (UICalloutBarButton *btn in currentSystemButtons) {
        if (btn.action == @selector(cut:)) {
            isSelected = YES;
        }
    }

    NSMutableArray *items = [self.extraItems mutableCopy];

    if (isSelected) {
        if (![items containsObject:self.txtMainMenuItem]) {
            [items addObject:self.txtMainMenuItem];
        }
    } else {
        [items removeObject:self.txtMainMenuItem];
    }

    if (menuOpen) {
        items = [NSMutableArray array];
        for (UIMenuItem *item in self.txtStyleMenuItems) {
            if (![items containsObject:item]) {
                [items addObject:item];
            }
        }
    } else {
        for (UIMenuItem *item in self.txtStyleMenuItems) {
            [items removeObject:item];
        }
    }

    self.extraItems = items;

    %orig;

    if (menuOpen) {
        [currentSystemButtons removeAllObjects];
    }
}

%end

%hook UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (match.location == 0) return menuOpen;
    if (menuOpen) return NO;
    return %orig;
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
- (void)txtReplaceSelectedText:(NSDictionary *)map {
    NSRange selectedRange = [self _selectedNSRange];
    NSString *original = [self _fullText];
    NSString *selectedText = [original substringWithRange:selectedRange];
    NSString *stylized = stylizeTextWithMap(selectedText, map);

    UITextRange *textRange = [self _textRangeFromNSRange:selectedRange];
    [self replaceRange:textRange withText:stylized];
}

%new
- (void)txtDidSelectStyle:(NSString *)name {
    menuOpen = NO;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", name];
    NSArray *arr = [styles filteredArrayUsingPredicate:predicate];
    NSDictionary *style = [arr objectAtIndex:0];

    [self txtReplaceSelectedText:style[@"map"]];
}

%end

%hook UITextField

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (%orig(sel)) {
        return %orig(sel);
    }
    return %orig(@selector(txtDidSelectStyle:));
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (match.location == 0) {
        [self txtDidSelectStyle:[sel substringFromIndex:4]];
    } else {
        %orig(invocation);
    }
}

%end

%hook UITextView

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (%orig(sel)) {
        return %orig(sel);
    }
    return %orig(@selector(txtDidSelectStyle:));
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:@"txt_"];

    if (match.location == 0) {
        [self txtDidSelectStyle:[sel substringFromIndex:4]];
    } else {
        %orig(invocation);
    }
}

%end

%end

%ctor {
    // Someone smarter than me invented this.
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    bool shouldLoad = NO;
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if (!isFileProvider && isApplication && !skip) {
                shouldLoad = YES;
            }
        }
    }

    if (!shouldLoad) return;

    NSString *filePath = [[NSBundle bundleWithPath:@"/Library/Application Support/Textyle"] pathForResource:@"styles" ofType:@"plist"];
    styles = [[NSArray alloc] initWithContentsOfFile:filePath];

    %init(Textyle);
}
