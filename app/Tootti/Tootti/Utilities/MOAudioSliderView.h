//
//  WVAudioSliderView.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-14.
//

#import <UIKit/UIKit.h>
extern NSInteger const cellHeight;
extern NSInteger const kAudioPlayerLineSpacing;

NS_ASSUME_NONNULL_BEGIN

@interface MOAudioSliderView : UIView

- (instancetype)initWithFrame:(CGRect)frame playUrl:(NSURL *)playUrl points:(NSArray *)points;

@end

NS_ASSUME_NONNULL_END
