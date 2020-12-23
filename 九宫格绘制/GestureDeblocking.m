//
//  GestureDeblocking.m
//  九宫格绘制
//
//  Created by zf on 2018/3/2.
//  Copyright © 2018年 zf. All rights reserved.
//

#import "GestureDeblocking.h"
#import <AudioToolbox/AudioToolbox.h>

@interface GesturePointModel : NSObject
@property (nonatomic,assign)CGPoint center;
@property (nonatomic,assign)CGFloat radius;
@property (nonatomic,assign)CGPoint nextCenter;
@property (nonatomic,assign)CGPoint fromCenter;
@property (nonatomic,assign)BOOL selected;
@end
@implementation GesturePointModel
@end

@interface GestureDeblocking ()
@property (nonatomic,strong)NSMutableArray *pointMoedlArray;
@property (nonatomic,strong)NSMutableArray *selectedIndexArray;
@property (nonatomic,assign)CGPoint touchPoint;
@property (nonatomic,strong)GesturePointModel *fromModel;
@property (nonatomic,assign)BOOL beginTouch;
@end

@implementation GestureDeblocking
float findAngle(CGPoint from, CGPoint to) {
    float dy = to.y - from.y;
    float dx = to.x - from.x;
    return atan2f(dy, dx);
}
float distanceInPoint(CGPoint from,CGPoint to) {
    return sqrt(pow(from.x-to.x, 2)+pow(from.y-to.y, 2));
}
- (NSMutableArray *) selectedIndexArray {
    if (_selectedIndexArray == nil) {
        _selectedIndexArray = [NSMutableArray array];
    }
    return _selectedIndexArray;
}

- (NSMutableArray *) pointMoedlArray {
    if (_pointMoedlArray == nil) {
        _pointMoedlArray = [NSMutableArray array];
    }
    return _pointMoedlArray;
}
- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _number = 3;
        _padding = 25;
        [self resetGestView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    frame.size.height = frame.size.width;
    [super setFrame:frame];
}
- (void)setNumber:(NSInteger)number {
    _number = number;
    [self resetGestView];
}
- (void) setPadding:(CGFloat)padding {
    _padding = padding;
    [self resetGestView];
}

- (void) resetGestView {
    [self.pointMoedlArray removeAllObjects];
    [self.selectedIndexArray removeAllObjects];
    
    
    CGFloat radius = (self.bounds.size.width-(self.number+1)*self.padding)/self.number/2;
    for (NSInteger index = 0; index < self.number*self.number; index ++) {
        GesturePointModel *model = [[GesturePointModel alloc] init];
        NSInteger x = index%self.number;
        NSInteger y = index/self.number;
        CGFloat offset = radius+self.padding;
        CGFloat unitWidth = radius*2+self.padding;
        model.selected = NO;
        model.center = CGPointMake(x*unitWidth+offset, offset+y*unitWidth);
        model.radius = radius;
        [self.pointMoedlArray addObject:model];
    }
    
    [self setNeedsDisplay];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.beginTouch = YES;
    [self resetGestView];
}
- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    self.touchPoint = point;
    GesturePointModel *model = [self getModelFromPoint:point];
    if (model) {
        if (model.selected == NO) {
            if (self.fromModel) {
                self.fromModel.nextCenter = model.center;
                model.fromCenter = self.fromModel.center;
            }
            self.fromModel = model;
            NSInteger index = [self.pointMoedlArray indexOfObject:model];
            [self.selectedIndexArray addObject:@(index)];
            AudioServicesPlaySystemSound(1519);
        }
        model.selected = YES;
    }
    [self setNeedsDisplay];
}
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.beginTouch = NO;
    [self setNeedsDisplay];
    if (self.result) {
        self.result(self.selectedIndexArray);
    }
}

- (GesturePointModel *) getModelFromPoint:(CGPoint)point {
    for (GesturePointModel *model in self.pointMoedlArray) {
        CGFloat distance = distanceInPoint(point,model.center);
        if (distance <= model.radius*.8) {
            
            return model;
        }
    }
    return nil;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 绘制点之间的连线
    for (NSInteger index = 0; index < self.selectedIndexArray.count; index ++) {
        if (index == self.selectedIndexArray.count-1) {
            break;
        }
        NSInteger count = [self.selectedIndexArray[index] integerValue];
        [self drawLineAtModel:self.pointMoedlArray[count]];
    }
    
    // 绘制最后一个点和手指的连线
    if (self.selectedIndexArray.count > 0 && self.beginTouch) {
        [self drawLineToFinger];
    }
    
    // 绘制点
    for (NSInteger index = 0; index < self.pointMoedlArray.count; index ++) {
        GesturePointModel *model = self.pointMoedlArray[index];
        [self drawCirclePathAtModel:model];
    }
}

- (void) drawArrowFromModel:(GesturePointModel *)model destPoint:(CGPoint)point {
    CGPoint topPoint = [self getPointAtArcCenter:model.center destPoint:point radius:model.radius*3/4];
    CGFloat angle = findAngle(topPoint,model.center);
    CGPoint point1 = [self getNextPointFromTopPoint:topPoint angle:angle+M_PI/6 length:model.radius/4];
    CGPoint point2 = [self getNextPointFromTopPoint:topPoint angle:angle-M_PI/6 length:model.radius/4];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:topPoint];
    [path addLineToPoint:point1];
    [path addLineToPoint:point2];
    [[UIColor yellowColor] setFill];
    [path fill];
    
}

- (void) drawLineToFinger {
//    [self drawLineAndArrowFromPoint:self.fromModel.center toPoint:self.touchPoint];
    CGFloat distance = distanceInPoint(self.touchPoint, self.fromModel.center);
    if (distance > self.fromModel.radius) {
        CGPoint begin = [self getPointAtArcCenter:self.fromModel.center destPoint:self.touchPoint radius:self.fromModel.radius];
        [self drawLineFromPoint:begin toPoint:self.touchPoint];
    }
}

- (void) drawLineAtModel:(GesturePointModel *)model {
//    [self drawLineAndArrowFromPoint:model.center toPoint:model.nextCenter];
    
    CGPoint begin = [self getPointAtArcCenter:model.center destPoint:model.nextCenter radius:model.radius];
    CGPoint end = [self getPointAtArcCenter:model.nextCenter destPoint:model.center radius:model.radius];
    [self drawLineFromPoint:begin toPoint:end];
//    [self drawLineAndArrowFromPoint:begin toPoint:end];
}

- (CGPoint) getPointAtArcCenter:(CGPoint)center destPoint:(CGPoint)destPoint radius:(CGFloat)radius{
    CGFloat angle = findAngle(center, destPoint);
    float dx = cosf(angle) * radius;
    float dy = sinf(angle) * radius;
    CGPoint arrowEnd = CGPointMake(center.x + dx, center.y + dy);
    return arrowEnd;
}

// 两点之间画线和箭头
- (void) drawLineAndArrowFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPOint {
    [self drawLineFromPoint:fromPoint toPoint:toPOint];
    
    CGPoint center = CGPointMake((toPOint.x-fromPoint.x)/2+fromPoint.x, (toPOint.y-fromPoint.y)/2+fromPoint.y);
    CGFloat angle = findAngle(toPOint,fromPoint);
    [self drawArrowLineAtPoint:center angle:angle-M_PI/6 length:15];
    [self drawArrowLineAtPoint:center angle:angle+M_PI/6 length:15];
}
// 两点之间画线
- (void) drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPOint {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:fromPoint];
    [path addLineToPoint:toPOint];
    [[UIColor yellowColor] setStroke];
    [path setLineWidth:3];
    [path stroke];
}

- (void) drawArrowLineAtPoint:(CGPoint)point angle:(CGFloat)angle length:(CGFloat)length{
    CGPoint arrowEnd = [self getNextPointFromTopPoint:point angle:angle length:length];
    [self drawLineFromPoint:arrowEnd toPoint:point];
}

- (CGPoint) getNextPointFromTopPoint:(CGPoint)point angle:(CGFloat)angle length:(CGFloat)length {
    float dx = cosf(angle) * length;
    float dy = sinf(angle) * length;
    return CGPointMake(point.x + dx, point.y + dy);
}

// 选中和没选中点的绘制
- (void) drawCirclePathAtModel:(GesturePointModel *)model {
    UIColor *destColor = nil;
    if (model.selected) {
        destColor = [UIColor yellowColor];
    }else {
        destColor = [UIColor redColor];
    }
    [destColor setStroke];
    UIBezierPath *outpath = [UIBezierPath bezierPath];
    [outpath addArcWithCenter:model.center radius:model.radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [outpath setLineWidth:4];
    [outpath stroke];
    [self.backgroundColor setFill];
    [outpath fill];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:model.center radius:model.radius/4 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [destColor setFill];
    [path fill];
    if (model.selected) {
        if (model.nextCenter.x==0&&model.nextCenter.y==0) {
            if (self.beginTouch) {
                [self drawArrowFromModel:model destPoint:self.touchPoint];
            }
        }else {
            [self drawArrowFromModel:model destPoint:model.nextCenter];
        }
    }
}


@end
