#import <Foundation/Foundation.h>

@interface QualifioIntegrationBridge : NSObject

+ (NSException * _Nullable)tryBlock:(void (^_Nonnull)(void))block;

@end
