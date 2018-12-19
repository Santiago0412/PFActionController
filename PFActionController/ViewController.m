//
//  ViewController.m
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "ViewController.h"
#import "PFActionController/PFActionViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showNormalActionController:(id)sender {

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    PFAction *action1 = [PFAction actionWithTitle:@"wpf普通action1" andHandler:^{
        NSLog(@"wpf普通action1点击");
    }];
    
    PFAction *action2 = [PFAction actionWithTitle:@"wpf普通action2" andHandler:^{
        NSLog(@"wpf普通action2点击");
    }];
    
    PFAction *action3 = [PFAction actionWithTitle:@"wpf普通action3" andHandler:^{
        NSLog(@"wpf普通action3点击");
    }];
    
    PFAction *action4 = [PFAction actionWithTitle:@"wpf普通action3" andHandler:^{
        NSLog(@"wpf普通action3点击");
    }];
    
    PFAction *action5 = [PFAction actionWithTitle:@"wpf普通action3" andHandler:^{
        NSLog(@"wpf普通action3点击");
    }];

    PFActionViewController *controller = [PFActionViewController normalActionControllerWithTitle:@"标题" message:@"提示语" contentView:view actions:@[action1,action2,action3,action4,action5] cancel:^{
        NSLog(@"wpf normal action canceld");
    } style:PFActionViewControllerStyleWhite];
    
    [controller showFromViewController:self];
}

- (IBAction)showExpandedViewController:(id)sender {
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor redColor]];
    
    PFAction *action1 = [PFAction actionWithTitle:@"wpf普通action1" andHandler:^{
        NSLog(@"wpf普通action1点击");
    }];
    
    PFAction *action2 = [PFAction actionWithTitle:@"wpf普通action2" andHandler:^{
        NSLog(@"wpf普通action2点击");
    }];
    
    PFAction *action3 = [PFAction actionWithTitle:@"wpf普通action3" andHandler:^{
        NSLog(@"wpf普通action3点击");
    }];
    
    PFImageAction *imageAction1 = [PFImageAction actionWithTitle:@"File" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action1点击");
    }];
    
    PFImageAction *imageAction2 = [PFImageAction actionWithTitle:@"Mail" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action2点击");
    }];
    
    PFImageAction *imageAction3 = [PFImageAction actionWithTitle:@"Server" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action3点击");
    }];
    
    PFImageAction *imageAction4 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    PFImageAction *imageAction5 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    PFImageAction *imageAction6 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    PFImageAction *imageAction7 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    PFImageAction *imageAction8 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    PFImageAction *imageAction9 = [PFImageAction actionWithTitle:@"Calender" image:[UIImage imageNamed:@"test.jpg"] andHandler:^{
        NSLog(@"图片action4点击");
    }];
    
    PFActionViewController *controller = [PFActionViewController exportActionControllerWithTitle:@"标题" message:@"提示语" contentView:view actions:@[action1,action2,action3] imageActions:@[imageAction1,imageAction2,imageAction3, imageAction4, imageAction5, imageAction6, imageAction7, imageAction8, imageAction9] cancel:^{
        NSLog(@"wpf expand action canceld");
    } style:PFActionViewControllerStyleBlack];
    
    [controller showFromViewController:self];
}


@end
