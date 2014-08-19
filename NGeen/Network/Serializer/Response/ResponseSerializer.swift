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

/*TODO: find way to do a deep copy of the response when the dictionary have null value */

class ResponseSerializer: NSObject {
   
//MARK: Instance methods
    
    /**
    * The function serialize the data and return the json
    *
    * @param configuration The configuration for the response.
    * @param endpoint The endpoint with the model class.
    * @param data The data to serialize.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return AnyObject
    */
    
    func responseWithConfiguration(configuration: ApiStoreConfiguration, endPoint endpoint: ApiEndpoint, data: NSData, error: NSErrorPointer) -> AnyObject {
        switch configuration.responseType {
            case .data:
                return self.responseInDataFormatForData(data, error: error)
            case .json:
               return self.responseInJSONFormatForData(data, error: error)
            case .models:
                switch endpoint.httpMethod {
                    case .get:
                        assert(endpoint.modelClass! != nil, "The model class should be diferent than null", file: __FILE__, line: __LINE__)
                        assert(!configuration.modelsPath.isEmpty, "The path for the models should be diferent than null", file: __FILE__, line: __LINE__)
                        return self.responseInModelsForData(data, modelClass: endpoint.modelClass!, modelsPath: configuration.modelsPath, error: error)
                    default:
                        return self.responseInJSONFormatForData(data, error: error)
                }
            default:
                return self.responseInStringFormatForData(data, error: error)
        }
    }
    
    /**
    * The function serialize the data and return the string
    *
    * @param data The data to serialize.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return NSData
    */
    
    func responseInDataFormatForData(data: NSData, error: NSErrorPointer) -> NSData {
        return data
    }
    
    /**
    * The function serialize the data and return the json
    *
    * @param data The data to serialize.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return AnyObject
    */
    
    func responseInJSONFormatForData(data: NSData, error: NSErrorPointer) -> AnyObject {
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: error)
    }
    
    /**
    * The function serialize the data and return the an array of models
    *
    * @param data The data to serialize.
    * @params className The name of the model to create.
    * @param modelsPath The path of the model in the response.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return Array
    */
    
    func responseInModelsForData(data: NSData, modelClass className: NSObject.Type, modelsPath path: String, error: NSErrorPointer) -> [String: AnyObject] {
        var response: [String: AnyObject] = Dictionary()
        if let jsonDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: error) as? NSDictionary {
            response = jsonDictionary.mutableCopy() as [String: AnyObject]
            let values: AnyObject! = jsonDictionary.valueForKeyPath(path)
            if values is Array<NSDictionary> {
                var models: Array<Model> = Array<Model>()
                for value in values as [NSDictionary] {
                    var model = className() as Model
                    model.fill(value as [String: AnyObject])
                    models.append(model)
                }
                response[kNGeenModelsField] = models
            } else if values is Dictionary<String, AnyObject> {
                var model = className() as Model
                model.fill(values as [String: AnyObject])
                response[kNGeenModelsField] = model
            }
        }
        return response
    }
    
    /**
    * The function serialize the data and return the string
    *
    * @param data The data to serialize.
    * @param error The pointer to handle any error in the serialization process.
    *
    * @return String
    */
    
    func responseInStringFormatForData(data: NSData, error: NSErrorPointer) -> String {
        return NSString(data: data, encoding: NSUTF8StringEncoding)
    }
    
}
