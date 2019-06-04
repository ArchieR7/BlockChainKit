import secp256k1

public let SECP256K1_CONTEXT_SIGN = secp256k1.SECP256K1_CONTEXT_SIGN

public func secp256k1_context_create(_ flags: UInt32) -> OpaquePointer? {
    return secp256k1.secp256k1_context_create(flags)
}

public func secp256k1_ecdsa_recoverable_signature() -> secp256k1_ecdsa_recoverable_signature {
    return secp256k1.secp256k1_ecdsa_recoverable_signature()
}

public func secp256k1_ecdsa_sign_recoverable(_ ctx: OpaquePointer,
                                             _ sig: UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>,
                                             _ msg32: UnsafePointer<UInt8>,
                                             _ seckey: UnsafePointer<UInt8>,
                                             _ noncefp: secp256k1_nonce_function!,
                                             _ ndata: UnsafeRawPointer!) -> Int32 {
    return secp256k1.secp256k1_ecdsa_sign_recoverable(ctx, sig, msg32, seckey, noncefp, ndata)
}

public func secp256k1_ecdsa_recoverable_signature_serialize_compact(_ ctx: OpaquePointer,
                                                                    _ output64: UnsafeMutablePointer<UInt8>,
                                                                    _ recid: UnsafeMutablePointer<Int32>,
                                                                    _ sig: UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>) {
    secp256k1.secp256k1_ecdsa_recoverable_signature_serialize_compact(ctx, output64, recid, sig)
}

public func secp256k1_context_destroy(_ ctx: OpaquePointer!) {
    secp256k1.secp256k1_context_destroy(ctx)
}

public func secp256k1_pubkey() -> secp256k1_pubkey {
    return secp256k1.secp256k1_pubkey()
}

public func secp256k1_ec_pubkey_create(_ ctx: OpaquePointer,
                                       _ pubkey: UnsafeMutablePointer<secp256k1_pubkey>,
                                       _ seckey: UnsafePointer<UInt8>) -> Int32 {
    return secp256k1.secp256k1_ec_pubkey_create(ctx, pubkey, seckey)
}
