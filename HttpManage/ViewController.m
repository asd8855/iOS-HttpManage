//
//  ViewController.m
//  HttpManage
//
//  Created by libo on 2018/11/14.
//  Copyright © 2018 Cicada. All rights reserved.
//

#import "ViewController.h"
#import "ZLHttpManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onGet:(id)sender {
    
    [ZLHttpManager dataTaskUrlString:@"/api/app/teacher/school/schools" parameters:@{@"schoolNo":@"61010300000140"} completionHandler:^(id  _Nonnull dataObject, NSError * _Nonnull error) {
        if(error) {
            NSLog(@"%@", error);
        }else {
            NSLog(@"%@", dataObject);
        }
    }];
    NSLog(@"GET");
}
- (IBAction)onPost:(id)sender {
    NSLog(@"POST");

}
    
@end
