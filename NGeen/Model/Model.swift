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

// TODO: 1. Check if iskindofclass model

class Model: NSObject {
    
    lazy private var __properties: [String: AnyObject] = {
        return self.getPropertiesFromClass(self.dynamicType)
    }()
    private var queue: dispatch_queue_t
    
    // MARK: Constructor
    
    required override init() {
        self.queue = dispatch_queue_create("com.ngeen.modelqueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    /*required init(coder decoder: NSCoder!) {
        super.init()
        for (key, value) in self.__properties {
            self.setValue(decoder.decodeObjectForKey(key), forKey: key)
        }
    }*/
    
    // MARK: Instance methods

    /**
    * The function fill the properties of the model with the given dictioanry of values
    *
    * @param dictionary The dictionary with the values for the model.
    *
    */
    
    func fill(dictionary: [String: AnyObject]) {
        let bundleName: String = (NSBundle.mainBundle().infoDictionary as NSDictionary)[kCFBundleNameKey] as String
        for (key, value) in dictionary {
            if self.hasProperty(key) {
                if let modelClass: NSObject.Type = NSClassFromString("\(bundleName).\(key.singularize().capitalizedString)") as? NSObject.Type {
                    // TODO: Check if iskindofclass model
                    if value is [[String: AnyObject]] {
                        var models: [AnyObject] = Array()
                        for values in value as [[String: AnyObject]] {
                            let model = modelClass() as Model
                            model.fill(values as [String: AnyObject])
                            models.append(model)
                        }
                        self.setValue(models, forKey: key)
                    } else if value is [String: AnyObject] {
                        let model: Model = modelClass() as Model
                        model.fill(value as [String: AnyObject])
                        self.setValue(model, forKey: key)
                    }
                } else if value != nil && !value.isKindOfClass(NSNull.self) {
                    self.setValue(value, forKey: key)
                }
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
    
    // MARK: NSCoding protocol

    func encodeWithCoder(aCoder: NSCoder!) {
        for (key, value) in self.properties() {
            aCoder.encodeObject(self.valueForKey(key), forKey: key)
        }
    }

    // MARK: Private methods

    /**
    * The function get the properties for the class included the parents class
    *
    * @param className The name of the class to fecth the properties.
    *
    * @return Dictionary
    */

    private func getPropertiesFromClass(className: AnyClass) -> [String: AnyObject] {
        var properties: [String: AnyObject] = Dictionary()
        if (className.superclass().isSubclassOfClass(Model.self)) {
            properties += self.getPropertiesFromClass(className.superclass())
        }
        properties.removeValueForKey("description")
        var outCount: CUnsignedInt = 0;
        var cProperties: UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(className, &outCount)
        for counter in 0..<outCount {
            let property: objc_property_t = cProperties[Int(counter)]
            let propertyName: String = String.stringWithCString(property_getName(property), encoding: NSUTF8StringEncoding)!
            properties[propertyName] = String.stringWithCString(property_getAttributes(property), encoding: NSUTF8StringEncoding)!
        }
        return properties
    }

}