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

import UIKit

class SecurityPolicy: NSObject {
 
//MARK: Instance methods
    
    func trustedServer(server: SecTrustRef, InCertificates certificates: NSArray) -> Bool {
        return trustedServer(server, InCertificates: certificates, forDomain: "")
    }
    
    func trustedServer(server: SecTrust, InCertificates certificates: NSArray , forDomain domain: String) -> Bool {
        let policies: NSMutableArray = NSMutableArray.array()
        if !domain.isEmpty {
            //policies.addObject(SecPolicyCreateSSL(true, domain as CFStringRef).takeRetainedValue())
        } else {
            policies.addObject(SecPolicyCreateBasicX509().takeUnretainedValue())
        }
        SecTrustSetPolicies(server, policies)
        let certificateCount: CFIndex = SecTrustGetCertificateCount(server)
        let trustChains: NSMutableArray = NSMutableArray.array()
        for (index: CFIndex) in 0...certificateCount {
            let certificate = SecTrustGetCertificateAtIndex(server, index).takeUnretainedValue()
            trustChains.addObject(SecCertificateCopyData(certificate).takeUnretainedValue())
        }
        let pinnedCertificates = NSMutableArray.array()
        for data in certificates {
            pinnedCertificates.addObject(SecCertificateCreateWithData(kCFAllocatorDefault, data as NSData).takeUnretainedValue())
        }
        SecTrustSetAnchorCertificates(server, pinnedCertificates)
        var trustedCertificates = 0
        for data in trustChains {
            if certificates.containsObject(data) {
                trustedCertificates++
            }
        }
        return trustedCertificates == trustChains.count
    }
    
}
