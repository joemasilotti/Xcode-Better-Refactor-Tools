#import <Foundation/Foundation.h>
#import <ClangKit/ClangKit.h>

@interface XMASObjcSelector : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTokens:(NSArray *)tokens;

- (NSString *)selectorString;

@end