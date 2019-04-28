#import "TXTStyleCell.h"

@implementation TXTStyleCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.frame];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:16]];

        self.label = label;
        [self.contentView addSubview:self.label];
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
