#import "TXTStyleSelectionWindow.h"
#import "TXTStyleSelectionController.h"

@implementation TXTStyleSelectionWindow {
    TXTStyleSelectionController *controller;
}

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];

    if (self) {
        controller = [[TXTStyleSelectionController alloc] init];
        self.rootViewController = controller;
        [self addSubview:controller.view];
    }

    return self;
}

- (void)show {
    self.alpha = 0;
    self.hidden = NO;
    self.windowLevel = 20000000;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:nil];
}

- (void)hide {
    [self hideWithDelay:0];
}

- (void)hideWithDelay:(NSTimeInterval)delay {
    [UIView animateWithDuration:0.15
                          delay:delay
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.hidden = YES;
                     }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hide];
}

- (void)reload {
    [controller reload];
}

@end
