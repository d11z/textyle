#import "Tweak.h"

static NSArray *styles;
static BOOL menuOpen = NO;

%group Textyle

%hook UICalloutBar

%property (nonatomic, retain) UIMenuItem *txtStyleMenuItem;
%property (nonatomic, retain) NSArray *txtStyles;

- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;

    if (!self.txtStyleMenuItem) {
        self.txtStyleMenuItem = [[UIMenuItem alloc] initWithTitle:@"Styles" action:@selector(txtOpenStyleMenu:)];
        self.txtStyleMenuItem.dontDismiss = YES;
    }

    if (!self.txtStyles) {
        NSMutableArray *items = [NSMutableArray array];

        for (NSDictionary *style in styles) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:style[@"label"] action:@selector(txtApplyStyle:)];
            [items addObject:item];
        }

        self.txtStyles = items;
    }

    return self;
}

- (void)updateAvailableButtons {
    %orig;

    if (!self.extraItems) {
        self.extraItems = @[];
    }

    BOOL isSelected = NO;
    NSArray *currentSystemButtons = MSHookIvar<NSArray *>(self, "m_currentSystemButtons");
    for (UICalloutBarButton *btn in currentSystemButtons) {
        if (btn.action == @selector(cut:)) {
            isSelected = YES;
        }
    }

    NSMutableArray *items = [self.extraItems mutableCopy];

    if (isSelected) {
        if (![items containsObject:self.txtStyleMenuItem]) {
            [items addObject:self.txtStyleMenuItem];
        }
    } else {
        [items removeObject:self.txtStyleMenuItem];
    }

    if (menuOpen) {
        items = [NSMutableArray array];
        for (UIMenuItem *item in self.txtStyles) {
            if (![items containsObject:item]) {
                [items addObject:item];
            }
        }
    } else {
        for (UIMenuItem *item in self.txtStyles) {
            [items removeObject:item];
        }
    }

    self.extraItems = items;

    %orig;
}

%end

%hook UIResponder

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

%new
- (void)txtApplyStyle:(id)sender {
    menuOpen = NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(txtApplyStyle:)) return menuOpen;
    if (menuOpen) return NO;
    return %orig;
}

- (BOOL)becomeFirstResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtCloseStyleMenu) name:UIMenuControllerDidHideMenuNotification object:nil];
    return %orig;
}

%end

%hook UITextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (menuOpen) return NO;
    return %orig;
}

%end

%hook CKMessageEntryRichTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (menuOpen) return NO;
    return %orig;
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
