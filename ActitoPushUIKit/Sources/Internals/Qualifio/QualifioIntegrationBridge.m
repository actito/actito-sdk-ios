#import "QualifioIntegrationBridge.h"

@implementation QualifioIntegrationBridge

+ (NSException * _Nullable)tryBlock:(void (^)(void))block {
    @try {
        block();
        return nil;
    } @catch (NSException *exception) {
        return exception;
    }
}

@end
