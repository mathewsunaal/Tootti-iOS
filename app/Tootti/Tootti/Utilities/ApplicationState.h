//
//  SharedInstance.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-22.
//
#import "Session.h"
#import "AppDelegate.h"

@interface ApplicationState: NSObject

@property (nonatomic, strong) Session* currentSession;

+ (ApplicationState*) sharedInstance;
+(void)logout;
+ (void)close;



@end
