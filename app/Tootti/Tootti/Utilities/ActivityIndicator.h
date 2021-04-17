//
//  ActivityIndicator.h
//  Tootti
//
//  Created by Sunaal Philip Mathew on 2021-04-02.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ActivityIndicator : UIActivityIndicatorView

+(id)sharedInstance;
-(void)startWithSuperview:(UIView *)view;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
