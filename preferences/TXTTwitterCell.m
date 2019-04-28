#import "TXTTwitterCell.h"
#import <Preferences/PSSpecifier.h>

@implementation TXTTwitterCell {
    NSString *_user;
}

+ (NSString *)_urlForUsername:(NSString *)user {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion://"]]) {
        return [@"aphelion://profile/" stringByAppendingString:user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [@"tweetbot:///user_profile/" stringByAppendingString:user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [@"twitterrific:///profile?screen_name=" stringByAppendingString:user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [@"tweetings:///user?screen_name=" stringByAppendingString:user];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        return [@"twitter://user?screen_name=" stringByAppendingString:user];
    } else {
        return [@"https://mobile.twitter.com/" stringByAppendingString:user];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
    _user = [specifier.properties[@"user"] copy];

    if (self) {
        specifier.cellType = PSLinkCell;
        specifier.buttonAction = @selector(txt_openURL:);
        specifier.properties[@"url"] = [self.class _urlForUsername:_user];

        self.detailTextLabel.text = [@"@" stringByAppendingString:_user];
        self.detailTextLabel.textColor = [UIColor colorWithWhite:142.f / 255.f alpha:1];

        CGFloat size = 36.f;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
        specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = size / 2;
        [self.imageView addSubview:_avatarView];

        _avatarImageView = [[UIImageView alloc] initWithFrame:_avatarView.bounds];
        _avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarImageView.alpha = 0;
        _avatarImageView.userInteractionEnabled = NO;
        _avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
        [_avatarView addSubview:_avatarImageView];

        [self loadAvatar];
    }

    return self;
}

- (UIImage *)avatarImage {
    return _avatarImageView.image;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
    _avatarImageView.image = avatarImage;

    if (_avatarImageView.alpha == 0) {
        [UIView animateWithDuration:0.15 animations:^{
                                             _avatarImageView.alpha = 1;
                                         }];
    }
}

- (void)loadAvatar {
    if (!_user) {
        return;
    }

    if (self.avatarImage) {
        return;
    }

    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.d11z.textyle.avatar", DISPATCH_QUEUE_SERIAL);
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@/profile_image?size=original", _user]]] returningResponse:nil error:&error];

        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }

        UIImage *image = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImage = image;
        });
    });
}

@end
