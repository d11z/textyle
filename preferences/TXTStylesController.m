#import "TXTStylesController.h"
#import <Preferences/PSSpecifier.h>

#define kUserStylesPath @"/var/mobile/Library/Preferences/com.d11z.textyle.maps.plist"

@implementation TXTStylesController {
    NSArray *styles;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Edit Styles";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self loadStyles];
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];

        PSSpecifier *group = [PSSpecifier groupSpecifierWithName:@"Installed Styles"];
        [group setProperty:@"To add/modify styles, edit /var/mobile/Library/Preferences/com.d11z.textyle.maps.plist" forKey:@"footerText"];

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
            [item setProperty:@"com.d11z.textyle.styles/enabledStyles" forKey:@"PostNotification"];
            [specifiers addObject:item];
        }

        _specifiers = [specifiers copy];
    }

    return _specifiers;
}

- (void)loadStyles {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:kUserStylesPath]) {
        styles = [[NSArray alloc] initWithContentsOfFile:@"/Library/Application Support/Textyle/styles.plist"];
        [styles writeToFile:kUserStylesPath atomically:YES];
    } else {
        styles = [[NSArray alloc] initWithContentsOfFile:kUserStylesPath];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:animated];

    if (!editing) {
        [styles writeToFile:kUserStylesPath atomically:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSDictionary *item = [styles objectAtIndex:sourceIndexPath.row];
    NSMutableArray *stylesEdited = [styles mutableCopy];

    [stylesEdited removeObjectAtIndex:sourceIndexPath.row];
    [stylesEdited insertObject:item atIndex:destinationIndexPath.row];

    styles = stylesEdited;
}

@end
