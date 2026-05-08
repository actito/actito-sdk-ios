#import "QualifioIntegrationBridge.h"

@implementation QualifioIntegrationBridge

+ (void)invoke:(NSObject *)target
  selectorName:(NSString *)selectorName
      campaign:(NSString *)campaign
    completion:(void (^)(NSError * _Nullable))completion {

    SEL selector = NSSelectorFromString(selectorName);

    if (![target respondsToSelector:selector]) {
        if (completion) {
            completion([NSError errorWithDomain:@"QualifioIntegrationBridge"
                                           code:0
                                       userInfo:@{NSLocalizedDescriptionKey: @"Class method not found."}]);
        }

        return;
    }

    if (![self hasValidMethodSignature:target
                              selector:selector]) {
        if (completion) {
            completion([NSError errorWithDomain:@"QualifioIntegrationBridge"
                                           code:0
                                       userInfo:@{NSLocalizedDescriptionKey: @"Invalid method signature."}]);
        }

        return;
    }

    @try {
        typedef void (*Func)(NSObject *, SEL, NSString *, void (^)(NSError * _Nullable));

        IMP imp = [target methodForSelector:selector];
        Func func = (Func)imp;

        func(target, selector, campaign, completion);
    } @catch (NSException *exception) {
        if (completion) {
            completion([NSError errorWithDomain:@"QualifioIntegrationBridge"
                                           code:0
                                       userInfo:@{
                NSLocalizedDescriptionKey: exception.reason ?: @"Unknown",
                @"exception": exception.name ?: @"UnknownException"
            }]);
        }
    }
}

+ (BOOL)hasValidMethodSignature:(NSObject *)target
                       selector:(SEL)selector {

    NSMethodSignature *signature = [target methodSignatureForSelector:selector];

    if (!signature) {
        return NO;
    }

    if (strcmp(signature.methodReturnType, "v") != 0) {
        return NO;
    }

    if (signature.numberOfArguments != 4) {
        return NO;
    }

    if (strcmp([signature getArgumentTypeAtIndex:2], "@") != 0) {
        return NO;
    }

    if (strcmp([signature getArgumentTypeAtIndex:3], "@?") != 0) {
        return NO;
    }

    return YES;
}

@end
