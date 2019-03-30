#import "TXTStylesController.h"

@implementation TXTStylesController {
    NSArray *styles;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   self.title = @"Edit Styles";
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];

        PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Installed Styles"];
        [group setProperty:@"To add/modify/rearrange styles, edit the styles.plist file stored in /Library/Application Support/Textyle" forKey:@"footerText"];

        [specifiers addObject:group];

        [self loadStyles];

        for (NSDictionary *style in styles) {
            PSSpecifier *item = [PSSpecifier preferenceSpecifierNamed:style[@"label"]
                                                            target:self
                                                            set:@selector(setPreferenceValue:specifier:)
                                                            get:@selector(readPreferenceValue:)
                                                            detail:Nil
                                                            cell:PSSwitchCell
                                                            edit:Nil];

            [item setProperty:style[@"name"] forKey:@"key"];
            [item setProperty:@YES forKey:@"enabled"];
            [item setProperty:@YES forKey:@"default"];
            [item setProperty:@"com.d11z.textyle.styles" forKey:@"defaults"];
            [item setProperty:@"com.d11z.textyle.styles/ReloadPrefs" forKey:@"PostNotification"];
            [specifiers addObject:item];
        }

        _specifiers = [specifiers copy];
    }

    return _specifiers;
}

- (void)loadStyles {
    NSString *filePath = [[NSBundle bundleWithPath:@"/Library/Application Support/Textyle"] pathForResource:@"styles" ofType:@"plist"];
    styles = [[NSArray alloc] initWithContentsOfFile:filePath];
}

@end
