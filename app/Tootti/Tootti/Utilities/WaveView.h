//
//  WaveView.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WaveView : UIView {
    NSMutableArray *averagePointArray;
    NSMutableArray *peakPointArray;
}

- (void) addAveragePoint:(CGFloat)averagePoint andPeakPoint:(CGFloat)peakPoint;
// p (averagePoint, peakPoint)
//- (void) addAveragePoint:(CGPoint)p;

@end
