//
// ResponseSerializer.swift
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

// TODO: find way to do a deep copy of the response when the dictionary have null value */

class ResponseSerializer: NSObject, ResponseSerializerProtocol {
   
    var acceptableContentTypes: NSSet?
    var acceptableStatusCodes: NSIndexSet
    var stringEncoding: NSStringEncoding
    
    // MARK: Constructor
    
    override init() {
        self.acceptableStatusCodes =  NSIndexSet(indexesInRange: NSMakeRange(200, 100))
        self.stringEncoding = NSUTF8StringEncoding
    }
    
    // MARK: Instance methods
    
    /**
    * The function remove all the null values from the given object
    *
    * @param JSONObject The object with the response values.
    *
    * @return AnyObject
    */
    
    func removeNullValues(JSONObject: AnyObject) -> AnyObject {
        if JSONObject.isKindOfClass(NSArray.self) {
            let mutableArray = NSMutableArray(capacity: (JSONObject as NSArray).count)
            for value in (JSONObject as NSArray) {
                mutableArray.addObject(self.removeNullValues(value))
            }
            return mutableArray.copy() as NSArray
        } else if JSONObject.isKindOfClass(NSDictionary.self) {
            let mutableDictionary = (JSONObject as NSDictionary).mutableCopy() as NSMutableDictionary
            for (key, value) in (JSONObject as NSDictionary) {
                if value.isEqual(NSNull.self) {
                    mutableDictionary.removeObjectForKey(key)
                } else if value.isKindOfClass(NSArray.self) || value.isKindOfClass(NSDictionary.self) {
                    mutableDictionary.setObject(self.removeNullValues(value), forKey: (key as String))
                }
            }
            return mutableDictionary.copy() as NSDictionary
        }
        return JSONObject
    }
    
    /**
    * The function serialize the data and return the string
    *
    * @param data The data to serialize.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return AnyObject
    */
    
    func responseObjectForData(data: NSData, urlResponse: NSURLResponse?, var error: NSError?) -> AnyObject? {
        if urlResponse != nil && !self.validateResponse(urlResponse!, data: data, error: error) {
            return nil
        }
        return NSString(data: data, encoding: self.stringEncoding)
    }
    
    /**
    * The function validate the response from the server
    *
    * @param urlResponse The response given from the server.
    * @param data The data returned for the server.
    * @param error The pointer to handle any error occurred on the method.
    *
    * @return Bool
    */
    
    func validateResponse(urlResponse: NSURLResponse, data: NSData, var error: NSError?) -> Bool {
        var valid = true
        var validationError: NSError?
        if urlResponse.isKindOfClass(NSHTTPURLResponse.self) {
            if let contains = self.acceptableContentTypes?.containsObject(urlResponse.MIMEType) {
                if data.length > 0 {
                    let userInfo = [NSLocalizedDescriptionKey: "unacceptable content-type: \(urlResponse.MIMEType)", NSURLErrorFailingURLErrorKey: urlResponse.URL, "object": urlResponse]
                    validationError = NSError(domain: kNGeenResponseSerializationErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: userInfo)
                }
                valid = false
            }
            if self.acceptableStatusCodes.containsIndex((urlResponse as NSHTTPURLResponse).statusCode) {
                let userInfo = [NSLocalizedDescriptionKey: "Request failed", NSURLErrorFailingURLErrorKey: urlResponse.URL, "object": urlResponse]
                validationError = NSError(domain: kNGeenResponseSerializationErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                valid = false
            }
        }
        if validationError != nil && !valid {
            error = validationError!
        }
        return valid
    }
    
}

class JSONResponseSerializer: ResponseSerializer, ResponseSerializerProtocol {
    
    private(set) var readingOptions: NSJSONReadingOptions
    
    init(JSONReadingOptions: NSJSONReadingOptions) {
        self.readingOptions = JSONReadingOptions
        super.init()
        self.acceptableContentTypes =  NSSet(objects: "application/json", "text/json", "text/javascript")
    }
    
    // MARK: ResponseSerializer protocol
    
    /**
    * The function serialize the data and return the json
    *
    * @param data The data to serialize.
    * @param urlResponse The response given for the server.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return AnyObject
    */
    
    override func responseObjectForData(data: NSData, urlResponse: NSURLResponse?, var error: NSError?) -> AnyObject? {
        if urlResponse != nil && !self.validateResponse(urlResponse!, data: data, error: error) {
            return nil
        }
        var errorPointer: NSErrorPointer = nil
        let response: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: self.readingOptions, error: errorPointer)
        if errorPointer != nil {
            let userInfo = [NSLocalizedDescriptionKey: "Failed the serialization to JSON object", NSLocalizedFailureReasonErrorKey: "Could not decode data"]
            error = NSError(domain: kNGeenResponseSerializationErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: userInfo)
        }
       return response
    }
}

class ModelsResponseSerializer: ResponseSerializer, ResponseSerializerProtocol {
    
    var className: NSObject.Type
    var path: String
    
    init(modelClass className: NSObject.Type, path modelsPath: String) {
        self.className = className
        self.path = modelsPath
        super.init()
        self.acceptableContentTypes =  NSSet(objects: "application/json", "text/json", "text/javascript")
    }
    
    // MARK: ResponseSerializer protocol
    
    /**
    * The function serialize the data and return the json
    *
    * @param data The data to serialize.
    * @param urlResponse The response given for the server.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return AnyObject
    */
    
    override func responseObjectForData(data: NSData, urlResponse: NSURLResponse?, var error: NSError?) -> AnyObject? {
        assert(self.className != nil, "The model class should be diferent than null", file: __FILE__, line: __LINE__)
        assert(!self.path.isEmpty, "The path for the models should be diferent than null", file: __FILE__, line: __LINE__)
        if urlResponse != nil && !self.validateResponse(urlResponse!, data: data, error: error) {
            return nil
        }
        var errorPointer: NSErrorPointer = nil
        let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: errorPointer) as? NSDictionary
        if errorPointer != nil {
            let userInfo = [NSLocalizedDescriptionKey: "Failed the serialization to models object", NSLocalizedFailureReasonErrorKey: "Could not decode data"]
            error = NSError(domain: kNGeenResponseSerializationErrorDomain, code: NSURLErrorCannotDecodeContentData, userInfo: userInfo)
        }
        if jsonDictionary != nil {
            var response: NSMutableDictionary = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, jsonDictionary!, 1) as NSMutableDictionary
            let values: AnyObject! = jsonDictionary?.valueForKeyPath(self.path)
            if values is Array<NSDictionary> {
                var models: Array<Model> = Array<Model>()
                for value in values as [NSDictionary] {
                    var model = self.className() as Model
                    model.fill(value as [String: AnyObject])
                    models.append(model)
                }
                response.setValue(models, forKeyPath: self.path)
            } else if values is Dictionary<String, AnyObject> {
                var model = self.className() as Model
                model.fill(values as [String: AnyObject])
                response.setValue(model, forKeyPath: self.path)
            }
            return response
        }
        return nil
    }
}
