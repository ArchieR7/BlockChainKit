//
//  CryptoSign.m
//  BlockChainKit
//
//  Created by Archie on 2019/6/12.
//

#import "CryptoSign.h"
#import <secp256k1/secp256k1.h>

@implementation _Crypto

+ (NSData *)signMessage:(NSData *)message withPrivateKey:(NSData *)privateKey {
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    secp256k1_ecdsa_signature signature;
    secp256k1_ecdsa_signature normalizedSignature;
    secp256k1_ecdsa_sign(ctx, &signature, message.bytes, privateKey.bytes, NULL, NULL);
    secp256k1_ecdsa_signature_normalize(ctx, &normalizedSignature, &signature);
    size_t siglen = 74;
    NSMutableData *der = [NSMutableData dataWithLength:siglen];
    secp256k1_ecdsa_signature_serialize_der(ctx, der.mutableBytes, &siglen, &normalizedSignature);
    der.length = siglen;
    secp256k1_context_destroy(ctx);
    return der;
}

@end
