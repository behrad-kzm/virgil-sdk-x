//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

@objc(VSSKeyknoxGetKeysParams) public class KeyknoxGetKeysParams: NSObject {
    @objc public let identity: String?
    @objc public let root: String?
    @objc public let path: String?
    
    @objc public init(identity: String? = nil,
                      root: String? = nil,
                      path: String? = nil) {
        self.identity = identity
        self.root = root
        self.path = path
        
        super.init()
    }
}

@objc(VSSKeyknoxDeleteParticipantParams) public class KeyknoxDeleteRecipientParams: NSObject {
    @objc public let identity: String
    @objc public let root: String
    @objc public let path: String
    @objc public let key: String?
    
    @objc public init(identity: String,
                      root: String,
                      path: String,
                      key: String? = nil) {
        self.identity = identity
        self.root = root
        self.path = path
        self.key = key
        
        super.init()
    }
}

@objc(VSSKeyknoxResetParams) public class KeyknoxResetParams: NSObject {
    @objc public let root: String?
    @objc public let path: String?
    @objc public let key: String?
    
    @objc public init(root: String? = nil,
                      path: String? = nil,
                      key: String? = nil) {
        self.root = root
        self.path = path
        self.key = key
        
        super.init()
    }
}

@objc(VSSKeyknoxPullParams) public class KeyknoxPullParams: NSObject {
    @objc public let identity: String
    @objc public let root: String
    @objc public let path: String
    @objc public let key: String
    
    @objc public init(identity: String,
                      root: String,
                      path: String,
                      key: String) {
        self.identity = identity
        self.root = root
        self.path = path
        self.key = key
        
        super.init()
    }
}

@objc(VSSKeyknoxPushParams) public class KeyknoxPushParams: NSObject {
    @objc public let identities: [String]
    @objc public let root: String
    @objc public let path: String
    @objc public let key: String
    
    @objc public init(identities: [String],
                      root: String,
                      path: String,
                      key: String) {
        self.identities = identities
        self.root = root
        self.path = path
        self.key = key
        
        super.init()
    }
}
