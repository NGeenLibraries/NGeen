//
// ApiQuery.swift
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

class ApiQuery: NSObject, QueryProtocol {
    
    internal var config: ConfigurationStoreProtocol? {
        get {
            return __config
        }
        set(config) {
            __config = config as? ApiStoreConfiguration
        }
    }
    private struct NGImageBodyPart {
        
        var data: NSData
        var fileName: String
        var mimeType: String
        var name: String

        init(bodies: NSDictionary) {
            self.data = bodies["data"] as NSData!
            self.fileName = bodies["fileName"] as String!
            self.mimeType = bodies["mimeType"] as String!
            self.name = bodies["name"] as String!
        }
    }
    private var __config: ApiStoreConfiguration?
    private var endPoint: ApiEndpoint
    private var sessionManager: SessionManager?
    private var urlComponents: NSURLComponents = NSURLComponents(string: "")
    
    weak var delegate: ApiQueryDelegate?
    
//MARK: Constructor
    
    init(configuration: ConfigurationStoreProtocol, endPoint: ApiEndpoint) {
        self.endPoint = endPoint
        self.urlComponents.path = (self.endPoint.path != nil ? self.endPoint.path : "")
        super.init()
        self.config = configuration
        self.sessionManager = SessionManager(sessionConfiguration: self.__config!.sessionConfiguration)
        if let credential: NSURLCredential = self.__config!.credential {
            self.sessionManager!.setAuthenticationCredential(self.__config!.credential!, forProtectionSpace: self.__config!.protectionSpace!)
        }
        self.sessionManager!.responseDisposition = self.__config!.responseDisposition
        self.urlComponents.scheme = self.__config!.scheme
        self.urlComponents.host = self.__config!.host
    }
    
// MARK: Instance methods    
    
    /**
    * The function set to the request the parameters to download a object
    *
    * @param destination The destination to store the file.
    * @params handler The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    *
    * return NSURLSessionDownloadTask
    */
    
    func download(destination: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDownloadTask {
        let downloadTask: NSURLSessionDownloadTask = self.sessionManager!.downloadTaskWithRequest(self.request(), destination: destination, progress: handler, completionHandler: closure)
        downloadTask.resume()
        return downloadTask
    }
    
    /**
    * The function set to the request the parameters to download a object
    *
    * @param data The partial data.
    * @param destination The destination to store the file.
    * @params handler The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    *
    * return NSURLSessionDownloadTask
    */
    
    func downloadWithResumeData(data: NSData, destination url: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDownloadTask {
        let downloadTask: NSURLSessionDownloadTask = self.sessionManager!.downloadTaskWithResumeData(data, destination: url, progress: handler, completionHandler: closure)
        downloadTask.resume()
        return downloadTask
    }
    
    /**
    * The function return the body items
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getBodyItems() -> NSDictionary {
        return self.__config!.bodyItems
    }
    
    /**
    * The function return the body
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getBody() -> String {
        if self.endPoint.contentType! == ContentType.json {
            let data: NSData = NSJSONSerialization.dataWithJSONObject(self.__config!.bodyItems, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        } else if self.endPoint.contentType == ContentType.multiPartForm {
            return self.encodeMultipart(self.__config!.bodyItems)
        }
        return self.encode(self.__config!.bodyItems)
    }
    
    /**
    * The function return the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCachePolicy() -> NSURLRequestCachePolicy {
        return self.__config!.sessionConfiguration.requestCachePolicy
    }
    
    /**
    * The function return the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCacheStoragePolicy() -> NSURLCacheStoragePolicy {
        return self.__config!.cacheStoragePolicy
    }
    
    /**
    *  The function return the configuration for the api query
    *
    *  @return ApiStoreConfig
    */
    
    func getConfiguration() -> ApiStoreConfiguration {
        return self.__config!
    }
    
    
    /**
    * The function return the http headers
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getHttpHeaders() -> Dictionary<String, String> {
        return self.__config!.headers
    }
    
    /**
    * The function return model path
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getModelsPath() -> String {
        return self.__config!.modelsPath
    }
    
    /**
    * The function return the path items
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getPathItems() -> Dictionary<String, String> {
        return self.__config!.pathItems
    }
    
    /**
    * The function return the full path for the components
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getPath() -> String {
        return self.urlComponents.path
    }
    
    /**
    * The function return the query string
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getQuery() -> String? {
        return self.urlComponents.query
    }
    
    /**
    * The function return the response disposition for the request
    *
    * @param no need params.
    *
    * @return NSURLSessionResponseDisposition
    */
    
    func getResponseDisposition() -> NSURLSessionResponseDisposition {
        return self.__config!.responseDisposition
    }
    
    /**
    * The function return the response type for the request
    *
    * @param no need params.
    *
    * @return ResponseType
    */
    
    func getResponseType() -> ResponseType {
        return self.__config!.responseType
    }
    
    /**
    * The function execute the request
    *
    * @param completionHandler The closure to be called when the function end.
    *
    */
    
    func execute(completionHandler closure: NGeenClosure) {
        assert(self.urlComponents.URL != nil, "The url cant be null", file: __FUNCTION__, line: __LINE__)
        let sessionDataTask: NSURLSessionDataTask = self.sessionManager!.dataTaskWithRequest(self.request(), completionHandler: {(data, urlResponse, error) in
            if closure != nil {
                closure!(object: self.responseForData(data), error: error)
            }
        })
        sessionDataTask.resume()
    }

    /**
    * The function execute the request
    *
    * @params parameters The parameters for the request.
    * @param completionHandler The closure to be called when the function end.
    *
    */
    
    func execute(parameters: Dictionary<String, String>, completionHandler closure: NGeenClosure) {
        switch self.endPoint.httpMethod! {
            case .delete, .get, .head:
                self.setQueryItems(parameters)
            case .patch, .post, .put:
                self.__config!.bodyItems += parameters
            default:
                assert(false, "Invalid http method", file: __FILE__, line: __LINE__)
        }
        self.execute(completionHandler: closure)
    }
    
    /**
    * The function store the body item in a local dictionary
    *
    * @param item The body item.
    * param key The key for the given item.
    *
    */
    
    func setBodyItem(item: AnyObject, forKey key: String) {
        self.__config!.bodyItems[key] = item
    }
    
    /**
    * The function store the body the items in a local dictionary
    *
    * @param items The body items for the request.
    *
    */
    
    func setBodyItems(items: [String: AnyObject]) {
        self.__config!.bodyItems += items
    }
    
    /**
    * The function set the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCachePolicy(policy: NSURLRequestCachePolicy) {
        self.__config!.sessionConfiguration.requestCachePolicy = policy
    }
    
    /**
    * The function set the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCacheStoragePolicy(policy: NSURLCacheStoragePolicy) {
        self.__config!.cacheStoragePolicy = policy
    }
    
    /**
    * The function set the data for a given image
    *
    * @param data The data with the contents of the image.
    * @param name The name for the image in the body.
    * @param file The file name for the image in the body.
    * @param mime The mime type of the image.
    *
    */
    
    func setFileData(data: NSData, forName name: String, fileName file: String, mimeType mime: String) {
        assert(file != nil, "You should provide the file name for the file", file: __FILE__, line: __LINE__)
        assert(name != nil, "You should provide a name for the file", file: __FILE__, line: __LINE__)
        assert(mime != nil, "You should provide a mime type for the file", file: __FILE__, line: __LINE__)
        self.__config!.bodyItems[kDefaultImageKeyData] = ["data": data, "fileName": file, "name": name, "mimeType": mime]
    }
    
    /**
    * The function set a value for the local headers
    *
    * @param header The value for the header.
    * @param key The value for the header field.
    *
    */
    
    func setHeader(header: String, forKey key: String) {
        self.__config!.headers[key] = header
    }
    
    /**
    * The function set the headers in a local dictionary
    *
    * @param headers The headers for the request.
    *
    */
    
    func setHeaders(headers: Dictionary<String, String>) {
        self.__config!.headers += headers
    }

    /**
    * The function set the model path for the api response
    *
    * @param path The path of the models in the api response.
    *
    */
    
    func setModelsPath(path: String) {
        self.__config?.modelsPath = path
    }
   
    /**
    * The function store a path item in a local dictionary
    *
    * @param item The path item.
    * @param key The key for the given item.
    *
    */
    
    func setPathItem(item: String, forKey key: String) {
        self.__config!.pathItems[key] = item
        self.urlComponents.path = "\(self.urlComponents.path)/\(item)"
    }
    
    /**
    * The function store the path items in a local dictionary
    *
    * @param items The path items.
    *
    */
    
    func setPathItems(items: Dictionary<String, String>) {
        self.__config!.pathItems += items
        for (key, value) in items {
            self.urlComponents.path = "\(self.urlComponents.path)/\(value)"
        }
    }
    
    /**
    * The function store a query item in a local dictionary
    *
    * @param item The query item.
    * @param key The key for the given query item.
    *
    */
    
    func setQueryItem(item: AnyObject, forKey key: String) {
        self.__config!.queryItems[key] = item
        self.urlComponents.query = (!self.urlComponents.query ? "" : self.urlComponents.query + "&") + "\(self.encode([key: item]))"
    }
    
    /**
    * The function store the query items in a local dictionary
    *
    * @param items The query items.
    *
    */
    
    func setQueryItems(items: Dictionary<String, AnyObject>) {
        self.urlComponents.query = (!self.urlComponents.query ? "" : self.urlComponents.query + "&") + "\(self.encode(items))"
    }
    
    /**
    * The function set the response disposition to the API Store
    *
    * @param disposition The disposition for the request.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition) {
        self.__config!.responseDisposition = disposition
    }
    
    /**
    * The function set the response type for the query
    *
    * @param type The response type.
    *
    */
    
    func setResponseType(type: ResponseType) {
        self.__config!.responseType = type
    }
    
    /**
    * The function set the session configuration
    *
    * @param sessionConfiguration The session Configuration.
    *
    */
    
    func setSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration) {
        self.__config!.sessionConfiguration = sessionConfiguration
    }
    
    /**
    * The function set to the request the parameters to upload a file
    *
    * @param data The data to upload.
    * @params handler The closure to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(data: NSData, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        self.upload(data, uploadType: UploadType.data, progress: handler, completionHandler: closure)
    }
    
    /**
    * The function set to the request the parameters to upload a file
    *
    * @param file The url of the file to upload.
    * @params handler The handler to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(file: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        self.upload(file, uploadType: UploadType.file, progress: handler, completionHandler: closure)
    }
    
    /**
    * The function set to the request the parameters to upload a stream
    *
    * @param stream The stream to upload.
    * @params handler The handler to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(stream: NSInputStream, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        self.upload(stream, uploadType: UploadType.stream, progress: handler, completionHandler: closure)
    }
    
// MARK: Private methods
    
    /**
    * The function encode the params for the given content type
    *
    * @param parameters The dictionary with the params to encode.
    *
    * @return String
    */
    
    private func encode(parameters: [String: AnyObject]) -> String {
        
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
    
    /**
    * The function encode the params in mutlipart form for the given content type
    *
    * @param parameters The dictionary with the params to encode.
    *
    * @return String
    */
    
    private func encodeMultipart(parameters: [String: AnyObject]) -> String {
        assert(parameters[kDefaultImageKeyData] != nil, "The multipart form should have at least a image in the body", file: __FUNCTION__, line: __LINE__)
        let boundary: String = "--Boundary+\(CFAbsoluteTimeGetCurrent())\r\n"
        var params: String = ""
        for (key, value) in parameters {
            if (key as String) == kDefaultImageKeyData {
                let imageBodyPart: NGImageBodyPart = NGImageBodyPart(bodies: parameters[kDefaultImageKeyData] as NSDictionary)
                params = "\(params)\(boundary) Content-Disposition: form-data; name=\"\(imageBodyPart.name)\"; filename=\"\(imageBodyPart.fileName)\"\r\n Content-Type: \(imageBodyPart.mimeType)\r\n\r\n \(imageBodyPart.data)\r\n"
            } else {
                params = "\(params)\(boundary) Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n \(value)\r\n"
            }
        }
        params = "\(params)\(boundary)--\r\n"
        return params
    }
    
    /**
    * The function create a new request for the session
    *
    * no need params.
    *
    * return NSURLRequest
    */
    
    private func request() -> NSURLRequest {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: self.urlComponents.URL)
        request.HTTPMethod = self.endPoint.httpMethod!.toRaw()
        request.setValue(self.endPoint.contentType!.toRaw(), forHTTPHeaderField: "Content-Type")
        for (key, value) in self.__config!.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if (self.__config!.bodyItems.count > 0) {
            assert(self.endPoint.httpMethod != HttpMethod.delete, "You can`t set a body for http delete method", file: __FILE__, line: __LINE__)
            assert(self.endPoint.httpMethod != HttpMethod.get, "You can`t set a body for http get method", file: __FILE__, line: __LINE__)
            if self.endPoint.contentType! == ContentType.json {
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(self.__config!.bodyItems, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            } else if self.endPoint.contentType! == ContentType.multiPartForm {
                request.HTTPBody = self.encodeMultipart(self.__config!.bodyItems).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            } else {
                request.HTTPBody = self.encode(self.__config!.bodyItems).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            }
            request.setValue(request.HTTPBody.length.description, forHTTPHeaderField: "Content-Length")
        }
        return request
    }
    
    /**
    * The function configure the response for the current request
    *
    * @param data The data from the response.
    *
    */
    
    private func responseForData(data: NSData) -> AnyObject {
        if self.__config!.responseType == ResponseType.dictionary {
            if let jsonDictionary: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) {
                return jsonDictionary
            }
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        } else if self.__config!.responseType == ResponseType.models {
            assert(!self.__config!.modelsPath.isEmpty, "You should set the models path for the response type", file: __FUNCTION__, line: __LINE__)
            if let jsonDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                var dictionaries: Array<NSDictionary> = jsonDictionary.valueForKeyPath(self.__config!.modelsPath) as Array<NSDictionary>
                var models: Array<AnyObject> = Array<AnyObject>()
                for value in dictionaries {
                    var model = self.endPoint.modelClass!() as Model
                    model.fill(value as Dictionary<String, AnyObject>)
                    models.append(model)
                }
                return models
            }
        } else if self.__config!.responseType == ResponseType.string {
            return NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        return data
    }
    
    /**
    * The function set to the request the parameters to upload a object
    *
    * @param data The data to upload.
    * @params type The type of the upload.
    * @params handler The closure to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    private func upload(data: AnyObject, uploadType type: UploadType , progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        assert(data != nil, "The file can't be nil", file: __FUNCTION__, line: __LINE__)
        let request: Request = Request(httpMethod: self.endPoint.httpMethod!.toRaw(), url: self.urlComponents.URL)
    }
    
//MARK: Request delegate
    
    func cachedResponseForUrl(url: NSURL, cachedData data: NSData) {
        if self.delegate != nil && self.delegate!.respondsToSelector("cachedResponseForUrl:cachedData:")  {
            self.delegate!.cachedResponseForUrl!(url, cachedData: self.responseForData(data))
        }
    }
    
}
