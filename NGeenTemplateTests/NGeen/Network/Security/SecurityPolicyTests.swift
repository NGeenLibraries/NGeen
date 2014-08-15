//
// SecurityPolicyTests.swift
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
import XCTest

class Certificate: NSObject {
    
    class func createTrustSecForCertificateName(name: String, inout certificate cert: SecCertificateRef?, inout forTrust trust: SecTrustRef?) {
        let path: String = NSBundle.mainBundle().pathForResource(name, ofType: "cer")
        XCTAssertFalse(path.isEmpty, "The path for the certificate should not be null", file: __FILE__, line: __LINE__)
        var error: NSErrorPointer = nil
        let data: NSData = NSData.dataWithContentsOfFile(path, options: NSDataReadingOptions.DataReadingMappedAlways, error: error)
        XCTAssert(error == nil, "The error should be null", file: __FILE__, line: __LINE__)
        cert = SecCertificateCreateWithData(kCFAllocatorDefault, data).takeUnretainedValue()
        let certificates: NSArray = NSArray(array: [cert!])
        let policy = SecPolicyCreateBasicX509()
        var trusted: Unmanaged<SecTrustRef>? = nil
        SecTrustCreateWithCertificates(cert, policy.takeUnretainedValue(), &trusted)
        if trusted != nil {
            trust = trusted!.takeUnretainedValue()
        }
    }
}

class SecurityPolicyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatSelfSignedCertificateWithDomain() {
        var certificate: SecCertificateRef?
        var trust: SecTrustRef?
        Certificate.createTrustSecForCertificateName("foobar.com", certificate: &certificate, forTrust: &trust)
        let securityPolicy: SecurityPolicy = SecurityPolicy()
        securityPolicy.allowInvalidCertificates = true
        securityPolicy.certificates = [SecCertificateCopyData(certificate).takeUnretainedValue()]
        securityPolicy.policy = Policy.certificate
        XCTAssertTrue(securityPolicy.trustedServer(trust!, forDomain: "foobar.com"), "Certificate should be trusted", file: __FILE__, line: __LINE__)
    }
    
    func testThatSelfSignedCertificateWithoutDomainShouldBeTrue() {
        var certificate: SecCertificateRef?
        var trust: SecTrustRef?
        Certificate.createTrustSecForCertificateName("NoDomains", certificate: &certificate, forTrust: &trust)
        let securityPolicy: SecurityPolicy = SecurityPolicy()
        securityPolicy.allowInvalidCertificates = true
        securityPolicy.certificates = [SecCertificateCopyData(certificate).takeUnretainedValue()]
        securityPolicy.policy = Policy.certificate
        XCTAssertTrue(securityPolicy.trustedServer(trust!, forDomain: ""), "Certificate should not be trusted", file: __FILE__, line: __LINE__)
    }
    
    func testThatSelfSignedCertificateWithoutDomain() {
        var certificate: SecCertificateRef?
        var trust: SecTrustRef?
        Certificate.createTrustSecForCertificateName("NoDomains", certificate: &certificate, forTrust: &trust)
        let securityPolicy: SecurityPolicy = SecurityPolicy()
        securityPolicy.certificates = [SecCertificateCopyData(certificate).takeUnretainedValue()]
        securityPolicy.policy = Policy.certificate
        XCTAssertFalse(securityPolicy.trustedServer(trust!, forDomain: "foo.bar"), "Certificate should not be trusted", file: __FILE__, line: __LINE__)
    }
}
