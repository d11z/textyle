@interface UICalloutBar : UIView

@property (nonatomic, retain) NSArray *extraItems;
@property (nonatomic, retain) UIMenuItem *txtStyleMenuItem;
@property (nonatomic, retain) NSArray *txtStyles;

+ (id)sharedCalloutBar;
- (void)update;
- (void)resetPage;

@end


@interface UICalloutBarButton : UIButton

@property (nonatomic, assign) SEL action;

@end


@interface UIMenuItem (Textyle)

@property (assign, nonatomic) BOOL dontDismiss;

@end
