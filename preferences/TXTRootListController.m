#import "TXTRootListController.h"
#import "TXTStylesController.h"

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

@end
