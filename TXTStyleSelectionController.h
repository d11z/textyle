@class TXTCollectionView;

@interface TXTStyleSelectionController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, retain) TXTCollectionView *collectionView;
- (void)reload;
@end
