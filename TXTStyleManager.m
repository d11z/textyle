#import "TXTStyleManager.h"
#import "TXTConstants.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface TXTStyleManager ()

static void TXTActiveStyleChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
);

static void TXTEnabledStylesChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
);

@end

@implementation TXTStyleManager {
    NSArray *styles;
}

+ (instancetype)sharedManager {
    static TXTStyleManager *sharedManager;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self loadEnabledStyles];
        [self loadActiveStyle];
        [self registerObservers];
    }

    return self;
}

- (void)registerObservers {
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)TXTActiveStyleChanged,
        CFSTR("com.d11z.textyle.styles/activeStyle"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)TXTEnabledStylesChanged,
        CFSTR("com.d11z.textyle.styles/enabledStyles"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );
}

- (void)loadActiveStyle {
    NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:kPrefsPath];
    NSString *styleName = [preferences objectForKey:@"ActiveStyle"];

    NSUInteger index = [self.enabledStyles indexOfObjectPassingTest:^BOOL (NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        return [[dict objectForKey:@"name"] isEqual:styleName];
    }];

    if (!styleName || index >= [self.enabledStyles count]) {
        styleName = self.enabledStyles[0][@"name"];
    }

    self.activeStyle = [self styleWithName:styleName];
}

// server
- (void)initForSpringBoard {
    NSLog(@"[Textyle] initForSpringBoard");

    CPDistributedMessagingCenter *messageCenter = [CPDistributedMessagingCenter centerNamed:kMessageCenter];
    rocketbootstrap_distributedmessagingcenter_apply(messageCenter);
    [messageCenter runServerOnCurrentThread];
    [messageCenter registerForMessageName:kSetActiveStyle target:self selector:@selector(handleMessageNamed:withUserInfo:)];
}

- (void)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    self.activeStyle = [self styleWithName:userInfo[@"name"]];
    [self saveActiveStyle];
}

- (void)saveActiveStyle {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:kPrefsPath];

    [preferences setObject:self.activeStyle[@"name"] forKey:@"ActiveStyle"];
    [preferences writeToFile:kPrefsPath atomically:YES];

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.d11z.textyle.styles/activeStyle"),
        NULL,
        NULL,
        YES
    );
}

// client
- (void)selectStyle:(NSString *)name {
    self.activeStyle = [self styleWithName:name];

    CPDistributedMessagingCenter *messageCenter = [CPDistributedMessagingCenter centerNamed:kMessageCenter];
    rocketbootstrap_distributedmessagingcenter_apply(messageCenter);
    [messageCenter sendMessageName:kSetActiveStyle userInfo:@{ @"name": name }];
}

- (NSDictionary *)styleWithName:(NSString *)name {
    NSUInteger index = [styles indexOfObjectPassingTest:^BOOL (NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        return [[dict objectForKey:@"name"] isEqual:name];
    }];

    return [styles objectAtIndex:index];
}

- (void)loadStyles {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:kUserStylesPath]) {
        styles = [[NSArray alloc] initWithContentsOfFile:kSystemStylesPath];
    } else {
        styles = [[NSArray alloc] initWithContentsOfFile:kUserStylesPath];
    }
}

- (void)loadEnabledStyles {
    [self loadStyles];

    NSDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:kEnabledStylesPath];

    if (!preferences) {
        self.enabledStyles = styles;
    } else {
        NSMutableArray *enabledStyles = [NSMutableArray array];

        for (NSDictionary *style in styles) {
            if ([[preferences objectForKey:style[@"name"]] boolValue]) {
                [enabledStyles addObject:style];
            }
        }

        self.enabledStyles = [enabledStyles copy];
    }
}

static void TXTActiveStyleChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
) {
    [[TXTStyleManager sharedManager] loadActiveStyle];
}

static void TXTEnabledStylesChanged(
    CFNotificationCenterRef center,
    void *observer,
    CFStringRef name,
    const void *object,
    CFDictionaryRef userInfo
) {
    TXTStyleManager *styleManager = [TXTStyleManager sharedManager];

    [styleManager loadEnabledStyles];
    [styleManager loadActiveStyle];
}

@end
