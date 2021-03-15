//
//  MOTimeTableView.h
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOTimeTableView : UITableView

@property (nonatomic, strong) NSArray *points;
@property (nonatomic, assign) CGFloat rightSpace; 

@end

NS_ASSUME_NONNULL_END
