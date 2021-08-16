//
//  ViewController.m
//  HW_DispatchTimer
//
//  Created by erlich wang on 2021/8/16.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong)dispatch_queue_t queue;
@property(nonatomic, strong)dispatch_source_t timer;

@property(nonatomic, assign)NSInteger count;
@property(nonatomic, assign)NSInteger interval;
@property(nonatomic, assign)BOOL stopped;

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stopped = YES;
    self.count = 0;     // 计数
    self.interval = 1;  // 间隔1秒
    
    self.queue = dispatch_queue_create("com.iflamer.fork", DISPATCH_QUEUE_CONCURRENT);
    [self createTimer];
    [self startTimer];
}

- (IBAction)startBtnTouchUpInside:(id)sender {
    if (self.stopped) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

- (IBAction)recycleBtnTouchUpInside:(id)sender {
    if (!self.timer) {
        [self createTimer];
    } else {
        [self destroyTimer];
    }
}


- (void)dealloc {
    [self destroyTimer];
}

- (void)createTimer {
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.countLabel.text = [NSString stringWithFormat:@"%ld", ++self.count];
        });
    });
    self.countLabel.text = @"timer 已创建";
    [self.btn2 setTitle:@"销毁" forState:UIControlStateNormal];
}
- (void)startTimer {
    if (!self.timer) {
        return;
    }
    dispatch_resume(self.timer);
    self.stopped = NO;
    [self.btn1 setTitle:@"暂停" forState:UIControlStateNormal];
    NSLog(@"timer started ... ");
}
- (void)stopTimer {
    if (!self.timer) {
        return;
    }
    dispatch_suspend(self.timer);
    self.stopped = YES;
    [self.btn1 setTitle:@"开始" forState:UIControlStateNormal];
    NSLog(@"timer suspended ... ");
}

- (void)destroyTimer {
    if (!self.timer) {
        return;
    }
    if (self.stopped) {
        [self startTimer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_cancel(self.timer);
            self.stopped = YES;
            self.timer = nil;
            [self.btn2 setTitle:@"创建timer" forState:UIControlStateNormal];
            [self.btn1 setTitle:@"开始" forState:UIControlStateNormal];
            self.count = 0;
            self.countLabel.text = @"timer 已销毁";
            NSLog(@"timer destroyed ... ");
        });
    } else {
        dispatch_cancel(self.timer);
        self.stopped = YES;
        self.timer = nil;
        [self.btn2 setTitle:@"创建timer" forState:UIControlStateNormal];
        [self.btn1 setTitle:@"开始" forState:UIControlStateNormal];
        self.count = 0;
        self.countLabel.text = @"timer 已销毁";
        NSLog(@"timer destroyed ... ");
    }
}


@end
