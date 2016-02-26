//
//  ViewController.m
//  demoTCP
//
//  Created by Carolyn Foo on 2/21/16.
//  Copyright © 2016 22m. All rights reserved.
//

#import "ViewController.h"
#import "JPRawTCPClient.h"

@interface ViewController ()
@property (nonatomic, strong) JPRawTCPClient *tcpClient;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *initBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    initBtn.backgroundColor = [UIColor blueColor];
    [initBtn setTitle:@"Init new TCP connection" forState:UIControlStateNormal];
    [initBtn addTarget:self action:@selector(setupNewTCP) forControlEvents:UIControlEventTouchUpInside];
    initBtn.center = self.view.center;
    
    [self.view addSubview:initBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNewTCP {
    self.tcpClient = [[JPRawTCPClient alloc] init];
    [self.tcpClient connectToAddress:@"192.168.1.129:6000"];
}

@end
