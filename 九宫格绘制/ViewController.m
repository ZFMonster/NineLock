//
//  ViewController.m
//  九宫格绘制
//
//  Created by zf on 2018/3/2.
//  Copyright © 2018年 zf. All rights reserved.
//

#import "ViewController.h"
#import "GestureDeblocking.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (weak, nonatomic) IBOutlet GestureDeblocking *gestView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *countSegment;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) this = self;
    self.gestView.result = ^(NSArray *indexArray) {
        
        NSString *text = [indexArray componentsJoinedByString:@","];
        this.showLabel.text = text;
    };
    
    [self segmentChanged:self.countSegment];
}
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    self.gestView.number = sender.selectedSegmentIndex+2;
    self.gestView.padding = 60-10*self.gestView.number;
}



@end
