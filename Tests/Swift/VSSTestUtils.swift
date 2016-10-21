//
//  VSSTestUtils.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK

let kApplicationToken = <#String: Application Access Token#>
let kApplicationPublicKeyBase64 = <#String: Application Public Key#>
let kApplicationPrivateKeyBase64 = <#String: Application Private Key in base64#>
let kApplicationPrivateKeyPassword = <#String: Application Private Key password#>
let kApplicationIdentityType = String: <#Application Identity Type#>
let kApplicationId = <#String: Application Id#>

class VSSTestUtils {
    private var crypto: VSSCrypto
    
    init(crypto: VSSCrypto) {
        self.crypto = crypto
    }
    
    func instantiateCard() -> VSSCard? {
        let keyPair = self.crypto.generateKeyPair()
        let exportedPublicKey = self.crypto.export(keyPair.publicKey)
        
        // some random value
        let identityValue = UUID().uuidString
        let identityType = kApplicationIdentityType
        let card = VSSCard(identity: identityValue, identityType: identityType, publicKey: exportedPublicKey)
        
        let privateAppKeyData = Data(base64Encoded: kApplicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: kApplicationPrivateKeyPassword)!
        
        let signer = VSSSigner(crypto: self.crypto)
        
        try! signer.ownerSign(card, with: keyPair.privateKey)
        try! signer.authoritySign(card, forAppId: kApplicationId, with: appPrivateKey)
        
        return card;
    }
    
    func check(card card1: VSSCard, isEqualToCard card2: VSSCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.identityType == card2.data.identityType
            && card1.data.identity == card2.data.identity
        
        return equals
    }
    
    func instantiateRevokeCardFor(card: VSSCard) -> VSSRevokeCard {
        let revokeCard = VSSRevokeCard(cardId: card.identifier!, reason: .unspecified)
        
        let signer = VSSSigner(crypto: self.crypto)
        
        let privateAppKeyData = Data(base64Encoded: kApplicationPrivateKeyBase64, options: Data.Base64DecodingOptions(rawValue: 0))!
        
        let appPrivateKey = self.crypto.importPrivateKey(from: privateAppKeyData, withPassword: kApplicationPrivateKeyPassword)!
        
        try! signer.authoritySign(revokeCard, forAppId: kApplicationId, with: appPrivateKey)
        
        return revokeCard
    }
    
    func check(card card1: VSSRevokeCard, isEqualToCard card2: VSSRevokeCard) -> Bool {
        let equals = card1.snapshot == card2.snapshot
            && card1.data.cardId == card2.data.cardId
        
        return equals
    }
}
