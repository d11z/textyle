#define kPrefsPath @"/var/mobile/Library/Preferences/com.d11z.textyle.plist"
#define kSystemStylesPath @"/Library/Application Support/Textyle/styles.plist"
#define kUserStylesPath @"/var/mobile/Library/Preferences/com.d11z.textyle.maps.plist"
#define kEnabledStylesPath @"/var/mobile/Library/Preferences/com.d11z.textyle.styles.plist"

#define kTintColor [UIColor colorWithRed:1.00 green:0.18 blue:0.33 alpha:0.85f]
#define kMenuIcon @"/Library/PreferenceBundles/Textyle.bundle/menuIcon.png"
#define kDefaultMenuLabel @"Styles"

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
-(void)setupWithTitle:(id)arg1 action:(SEL)arg2 type:(int)arg3;
-(void)setupWithImage:(id)arg1 action:(SEL)arg2 type:(int)arg3;
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

@interface UIImageView (Textyle)
- (long long)_defaultRenderingMode;
@end
