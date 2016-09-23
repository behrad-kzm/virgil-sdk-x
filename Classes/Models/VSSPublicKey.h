//
//  VSSPublicKey.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModel.h"
#import "VSSModelCommons.h"

@class VSSCard;

/**
 * Wrapper class representing the public key of the particular user or owner of the Virgil Card.
 */
@interface VSSPublicKey : VSSModel

/**
 * Actual public key's data.
 */
@property (nonatomic, copy, readonly) NSData * __nonnull key;

///------------------------------------------
/// @name Lifecycle
///------------------------------------------

/**
 * Designated constructor.
 *
 * @param Id Unique identifier of the model.
 * @param createdAt Date when model was created.
 * @param key Actual public key's data.
 *
 * @return Instance of the Virgil Public Key wrapper object.
 */
- (instancetype __nonnull)initWithKey:(NSData * __nonnull)key NS_DESIGNATED_INITIALIZER;
@end
