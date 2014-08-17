//
// Hero.swift
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

class Hero: Model {
   
    var id: Int = 0
    var name: String = ""
    var bio: String = ""
    override var description: String {
        set {
            self.bio = newValue
        }
        get {
            return self.bio
        }
    }
    var modified: NSDate = NSDate()
    var resourceURI: String = ""
    var urls: [AnyObject] = Array()
    var thumbnail: [String: AnyObject] = Dictionary()
    var comics: [AnyObject] = Array()
    var stories: [AnyObject] = Array()
    var events: [AnyObject] = Array()
    var series: [AnyObject] = Array()
    
//MARK: Constructor
    
    required init () {}
    
}
