#import <Foundation/Foundation.h>

@interface QualifioIntegrationBridge : NSObject

+ (void)invoke:(NSObject *_Nonnull)target
        selectorName:(NSString *_Nonnull)selectorName
            campaign:(NSString *_Nonnull)campaign
          completion:(void (^_Nonnull)(NSError * _Nullable error))completion;

@end
