//
// ApiConfiguaration.swift
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

class ApiConfiguration: NSObject {
    
//MARK: Constructor
    
    override init() {}
    
//MARK: Class methods
    
    class func startConfiguration() {
        let marvelConfiguration = ApiStoreConfiguration(host: "gateway.marvel.com", scheme: "http")
        marvelConfiguration.queryItems = ["ts": "429930524.650837", "apikey": kMarvelPublicKey, "hash": "3f5b36b299f829c987e3fefadab2a0b5"]
        ApiStore.defaultStore().setConfiguration(marvelConfiguration, forServer: kMarvelServer)
        ApiStore.defaultStore().setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed, forServer: kMarvelServer)
        ApiStore.defaultStore().setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad, forServer: kMarvelServer)
        let heroEndpint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "/v1/public/characters")
        ApiStore.defaultStore().setEndpoint(heroEndpint, forServer: kMarvelServer)
        let parseConfiguration: ApiStoreConfiguration = ApiStoreConfiguration(host: "api.parse.com", scheme: "https")
        ApiStore.defaultStore().setConfiguration(parseConfiguration, forServer: kParseServer)
    }
    
}
