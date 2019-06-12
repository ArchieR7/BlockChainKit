//
//  CryptoSign.h
//  BlockChainKit
//
//  Created by Archie on 2019/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface _Crypto : NSObject
+ (NSData *)signMessage:(NSData *)message withPrivateKey:(NSData *)privateKey;
@end
NS_ASSUME_NONNULL_END
