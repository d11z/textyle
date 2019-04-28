#import "TXTStyleMenuView.h"
#import "TXTCollectionView.h"
#import "TXTConstants.h"

@implementation TXTStyleMenuView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, kMenuWidth, kMenuHeight)];

    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = kCornerRadius;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.27f;

        UIView *blurMask = [[UIView alloc] initWithFrame:self.bounds];
        blurMask.layer.cornerRadius = kCornerRadius;
        blurMask.clipsToBounds = YES;
        [self addSubview:blurMask];

        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = blurMask.bounds;
        blurView.layer.masksToBounds = NO;
        [blurMask addSubview:blurView];

        self.collectionView = [[TXTCollectionView alloc] init];
        self.collectionView.frame = self.bounds;
        self.collectionView.layer.cornerRadius = kCornerRadius;
        [self addSubview:self.collectionView];
    }

    return self;
}

@end
