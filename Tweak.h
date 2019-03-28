@interface UICalloutBar : UIView

@property (nonatomic, retain) NSArray *extraItems;
@property (nonatomic, retain) UIMenuItem *txtMainMenuItem;
@property (nonatomic, retain) NSArray *txtStyleMenuItems;

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


@interface UIResponder (Textyle)

- (NSRange)_selectedNSRange;
- (id)_fullText;
- (void)replaceRange:(id)arg1 withText:(id)arg2;
- (id)_textRangeFromNSRange:(NSRange)arg1;

- (void)txtDidSelectStyle:(NSString *)name;
- (void)txtReplaceSelectedText:(NSDictionary *)map;

@end
