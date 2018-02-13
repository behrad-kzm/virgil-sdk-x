//
//  VSS001_CardClientTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCryptoApiImpl;
@import VirgilCrypto;

#import "VSSTestsConst.h"
#import "VSSTestUtils.h"

@interface VSS001_CardClientTests : XCTestCase

@property (nonatomic) VSSTestsConst *consts;
@property (nonatomic) VSMVirgilCrypto *crypto;
@property (nonatomic) VSMVirgilCardCrypto *cardCrypto;
@property (nonatomic) VSSTestUtils *utils;
@property (nonatomic) VSSCardClient *cardClient;

@end

@implementation VSS001_CardClientTests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    
    self.consts = [[VSSTestsConst alloc] init];
    self.crypto = [[VSMVirgilCrypto alloc] initWithDefaultKeyType:VSCKeyTypeFAST_EC_ED25519 useSHA256Fingerprints:true];
    self.cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    self.utils = [[VSSTestUtils alloc] initWithCrypto:self.crypto consts:self.consts];
    self.cardClient = [[VSSCardClient alloc] initWithServiceUrl:self.consts.serviceURL];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test001_CreateCard {
    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity";

    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:@"5.0" createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot];
    XCTAssert(error == nil && rawCard != nil);

    NSString *strToken = [self.utils getTokenStringWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil && responseRawCard != nil);
    
    VSSCard *responseCard = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:responseRawCard];
    VSSCard *card = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:rawCard];
    XCTAssert(card != nil && responseCard != nil);
    
    XCTAssert([self.utils isCardsEqualWithCard:responseCard and:card]);
    
    NSData *exportedPublicKeyCard = [self.crypto exportPublicKey:(VSMVirgilPublicKey *)card.publicKey];
    XCTAssert(error == nil);
    NSString *publicKeyBase64Card = [exportedPublicKeyCard base64EncodedStringWithOptions:0];
    
    XCTAssert([publicKeyBase64Card isEqualToString:publicKeyBase64]);
    
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCardCrypto:self.cardCrypto whiteLists:@[]];
    
    XCTAssert([verifier verifyCardWithCard:responseCard]);
}

-(void)test002_GetCard {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    NSString *strToken = [self.utils getTokenStringWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);

    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];

    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:@"5.0" createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];

    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot];
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCard.signatures.count == 1);
    
    VSSRawSignedModel *publishedRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:publishedRawCard];
    
    VSSGetCardResponse *getCardResponse = [self.cardClient getCardWithId:card.identifier token:strToken error:&error];
    
    VSSCard *foundCard = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:getCardResponse.rawCard];
    XCTAssert(error == nil && foundCard != nil);

    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:getCardResponse.rawCard.contentSnapshot];
    XCTAssert([self.utils isRawCardContentEqualWithContent:content and:responseContent]);

    XCTAssert([self.utils isCardsEqualWithCard:card and:foundCard]);

    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCardCrypto:self.cardCrypto whiteLists:@[]];

    XCTAssert([verifier verifyCardWithCard:foundCard]);
}

-(void)test003_SearchCards {
    NSError *error;
    NSString *identity = [[NSUUID alloc] init].UUIDString;
    NSString *strToken = [self.utils getTokenStringWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:@"5.0" createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot];
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCard.signatures.count == 1);
    
    VSSRawSignedModel *publishedRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error == nil);
    VSSCard *card = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:publishedRawCard];
    XCTAssert(card != nil);
    
    NSArray<VSSRawSignedModel *> *foundRawCards = [self.cardClient searchCardsWithIdentity:identity token:strToken error:&error];
    XCTAssert(foundRawCards.count != 0);
    VSSRawSignedModel *foundRawCard = foundRawCards.firstObject;
    
    VSSCard *foundCard = [VSSCard parseWithCardCrypto:self.cardCrypto rawSignedModel:foundRawCard];
    XCTAssert(foundCard != nil);
    
    VSSRawCardContent *responseContent = [[VSSRawCardContent alloc] initWithSnapshot:foundRawCard.contentSnapshot];
    XCTAssert([self.utils isRawCardContentEqualWithContent:content and:responseContent]);
    
    XCTAssert([self.utils isCardsEqualWithCard:card and:foundCard]);
    
    VSSVirgilCardVerifier *verifier = [[VSSVirgilCardVerifier alloc] initWithCardCrypto:self.cardCrypto whiteLists:@[]];
    
    XCTAssert([verifier verifyCardWithCard:foundCard]);
}

-(void)test004_STC_27 {
    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity1";
    NSString *wrongIdentity = @"identity2";
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:@"5.0" createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot];
    XCTAssert(rawCard != nil);
    
    NSString *strToken = [self.utils getTokenStringWithIdentity:wrongIdentity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];

    XCTAssert(error != nil);
    XCTAssert(responseRawCard == nil);
}

-(void)test005_STC_25 {
    NSError *error;
    VSMVirgilKeyPair *keyPair = [self.crypto generateKeyPairAndReturnError:&error];
    XCTAssert(error == nil);
    
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    NSString *identity = @"identity1";
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:identity publicKey:publicKeyBase64 previousCardId:nil version:@"5.0" createdAt:NSDate.date];
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot ];
    XCTAssert(error == nil && rawCard != nil);
    
    NSString *strToken = [self.utils getTokenWithWrongPrivateKeyWithIdentity:identity error:&error];
    XCTAssert(error == nil);
    
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:self.cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *responseRawCard = [self.cardClient publishCardWithModel:rawCard token:strToken error:&error];
    XCTAssert(error != nil);
    XCTAssert(responseRawCard == nil);
    XCTAssert([[error localizedDescription] isEqualToString:@"JWT is invalid"]);
}

@end
