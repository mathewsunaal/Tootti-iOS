//
//  SharedInstance.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-22.
//

#import "ApplicationState.h"
#import <Foundation/Foundation.h>

static ApplicationState* sharedInstance = nil;

@implementation ApplicationState

+ (ApplicationState*)sharedInstance {
    @synchronized (self) {
        if(sharedInstance==nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+(void)logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"joinedSessions"];
}

+(void)close {
    [sharedInstance.currentSession updateCurrentPlayerListWithActivity:NO
                                             username:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]
                                                  uid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]
                                      completionBlock:nil];
    //destroy all global instances
    [self destroyInstance];
}

+(void)destroyInstance {
    sharedInstance.currentSession = nil;
    sharedInstance = nil;
}

@end
