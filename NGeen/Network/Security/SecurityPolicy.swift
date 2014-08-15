//
// SecurityPolicy.swift
// Copyright (c) 2014 NGeen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/* TODO: 1. create the cfarray from the certificates
         3. finish validation for public keys
*/

import UIKit

class SecurityPolicy: NSObject {
 
    private var pinnedKeys: [SecKeyRef]
    
    var allowInvalidCertificates: Bool
    var certificates: NSArray
    var policy: Policy
    
//MARK: Constructor
    
    override init() {
        self.allowInvalidCertificates = false
        self.certificates = NSArray()
        self.pinnedKeys = Array()
        self.policy = Policy.none
    }
    
//MARK: Instance methods
    
    /**
    * The function evaluate the server trust in the certificates
    *
    @param serverTrust The X.509 certificate trust of the server.
    @param certificates The array of trusted certificates.
    *
    * return boolean
    */
    
    func trustedServer(server: SecTrustRef) -> Bool {
        return trustedServer(server, forDomain: "")
    }
    
    /**
    * The function evaluate the server trust in the certificates
    *
    @param serverTrust The X.509 certificate trust of the server.
    @param certificates The array of trusted certificates.
    @param domain The domain of serverTrust. If empty, the domain will not be validated.
    *
    * return boolean
    */
    
    func trustedServer(server: SecTrust, forDomain domain: String) -> Bool {
        switch self.policy {
            case .certificate:
                let policies: NSMutableArray = NSMutableArray.array()
                if !domain.isEmpty {
                    let cfDomain = CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, domain, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding), kCFAllocatorDefault)
                    policies.addObject(SecPolicyCreateSSL(1, cfDomain).takeUnretainedValue())
                } else {
                    policies.addObject(SecPolicyCreateBasicX509().takeUnretainedValue())
                }
                SecTrustSetPolicies(server, policies)
                var result: SecTrustResultType = UInt32(kSecTrustResultOtherError)
                SecTrustEvaluate(server, &result)
                if (Int(result) != kSecTrustResultUnspecified || Int(result) != kSecTrustResultProceed) && !self.allowInvalidCertificates {
                    return false
                }
                let certificateCount: CFIndex = SecTrustGetCertificateCount(server)
                let trustChains: NSMutableArray = NSMutableArray.array()
                for (index: CFIndex) in 0..<certificateCount {
                    let certificate: SecCertificateRef = SecTrustGetCertificateAtIndex(server, index).takeUnretainedValue()
                    trustChains.addObject(SecCertificateCopyData(certificate).takeUnretainedValue())
                }
                let pinnedCertificates = NSMutableArray.array()
                for data in self.certificates {
                    pinnedCertificates.addObject(SecCertificateCreateWithData(kCFAllocatorDefault, data as NSData).takeUnretainedValue())
                }
                SecTrustSetAnchorCertificates(server, pinnedCertificates)
                var trustedCertificates = 0
                for data in trustChains {
                    if self.certificates.containsObject(data) {
                        trustedCertificates++
                    }
                }
                return trustedCertificates == trustChains.count
            case .none:
                return true
            case .publicKey:
                var trustedPublicKeys: Int = 0
                let policy = SecPolicyCreateBasicX509().takeUnretainedValue()
                let certificateCount: CFIndex = SecTrustGetCertificateCount(server)
                let trustedChains: NSMutableArray = NSMutableArray.arrayWithCapacity(certificateCount)
                for index in 0...certificateCount {
                    let certificate: SecCertificateRef = SecTrustGetCertificateAtIndex(server, index).takeUnretainedValue()
                    let pointerCertificates = UnsafeMutablePointer<UnsafePointer<()>>(calloc(0, UInt(sizeof(CGFloat))))
                    let certificates: CFArrayRef = CFArrayCreate(kCFAllocatorDefault, pointerCertificates, 1, nil)
                    var trust: Unmanaged<SecTrust>? = nil
                    SecTrustCreateWithCertificates(certificates, policy, &trust)
                    if trust != nil {
                        let trusted = trust!.takeUnretainedValue()
                        var trustResult: UnsafeMutablePointer<SecTrustResultType> = nil
                        SecTrustEvaluate(trusted, trustResult)
                        trustedChains.addObject(SecTrustCopyPublicKey(trusted).takeUnretainedValue())
                    }
                    for key in trustedChains {
                        for pinnedKey in self.pinnedKeys {
                            if key as SecKeyRef === pinnedKey as SecKeyRef {
                                trustedPublicKeys += 1
                            }
                        }
                    }
                    return trustedPublicKeys > 0
                }
            default:
                return false
        }
        return false
    }
    
}
