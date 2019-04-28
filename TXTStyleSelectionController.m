#import "TXTStyleSelectionController.h"
#import "TXTCollectionView.h"
#import "TXTStyleCell.h"
#import "TXTStyleManager.h"
#import "TXTStyleMenuView.h"
#import "TXTConstants.h"

@implementation TXTStyleSelectionController {
    NSArray *styles;
    TXTStyleMenuView *menuView;
    NSString *activeStyle;
    NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupMenuView];
    [self load];
}

- (void)load {
    TXTStyleManager *styleManager = [TXTStyleManager sharedManager];
    styles = [styleManager enabledStyles];
    activeStyle = [styleManager activeStyle][@"name"];

    [self selectActiveStyle];
}

- (void)reload {
    [self load];
    [self.collectionView reloadData];
}

- (void)selectActiveStyle {
    NSUInteger index = [styles indexOfObjectPassingTest:^BOOL (NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        return [[dict objectForKey:@"name"] isEqual:activeStyle];
    }];

    selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];

    [self.collectionView selectItemAtIndexPath:selectedIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:selectedIndexPath];
}

- (void)setupMenuView {
    menuView = [[TXTStyleMenuView alloc] init];
    menuView.collectionView.delegate = self;
    menuView.collectionView.dataSource = self;
    [menuView.collectionView registerClass:[TXTStyleCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    self.collectionView = menuView.collectionView;

    CGSize size = self.view.frame.size;
    [menuView setCenter:CGPointMake(size.width / 2, size.height / 3)];
    [self.view addSubview:menuView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TXTStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];

    cell.name = styles[indexPath.row][@"name"];
    [cell.label setText:styles[indexPath.row][@"label"]];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return styles.count;
}

- (void)actuateHapticFeedback {
    UIImpactFeedbackGenerator *hapticFeedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];

    [hapticFeedbackGenerator prepare];
    [hapticFeedbackGenerator impactOccurred];
    hapticFeedbackGenerator = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    [self actuateHapticFeedback];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
                     }
                     completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor clearColor]];
                     }
                     completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;

    TXTStyleCell *cell = (TXTStyleCell *)[collectionView cellForItemAtIndexPath:indexPath];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor colorWithRed:1.00 green:0.18 blue:0.33 alpha:1.0f]];
                     }
                     completion:nil];

    if (cell.name && ![cell.name isEqualToString:activeStyle]) {
        [[TXTStyleManager sharedManager] selectStyle:cell.name];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor clearColor]];
                     }
                     completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:selectedIndexPath]) {
        [cell setBackgroundColor:[UIColor colorWithRed:1.00 green:0.18 blue:0.33 alpha:1.0f]];
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

@end
