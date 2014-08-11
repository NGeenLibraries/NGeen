//
// ApiStoreConfiguration.swift
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

class ApiStoreConfiguration: NSObject, ConfigurationStoreProtocol {

    var bodyItems: [String: AnyObject]
    var cachePolicy: NSURLRequestCachePolicy
    var cacheStoragePolicy: NSURLCacheStoragePolicy
    var configurations: Dictionary<String, ConfigurationStoreProtocol>
    var credential: NSURLCredential?
    var headers: Dictionary<String, String>
    var host: String
    var modelsPath: String
    var pathItems: Dictionary<String, String>
    var protectionSpace: NSURLProtectionSpace?
    var queryItems: Dictionary<String, AnyObject>
    var responseType: ResponseType
    var scheme: String
    var timeout: Int
    
//MARK: Constructor
    
    override init() {
        self.bodyItems = Dictionary()
        self.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        self.cacheStoragePolicy = NSURLCacheStoragePolicy.NotAllowed
        self.configurations = Dictionary<String, ConfigurationStoreProtocol>()
        self.headers = Dictionary<String, String>()
        self.host = ""
        self.scheme = "http"
        self.modelsPath = ""
        self.pathItems = Dictionary<String, String>()
        self.queryItems = Dictionary<String, String>()
        self.responseType = ResponseType.data
        self.timeout = 30
    }
    
    convenience init(headers: Dictionary<String, String>, host: String, scheme: String) {
        self.init()
        self.headers = headers
        self.host = host
        self.scheme = scheme
    }

    
// MARK: Class methods
    
    /**
    *  The function return a instance for the api store configuration class
    *
    *  @param contentType The content type for the api
    *  @param headers The headers for the request
    *  @param host The host to send the request
    *  @param httpProtocol The protocol to use for the request
    *
    *  @return ApiStoreConfiguration
    */
    
    class func configWithContentType(headers: Dictionary<String, String>, host: String, scheme: String) -> ApiStoreConfiguration {
        return ApiStoreConfiguration(headers: headers, host: host, scheme: scheme)
    }
    
}
