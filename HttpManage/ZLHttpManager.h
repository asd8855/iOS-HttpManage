//
//  ZLHttpManager.h
//  HttpManage
//
//  Created by libo on 2018/11/14.
//  Copyright © 2018 Cicada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *ZLNetWorkUnknownNotification          = @"ZLNetWorkUnknownNotification";
static NSString *ZLNetWorkNotReachableNotification     = @"ZLNetWorkNotReachableNotification";
static NSString *ZLNetWorkReachableViaWWANNotification = @"ZLNetWorkReachableViaWWANNotification";
static NSString *ZLNetWorkReachableViaWiFiNotification = @"ZLNetWorkReachableViaWiFiNotification";

@interface ZLHttpManager : NSObject
    
@property (nonatomic, copy) NSString *baseURL;

    
+ (void)dataTaskUrlString:(NSString *)urlString
               parameters:(NSDictionary *)parameters
        completionHandler:(void (^)(id dataObject, NSError *error))completionHandler;
    
@end

NS_ASSUME_NONNULL_END
