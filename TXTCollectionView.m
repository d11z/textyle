#import "TXTCollectionView.h"
#import "TXTStyleCell.h"

@implementation TXTCollectionView

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(230, 48);

    self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }

    return self;
}

@end
