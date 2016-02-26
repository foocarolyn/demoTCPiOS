//
//  JPRawTCPClient.h
//  demoTCP
//
//  Created by Carolyn Foo on 2/21/16.
//  Copyright © 2016 22m. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPRawTCPClient : NSObject

- (void)connectToAddress:(NSString *)address;

@end
