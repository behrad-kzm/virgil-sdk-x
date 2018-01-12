//
//  VSS006_KeyStorageTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilCrypto
import XCTest

class VSS006_KeyStorageTests: XCTestCase {
    private var crypto: VirgilCrypto!
    private var storage: VSSKeyStorage!
    private var keyEntry: VSSKeyEntry!
    private var privateKeyName: String!
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        
        self.crypto = VirgilCrypto()
        self.storage = VSSKeyStorage()
        let keyPair = self.crypto.generateKeyPair()
        
        let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
        let privateKeyName = UUID().uuidString
        
        self.keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
    }
    
    override func tearDown() {
        try? self.storage.deleteKeyEntry(withName: self.keyEntry.name)
        
        self.crypto = nil
        self.storage = nil
        self.keyEntry = nil
        self.privateKeyName = nil
        
        super.tearDown()
    }

    // MARK: Tests
    func test001_StoreKey() {
        try! self.storage.store(self.keyEntry)
    }
    
    func test002_StoreKeyWithDuplicateName() {
        try! self.storage.store(self.keyEntry)
    
        let keyPair = self.crypto.generateKeyPair()
        
        let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
        let privateKeyName = self.keyEntry.name
        
        let keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
        
        var errorWasThrown = false
        do {
            try self.storage.store(keyEntry)
        }
        catch {
            print((error as NSError).code)
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
    }
    
    func test003_LoadKey() {
        try! self.storage.store(self.keyEntry)
        
        let loadedKeyEntry = try! self.storage.loadKeyEntry(withName: self.keyEntry.name)
    
        XCTAssert(loadedKeyEntry.name == self.keyEntry.name)
        XCTAssert(loadedKeyEntry.value == self.keyEntry.value)
    }
    
    func test004_ExistsKey() {
        var exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
        XCTAssert(!exists)
    
        try! self.storage.store(self.keyEntry)
    
        exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
    
        XCTAssert(exists);
    }
    
    func test005_DeleteKey() {
        try! self.storage.store(self.keyEntry)
        
        try! self.storage.deleteKeyEntry(withName: self.keyEntry.name)
    
        let exists = self.storage.existsKeyEntry(withName: self.keyEntry.name)
        
        XCTAssert(!exists);
    }
    
    func test006_UpdateKey() {
        try! self.storage.store(self.keyEntry)
        
        let keyPair = self.crypto.generateKeyPair()
        
        let privateKeyRawData = try! self.crypto.exportPrivateKey(keyPair.privateKey, password: nil)
        let privateKeyName = self.keyEntry.name
        
        let keyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)
        
        try! self.storage.update(keyEntry)
        
        let newKeyEntry = try! self.storage.loadKeyEntry(withName: privateKeyName)
        
        XCTAssert(newKeyEntry.name == privateKeyName)
        XCTAssert(newKeyEntry.value == privateKeyRawData)
    }
}
