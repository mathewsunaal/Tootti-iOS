//
//  SharedInstance.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-22.
//

#import "ApplicationState.h"
#import <Foundation/Foundation.h>

@implementation ApplicationState

+ (ApplicationState*) sharedInstance
{
    static ApplicationState* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end
