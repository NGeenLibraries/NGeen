//
// ApiStore.swift
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

class RequestSerializer: NSObject {

// TODO: 1. allow to set json writing options
    
    var constructingBodyClosure: (() -> (data: NSData!, name: String!, fileName: String!, mimeType: String!))?
    
    // MARK: Instance methods
    
    /**
    * The function serialize a given request in json format
    *
    * @param request The request to serialize.
    * @param configuration The configuration to create the request.
    *
    * @return NSURLRequest
    */
    
    func requestSerializingInJSONFormatWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint, error: NSErrorPointer) -> NSURLRequest {
        let mutableRequest = self.requestWithConfiguration(configuration, endPoint: endpoint).mutableCopy() as NSMutableURLRequest
        switch endpoint.httpMethod {
            case .patch, .post, .put:
                mutableRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(configuration.bodyItems, options: NSJSONWritingOptions.PrettyPrinted, error: error)
            default:
                ""
        }
        return mutableRequest
    }
    
    /**
    * The function construct the multipart form request
    *
    * @param configuration The configuration to create the request.
    * @param endpoint The api endpoint to use.
    *
    * @return NSURLRequest
    */
    
    func requestSerializingInMultipartWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint) -> NSURLRequest {
        let request = self.requestWithConfiguration(configuration, endPoint: endpoint).mutableCopy() as NSMutableURLRequest
        let boundary = "Boundary+\(CFAbsoluteTimeGetCurrent())"
        var params = ""
        for (key, value) in configuration.bodyItems {
            params = "\(params)--\(boundary)\r\n Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n \(value)\r\n"
        }
        let(data, name, fileName, mimeType) = self.constructingBodyClosure!()
        params = "\(params)\(boundary) Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n Content-Type: \(mimeType)\r\n\r\n \(data)\r\n"
        params = "\(params)--\(boundary)\r\n--\r\n"
        let body = params.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPBodyStream = NSInputStream(data: data)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(body.length.description, forHTTPHeaderField: "Content-Length")
        return request
    }
    
    /**
    * The function serialize a given request
    *
    * @param configuration The configuration to create the request.
    * @param endpoint The api endpoint to use.
    *
    * @return NSURLRequest
    */
    
    func requestSerializingWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint, error: NSErrorPointer) -> NSURLRequest {
        var request: NSURLRequest! = nil
        switch endpoint.contentType {
            case .json:
                request = self.requestSerializingInJSONFormatWithConfiguration(configuration, endPoint: endpoint, error: error)
            case .multiPartForm:
                assert(self.constructingBodyClosure != nil, "The body closure can't be null", file: __FILE__, line: __LINE__)
                request = self.requestSerializingInMultipartWithConfiguration(configuration, endPoint: endpoint)
            default:
                request = self.requestSerializingInUrlencodedWithConfiguration(configuration, endPoint: endpoint)
        }
        return request
    }
    
    /**
    * The function create and serialize the request in form url encode or query
    *
    * @param configuration The configuration to create the request.
    * @param endpoint The api endpoint to use.
    *
    * @return NSURLRequest
    */
    
    func requestSerializingInUrlencodedWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint) -> NSURLRequest {
        let request = self.requestWithConfiguration(configuration, endPoint: endpoint)
        return self.requestSerializingRequestInUrlencoded(request, withConfiguration: configuration)
    }
    
    /**
    * The function serialize a given request in form url encode or query
    *
    * @param request The request to serialize.
    * @param configuration The configuration to create the request.
    *
    * @return NSURLRequest
    */
    
    func requestSerializingRequestInUrlencoded(request: NSURLRequest, withConfiguration configuration: ApiStoreConfiguration) -> NSURLRequest {
        let mutableRequest = request.mutableCopy() as NSMutableURLRequest
        mutableRequest.HTTPBody = self.queryStringWithParameters(configuration.bodyItems).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if let body: NSData = mutableRequest.HTTPBody {
            mutableRequest.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        }
        return mutableRequest
    }
    
    /**
    * The function create a new request with the given configuration
    *
    * @param configuration The configuration to create the request.
    * @param endpoint The api endpoint to use
    *
    * @return NSURLRequest
    */
    
    func requestWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint) -> NSURLRequest {
        let urlComponents = NSURLComponents(string: configuration.host)
        urlComponents.host = configuration.host
        urlComponents.path = (endpoint.path != nil ? endpoint.path : "")
        urlComponents.scheme = configuration.scheme
        switch endpoint.httpMethod {
            case .delete, .get, .head :
                if configuration.queryItems.count > 0 {
                    urlComponents.query = self.queryStringWithParameters(configuration.queryItems)
                }
            default:
                ""
        }
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        let request = NSMutableURLRequest(URL: urlComponents.URL)
        request.HTTPMethod = endpoint.httpMethod.toRaw()
        request.setValue("\(ContentType.json.toRaw()); charset=\(charset)", forHTTPHeaderField: "Content-Type")
        for (key, value) in configuration.headers {
            if !request.valueForHTTPHeaderField(key) {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
    
    // MARK: Private methods
    
    /**
    * The function encode the params for the given content type
    *
    * @param parameters The dictionary with the params to encode.
    *
    * @return String
    */
    
    private func queryStringWithParameters(parameters: [String: AnyObject]) -> String {
        
        func query() -> String! {
            
            func queryComponents(key: String, value: AnyObject) -> [(String, String)] {
                
                func arrayQueryComponents(key: String, array: [AnyObject]) -> [(String, String)] {
                    var components: [(String, String)] = []
                    for (index, value) in enumerate(array) {
                        components += queryComponents("\(key)[\(index)]", value)
                    }
                    return components
                }
                
                func dictionaryQueryComponents(key: String, dictionary: [String: AnyObject]) -> [(String, String)] {
                    var components: [(String, String)] = []
                    for (nestedKey, value) in dictionary {
                        components += queryComponents("\(key)[\(nestedKey)]", value)
                    }
                    return components
                }
                
                var components: [(String, String)] = []
                if let dictionary = value as? [String: AnyObject] {
                    components += dictionaryQueryComponents(key, dictionary)
                } else if let array = value as? [AnyObject] {
                    components += arrayQueryComponents(key, array)
                } else {
                    components.append(key, "\(value)")
                }
                return components
            }
            var components: [(String, String)] = []
            for key in sorted(Array(parameters.keys), <) {
                let value: AnyObject! = parameters[key]
                components += queryComponents(key, value)
            }
            return join("&", components.map({"\($0)=\($1)"}) as [String])
        }
        return query()
    }
    
}
