//
//  JPRawTCPClient.m
//  demoTCP
//
//  Created by Carolyn Foo on 2/21/16.
//  Copyright © 2016 22m. All rights reserved.
//

#import "JPRawTCPClient.h"
#import "GCDAsyncSocket.h"

static NSInteger kTCPClientPacketTagHeader = 1;
static NSInteger kTCPClientPacketTagBody = 2;
static NSTimeInterval kTCPClientWriteTimeout = 60;
static NSTimeInterval kTCPClientReadBodyTimeout = 30;
static NSTimeInterval kTCPClientReadTimeout = -1;

@interface JPRawTCPClient() <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation JPRawTCPClient

- (void)connectToAddress:(NSString *)address {
    NSArray <NSString *> *addressComponent = [address componentsSeparatedByString:@":"];
    
    if (addressComponent.count < 2) {
        return;
    }
    
    NSError *error;
    if (self.socket) {
        [self disconnect];
    }
    
    NSParameterAssert(self.socket == nil);
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];
    
    BOOL connected = [self.socket connectToHost:addressComponent[0]
                                         onPort:[addressComponent[1] integerValue]
                                          error:&error];
    
    NSParameterAssert(connected && error == nil);
}

- (void)disconnect {
    self.socket.delegate = nil;
    [self.socket disconnect];
    self.socket = nil;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if (self.socket != sock) {
        return;
    }
    
    NSParameterAssert([NSThread isMainThread]);
    
    // Send nickname
    NSData *body = [@"Car Foo" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData dataWithLength:4];
    
    char *bytes = (char *)data.mutableBytes;
    bytes[0] = (uint8_t)(body.length & 0xff);
    bytes[1] = (uint8_t)(body.length >> 8 & 0xff);
    bytes[2] = (uint8_t)(body.length >> 16 & 0xff);
    bytes[3] = (uint8_t)(body.length >> 24 & 0xff);
    
    [self.socket writeData:data withTimeout:kTCPClientWriteTimeout tag:0];
    [self.socket writeData:body withTimeout:kTCPClientWriteTimeout tag:0];
    
    [sock readDataToLength:4 withTimeout:kTCPClientReadTimeout tag:kTCPClientPacketTagHeader];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (self.socket != sock || self.socket.isDisconnected) {
        return;
    }
    
    NSParameterAssert([NSThread isMainThread]);
    
    if (tag == kTCPClientPacketTagHeader) {
        char *bytes;
        
        bytes = (char *)data.bytes;
        
        int length = 0;
        
        length += (uint8_t)bytes[0];
        length += ((uint8_t)bytes[1] << 8);
        length += ((uint8_t)bytes[2] << 16);
        length += ((uint8_t)bytes[3] << 24);
        
        [sock readDataToLength:length withTimeout:kTCPClientReadBodyTimeout tag:kTCPClientPacketTagBody];
    }
    else if (tag == kTCPClientPacketTagBody) {
        NSString *testString = [NSString stringWithUTF8String:&data.bytes[1]];
        NSLog(@"test string: %@", testString);
    }
}

@end
