//
//  ActivityIndicator.m
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-04-02.
//

#import "ActivityIndicator.h"

@implementation ActivityIndicator

+(id)sharedInstance {
    static ActivityIndicator *sharedIndicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIndicator = [[ActivityIndicator alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        sharedIndicator.hidesWhenStopped = YES;
        //[sharedIndicator setBackgroundColor:[UIColor systemBackgroundColor]];
    });
    return sharedIndicator;
}

-(void)startWithSuperview:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addSubview:self];
        self.center = CGPointMake([[UIScreen mainScreen]bounds].size.width/2, [[UIScreen mainScreen]bounds].size.height/2);
        [self.superview setAlpha:0.7]; // gray out background
        [self startAnimating];
    });
}

-(void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.superview setAlpha:1.0];
        [self stopAnimating];
        [self removeFromSuperview];
    });
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
