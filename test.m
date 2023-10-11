//
//  test.m
//  test
//
//  Created by sqy on 2023/10/8.
//

#import "test.h"
#import "Carbon/Carbon.h"

@implementation test
+ (void)switchTo:(const char *)key {
    if ([NSThread isMainThread]) {
        [self doSwitchTo : key];
    } else{
        // 这里根据自己的需要也可以换成 dispatch_async
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self doSwitchTo : key];
        });
    }

}

+ (void)doSwitchTo:(const char *)key {
    // 目标输入法ID
    NSString* targetInputSourceID = [[NSString alloc] initWithCString:key encoding:NSUTF8StringEncoding];
    // 获取当前 InputSourceRef
    TISInputSourceRef current = TISCopyCurrentKeyboardInputSource();
    // NSLog(@"当前输入法:%@", current);
    CFArrayRef currentInputSourceIDArrayRef = TISGetInputSourceProperty(current, kTISPropertyInputSourceID);
    NSArray *currentInputSourceIDArray = (__bridge NSArray *)currentInputSourceIDArrayRef;
    NSString *currentInputSourceID = NULL;
    if ([currentInputSourceIDArray isKindOfClass:[NSString class]]) {
        currentInputSourceID = (NSString *)currentInputSourceIDArray;
    } else {
        currentInputSourceID = [currentInputSourceIDArray componentsJoinedByString:@","];
    }
    // 已经是目标输入法，返回
    if ([targetInputSourceID isEqualToString:currentInputSourceID]) {
        // NSLog(@"当前输入法ID已经是:%@",targetInputSourceID);
        return;
    }
    // 获取当前所有可用的 InputSourceRef，遍历
    CFArrayRef ref = TISCreateInputSourceList(nil,false);
    NSArray *inputSourceArray = (__bridge NSArray *)ref;
    for (int i=0; i<[inputSourceArray count]; i++) {
        CFArrayRef inputSourceIDArrayRef = TISGetInputSourceProperty((__bridge TISInputSourceRef)(inputSourceArray[i]), kTISPropertyInputSourceID);
        NSArray *inputSourceIDArray = (__bridge NSArray*)inputSourceIDArrayRef;
        NSString *inputSourceID = NULL;
        if ([inputSourceIDArray isKindOfClass:[NSString class]]) {
            inputSourceID = (NSString *)inputSourceIDArray;
        } else {
            inputSourceID = [inputSourceIDArray componentsJoinedByString:@","];
        }
        if ([targetInputSourceID isEqualToString:inputSourceID]) {
            // NSLog(@"切换至输入法:%@",targetInputSourceID);
            OSStatus res =  TISSelectInputSource((__bridge TISInputSourceRef)(inputSourceArray[i]));
            if (res != noErr) {
                // NSLog(@"切换至输入法:%@失败!",targetInputSourceID);
            } else {
                // NSLog(@"切换至输入法:%@成功!",targetInputSourceID);
            }
        }
    }
}

@end
