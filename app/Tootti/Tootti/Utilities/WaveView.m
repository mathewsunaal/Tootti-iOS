//
//  WaveView.m
//  Tootti
//
//  Created by Hanyu Xi on 2021-03-13.
//

#import "WaveView.h"

@implementation WaveView

- (id) initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame] )) {
        averagePointArray = [[NSMutableArray alloc] initWithCapacity:frame.size.width];
        peakPointArray = [[NSMutableArray alloc] initWithCapacity:frame.size.width];
        for (int i =0; i < frame.size.width; i++) {
            [averagePointArray addObject:[NSNumber numberWithFloat:0.0f]];
            [peakPointArray addObject:[NSNumber numberWithFloat:0.0f]];
        }
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}
- (void) addAveragePoint:(CGFloat)averagePoint andPeakPoint:(CGFloat)peakPoint {
    [averagePointArray removeObjectAtIndex:0];
    [averagePointArray addObject:[NSNumber numberWithFloat:averagePoint]];
    [peakPointArray removeObjectAtIndex:0];
    [peakPointArray addObject:[NSNumber numberWithFloat:peakPoint]];

    [self setNeedsDisplay];

}

- (void)drawInContext:(CGContextRef)context
{
    //Line color and size starts
    CGColorRef colorRef = [[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:20.0/255.0 alpha:1] CGColor];
    CGContextSetStrokeColorWithColor(context, colorRef);
    CGContextSetLineWidth(context, 3.0f);
    //Line color and size stops
    CGContextClearRect(context, self.bounds);
    //Background color start
    CGContextSetRGBFillColor(context, 64.0f/255.0f, 224.0f/255.0f, 208.0f/255.0f, 1.0f);
    CGContextFillRect(context, self.bounds);
    //Background color stop
    CGPoint firstPoint = CGPointMake(0.0f, [[averagePointArray objectAtIndex:0] floatValue]);

    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < [peakPointArray count]; i++)
    {
        CGPoint point = CGPointMake(i, self.bounds.size.height-([[averagePointArray objectAtIndex:i] floatValue]*self.bounds.size.height));
        //add a new point and connect that new point
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    //the drawing is done
    CGContextStrokePath(context);
}
// rect = current view height
-(void) drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, rect.size.height);
    //CGContextFillRect(context, drawRect);
    [self drawInContext:context];
}

-(void) drawRect2:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* CTM Context Transform Matrix */
    CGAffineTransform t = CGContextGetCTM(context);
    // [2, 0, 0, -2, 0, 200]
    //NSLog(@"t is %@", NSStringFromCGAffineTransform(t));

    CGContextTranslateCTM(context, 0.0f, (self.bounds.size.height));
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    t = CGContextGetCTM(context);
    //NSLog(@"new t is %@", NSStringFromCGAffineTransform(t));
    // [2, 0, -0, 2, 0, 0]
    [self drawInContext2:context];
}
- (void)drawInContext2:(CGContextRef)context

{
    //Line color and size start
    CGColorRef colorRef = [[UIColor cyanColor] CGColor];
    CGContextSetStrokeColorWithColor(context, colorRef);
    CGContextSetLineWidth(context, 2.0f);
    //Line color and size stop
    CGContextClearRect(context, self.bounds);
    //Background color start
    CGContextSetRGBFillColor(context, 64.0f/255.0f, 224.0f/255.0f, 208.0f/255.0f, 1.0f);
    CGContextFillRect(context, self.bounds);
    //Background color stop

    
    CGPoint firstPoint = CGPointMake(0.0f, [[averagePointArray objectAtIndex:0] floatValue]);
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < [peakPointArray count]; i++)
    {
        CGPoint point = CGPointMake(i, ([[averagePointArray objectAtIndex:i] floatValue]*self.bounds.size.height));
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}


@end
