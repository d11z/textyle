@interface TXTStyleManager : NSObject
@property (nonatomic, strong) NSDictionary *activeStyle;
@property (nonatomic, strong) NSArray *enabledStyles;
+ (instancetype)sharedManager;
- (void)initForSpringBoard;
- (void)selectStyle:(NSString *)name;
- (void)loadActiveStyle;
- (NSDictionary *)styleWithName:(NSString *)name;
@end
