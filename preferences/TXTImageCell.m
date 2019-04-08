#import "TXTImageCell.h"
#import <Preferences/PSSpecifier.h>

@implementation TXTImageCell {
    UIImageView *_imageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _imageView = [[UIImageView alloc] initWithImage:specifier.properties[@"iconImage"]];
        _imageView.frame = self.contentView.bounds;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.minificationFilter = kCAFilterTrilinear;
        [self.contentView addSubview:_imageView];

        self.imageView.hidden = YES;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
    }

    return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return _imageView.image.size.height;
}

@end
