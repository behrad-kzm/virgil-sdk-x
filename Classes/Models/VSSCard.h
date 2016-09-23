//
//  VSSCard.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModel.h"
#import "VSSCannonicalRepresentable.h"
#import "VSSSerializable.h"

@class VSSIdentity;
@class VSSPublicKey;

/**
 * This class represents the cornerstone model of the Virgil infrastructure.
 * 
 * Virgil Card is an object containing the public information about the user.
 * This information includes the user's identity, so that other users can find him/her.
 * Also it contains the public key object, so other users can encrypt data for this 
 * particular user and also they can verify signatures composed by this user.
 *
 * For the most sensitive operations with Virgil Services, it is required that
 * users have the Virgil Cards authorized (or confirmed, that this particular user
 * posesses the information associated with the card).
 *
 * There are two ways of card authorization:
 *
 * - Global (using Virgil Identity Service): in this case card's identity **MUST** have type kVSSIdentityTypeEmail.
 * Call to [VSSClient verifyEmailIdentityWithValue:extraFields:completionHandler:] initiates authorization process.
 * After that Virgil Identity Service sends a confirmation code to the email address which is set as a value of the card's identity.
 * User should get this code from the email and call [VSSClient confirmEmailIdentityWithActionId:code:tokenTtl:tokenCtl:completionHandler:]
 * with this code. After successful confirmation the validation token will be returned by the Serivce. This token then can be used with the SDK
 * for other operations.
 * - Private (using a third party service): in this case the card's identity may have any desired string as type. All responsibility of the card confirmation
 * is taken by the particular third party service (e.g. some developer's service).
 *
 * @see VSSIdentity
 *
 */
#warning review documentation
@interface VSSCard : VSSModel <VSSDeserializable, VSSCannonicalRepresentable>

/**
 * The identity object associated with the Virgil card.
 */
@property (nonatomic, copy, readonly) VSSIdentity * __nonnull identity;

/**
 * The public key of the user, which might be used to check his/her signatures and encrypt the data for the owner of the card.
 */
@property (nonatomic, copy, readonly) VSSPublicKey * __nonnull publicKey;

/**
 * The dictionary with any custom key-value data.
 */
@property (nonatomic, copy, readonly) NSDictionary * __nullable data;

/**
 * The dictionary with info about device which created the Virgil card.
 */
@property (nonatomic, copy, readonly) NSDictionary * __nonnull info;

///------------------------------------------
/// @name Lifecycle
///------------------------------------------

/**
 * Designated constructor.
 *
 * @param identity Identity associated with the card.
 * @param publicKey Public key wrapper representing the public key of the card's owner.
 * @param data dictionary with any custom key-value data.
 * @param info dictionary with data that describes device which created the card.
 *
 * @return Instance of the Virgil Card.
 */
- (instancetype __nonnull)initWithIdentity:(VSSIdentity * __nonnull)identity publicKey:(VSSPublicKey * __nonnull)publicKey data:(NSDictionary * __nullable)data info:(NSDictionary<NSString *, NSString *> * __nonnull)info NS_DESIGNATED_INITIALIZER;

@end
