//
//  MOWaveTableView.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-14.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MOTableViewDelegate <NSObject>
- (void)contentOffsetY:(CGFloat)y;
- (void)willBeginDragging;
- (void)didEndDraggingY:(CGFloat)y;
@end

@interface MOWaveTableView : UITableView
@property (nonatomic, strong) NSArray *points;
@property (nonatomic, assign) CGFloat rightSpace; 
@property (nonatomic, weak) id <MOTableViewDelegate> scrollDelegate;
@end

NS_ASSUME_NONNULL_END

