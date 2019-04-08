#import "TXTRootListController.h"
#import "TXTStylesController.h"
#import "SparkAppListTableViewController.h"

@implementation TXTRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    return _specifiers;
}

- (void)showStylesController {
    TXTStylesController *child = [[TXTStylesController alloc] init];
    [self.navigationController pushViewController:child animated:YES];
}

- (void)showBlacklistController {
    SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"com.d11z.textyle" andKey:@"Blacklist"];
    [self.navigationController pushViewController:s animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]]];

    if (![prefs objectForKey:[specifier.properties objectForKey:@"key"]]) {
        return [specifier.properties objectForKey:@"default"];
    }

    return [prefs objectForKey:[specifier.properties objectForKey:@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]]];

    [prefs setObject:value forKey:[specifier.properties objectForKey:@"key"]];
    [prefs writeToFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", [specifier.properties objectForKey:@"defaults"]] atomically:YES];

    if ([specifier.properties objectForKey:@"PostNotification"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)[specifier.properties objectForKey:@"PostNotification"], NULL, NULL, YES);
    }

    [super setPreferenceValue:value specifier:specifier];
}

@end
