//
//  ZLHttpManager.m
//  HttpManage
//
//  Created by libo on 2018/11/14.
//  Copyright © 2018 Cicada. All rights reserved.
//

#import "ZLHttpManager.h"

@implementation ZLHttpManager

+ (instancetype )sharedInstance {
    
    static ZLHttpManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[super alloc] init];
    });
    return sharedInstance;
}

    
+ (AFHTTPSessionManager *)manager {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [manager.requestSerializer setValue:@"12.0.1" forHTTPHeaderField:@"clientos"];
        [manager.requestSerializer setValue:@"0.9.2" forHTTPHeaderField:@"appversion"];
        [manager.requestSerializer setValue:@"iPhone SE" forHTTPHeaderField:@"clientmodel"];
        [manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"clienttype"];
        [manager.requestSerializer setValue:@"soeasypayschool" forHTTPHeaderField:@"app"];
        [manager.requestSerializer setValue:@"302BBA5C-9354-4DA0-93A2-2B7AE956EF87" forHTTPHeaderField:@"idfv"];
        [manager.requestSerializer setValue:@"app5bebc29f03321e603b9cc137" forHTTPHeaderField:@"token"];
        
        [manager.reachabilityManager startMonitoring];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZLNetWorkUnknownNotification object:nil];
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZLNetWorkReachableViaWWANNotification object:nil];
                    break;
                }
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZLNetWorkReachableViaWiFiNotification object:nil];
                    break;
                }
                case AFNetworkReachabilityStatusNotReachable:
                default:{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZLNetWorkNotReachableNotification object:nil];
                    break;
                }
            }
        }];
    });
    
    return manager;
}
    

// GET 请求
+ (NSMutableURLRequest *)getRequest:(AFHTTPRequestSerializer *)requestSerializer
                          urlString:(NSString *)urlString
                                  parameters:(NSDictionary *)parameters
                                       error:(NSError *__autoreleasing *)error {

   return [requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:parameters error:error] ;
}
  
// POST 请求 JSON Parameter Encoding
+ (NSMutableURLRequest *)postJsonRequestUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                            error:(NSError *__autoreleasing *)error {
    return [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:error];
}
    
// POST 请求 URL Form Parameter Encoding
+ (NSMutableURLRequest *)postFormRequestUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                            error:(NSError *__autoreleasing *)error {
    return [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:error];
}


// Creating a Data Task
+ (void)dataTaskUrlString:(NSString *)urlString
               parameters:(NSDictionary *)parameters
        completionHandler:(void (^)(id dataObject, NSError *error))completionHandler {

    AFHTTPSessionManager *manager = [ZLHttpManager manager];
   
    NSString *baseURL = [ZLHttpManager sharedInstance].baseURL;
    if(!baseURL) {
        baseURL = @"https://www.soeasypay.cn";
    }
    
    urlString =[[NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:baseURL]] absoluteString];
    
    NSError *error = nil;
    NSMutableURLRequest *request = [ZLHttpManager getRequest:manager.requestSerializer urlString:urlString parameters:parameters error:&error];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if(error) {
                completionHandler(@"请求失败", error);
            }else {
                completionHandler(responseObject, error);
            }
    }];
    
    [dataTask resume];
    
}
    
// Creating a Download Task
+ (void)downloadTaskDownloadURL:(NSString *)downloadURL {

    AFHTTPSessionManager *manager = [ZLHttpManager manager];

    NSURLRequest *reuqest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:reuqest progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
       
        // 指定下载文件的存放路径
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    
    [downloadTask resume];
}
 
    
// Creating an Upload Task
+ (void)uploadTaskUrlString:(NSString *)urlString fileURL:(NSString *)fileURL {
   
    AFHTTPSessionManager *manager = [ZLHttpManager manager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURL *filePath = [NSURL fileURLWithPath:fileURL];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error) {
            NSLog(@"%@",error);
        }else {
            NSLog(@"%@",responseObject);
        }
    }];
    
    [uploadTask resume];
}
    
    
// Creating an Upload Task for a Multi-Part Request, with Progress
+ (void)multiUploadTaskUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {

    AFHTTPSessionManager *manager = [ZLHttpManager manager];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"file://path/to/image.jpg"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
}
    
@end
