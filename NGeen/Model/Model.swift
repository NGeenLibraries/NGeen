//
// Model.swift
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

/*TODO: 1. map childs models
        2. pluralize and singularize model
        3. First letter fo the model in upper case
        4. Allow map parent class when the model extends from other
*/

class Model: NSObject {
    
    lazy private var __properties: [String: AnyObject] = {
        var __properties: [String: AnyObject] = Dictionary()
        var outCount: CUnsignedInt = 0;
        var cProperties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(self.dynamicType, &outCount)
        for counter in 0..<outCount {
            let property: objc_property_t = cProperties[Int(counter)]
            let propertyName: String = String.stringWithCString(property_getName(property), encoding: NSUTF8StringEncoding)!
            __properties[propertyName] = String.stringWithCString(property_getAttributes(property), encoding: NSUTF8StringEncoding)!
        }
        return __properties
    }()
    
//MARK: Constructor
    
    required override init() {}

    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        self.fill(dictionary)
    }
    
    /*required init(coder decoder: NSCoder!) {
        super.init()
        for (key, value) in self.__properties {
            self.setValue(decoder.decodeObjectForKey(key), forKey: key)
        }
    }*/
    
//MARK: Instance methods

    /**
    * The function fill the properties of the model with the given dictioanry of values
    *
    * @param dictionary The dictionary with the values for the model.
    *
    */
    
    func fill(dictionary: [String: AnyObject]) {
        for (key, value) in dictionary {
            if  self.hasProperty(key) {
                self.setValue(value, forKey: key)
            }
        }
    }
    
    /**
    * The function return a boolean if the model contains the property
    *
    * @param property The name of the property to search.
    *
    * @return Bool
    */
    
    func hasProperty(property: String) -> Bool {
        if let property: AnyObject = self.__properties[property] {
            return true
        }
        return false
    }
    
    /**
    * The function return the properties for the class
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func properties() -> [String: AnyObject] {
        var properties: [String: AnyObject] = Dictionary()
        for (key, value) in self.__properties {
            if let value: AnyObject = self.valueForKey(key) {
                properties[key] = value
            } else {
                properties[key] = ""
            }
        }
        return properties
    }
    
//MARK: NSCoding protocol

    func encodeWithCoder(aCoder: NSCoder!) {
        for (key, value) in self.properties() {
            aCoder.encodeObject(self.valueForKey(key), forKey: key)
        }
    }

//MARK: Private methods

}