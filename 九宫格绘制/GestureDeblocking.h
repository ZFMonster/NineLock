//
//  GestureDeblocking.h
//  九宫格绘制
//
//  Created by zf on 2018/3/2.
//  Copyright © 2018年 zf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GestResult)(NSArray *indexArray);

/**
 宽度设置有用，高度等于宽度
 */
@interface GestureDeblocking : UIView

- (void) resetGestView;

// 每一个球的上下左右边距
@property (nonatomic,assign) CGFloat padding;

/**
 每一行圆的个数，默认为3
 */
@property (nonatomic,assign) NSInteger number;

@property (nonatomic,copy) GestResult result;

@end
