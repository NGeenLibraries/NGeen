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

class ApiStore: NSObject, ConfigurableStoreProtocol {
    
    internal var configurations: Dictionary<String, ConfigurationStoreProtocol>
    private var __endPoints: NSMutableDictionary
    private struct Static {
        static var instace: ApiStore? = nil
        static var token: dispatch_once_t = 0
    }
    
    var endPoints: NSMutableDictionary {
        get {
            return __endPoints
        }
    }
    
//MARK: Constructor
    
    init(config: ConfigurationStoreProtocol) {
        self.configurations = Dictionary<String, ConfigurationStoreProtocol>()
        self.configurations[kDefaultServerName] = config
        self.__endPoints = NSMutableDictionary.dictionary()
    }
    
// MARK: Configurable store protocol
    
    /**
    * The function returns the default configuration from API Store
    *
    * @param no need params
    */
    
    func configuration() -> ConfigurationStoreProtocol {
        return self.configurationForKey(kDefaultServerName)
    }
    
    /**
    * The function returns a configuration from API Store
    *
    * @param key The Identifier of the configuration in dictionary
    *
    */
    
    func configurationForKey(key: String) -> ConfigurationStoreProtocol {
        if let configuration: ConfigurationStoreProtocol = self.configurations[key] {
            return configuration
        } else {
            assert(false, "The configuration can't be null", file: __FILE__, line: __LINE__)
        }
        return ApiStoreConfiguration()
    }
    
    /**
    * The function create and return the last query setted on the default server
    *
    * no need params.
    *
    */
    
    func createQuery() -> ApiQuery {
        if let endPoints: NSMutableDictionary = self.endPoints[kDefaultServerName] as? NSMutableDictionary {
            var key: String =  (endPoints.allKeys as NSArray).lastObject as String
            return ApiQuery(configuration: self.configurationForKey(kDefaultServerName), endPoint: endPoints[key] as ApiEndpoint)
        } else {
            assert(false, "The endopoint can't be null", file: __FILE__, line: __LINE__)
        }
        return  ApiQuery(configuration: self.configurationForKey(kDefaultServerName), endPoint: ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""))
    }
    
    /**
    * The function create and return the query for the given key
    *
    * @param key The id for the query
    *
    * return QueryProtocol
    */
    
    func createQueryWithConfigurationKey(key: String) -> ApiQuery {
        if let endPoint: ApiEndpoint = self.endPoints[key] as? ApiEndpoint {
            var key: String =  (endPoints.allKeys as NSArray).lastObject as String
            return ApiQuery(configuration: self.configurationForKey(key), endPoint: endPoints[key] as ApiEndpoint)
        } else {
            assert(false, "The endopoint can't be null", file: __FILE__, line: __LINE__)
        }
        return  ApiQuery(configuration: self.configurationForKey(kDefaultServerName), endPoint: ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""))
    }
    
    /**
    * The function add a default configuration to the API Store
    *
    * @param config The Object with the server configuration
    *
    */
    
    func setConfiguration(configuration: ConfigurationStoreProtocol) {
        self.configurations[kDefaultServerName] = configuration
    }
    
    /**
    * The function add a configuration to the API Store
    *
    * @param config The Object with server configuration
    * @param key The Identifier of the configuration
    *
    */
    
    func setConfiguration(configuration: ConfigurationStoreProtocol, forKey key: String) {
        self.configurations[key] = configuration
    }
    
 //MARK: Instance methods
    
    /**
    * The function return the endpoint for a given model class
    *
    * @param modelClass The class key to search the endpoint
    * @param method The method for the endpoint
    *
    * return Endpoint
    */
    
    func endpointForModelClass(modelClass: AnyClass, httpMethod method: HttpMethod) -> ApiEndpoint? {
         return self.endpointForModelClass(modelClass, httpMethod: method, serverName: kDefaultServerName)
    }
    
    /**
    * The function return the endpoint for a given model class and server name
    *
    * @param modelClass The class key to search the endpoint
    * @param method The method for the endpoint
    * @param name The name of the server for the endpoint
    *
    * return Endpoint
    */
    
    func endpointForModelClass(modelClass: AnyClass, httpMethod method: HttpMethod, serverName name: String) -> ApiEndpoint? {
        if let serverEndpoints: NSMutableDictionary = self.endPoints[name] as? NSMutableDictionary {
            return serverEndpoints[ApiEndpoint.keyForModelClass(modelClass, httpMethod: method)] as? ApiEndpoint
        }
        return nil
    }
    
    /**
    * The function return the body items for the default configuration
    *
    * no need params.
    *
    * @return NSDictionary
    */
    
    func getBodyItems() -> NSDictionary {
        return self.getBodyItemsForServer(kDefaultServerName)
    }
    
    /**
    * The function return the a bodies for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return NSDictionary
    */
    
    func getBodyItemsForServer(server: String) -> NSDictionary {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.bodyItems
    }
    
    /**
    * The function return the cache policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCachePolicy() -> NSURLRequestCachePolicy {
        return self.getCachePolicyForServer(kDefaultServerName)
    }
    
    /**
    * The function return the cache policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCachePolicyForServer(server: String) -> NSURLRequestCachePolicy {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.cachePolicy
    }
    
    /**
    * The function return the cache storage policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLCacheStoragePolicy
    */
    
    func getCacheStoragePolicy() -> NSURLCacheStoragePolicy {
        return self.getCacheStoragePolicyForServer(kDefaultServerName)
    }
    
    /**
    * The function return the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    * @return NSURLCacheStoragePolicy
    */
    
    func getCacheStoragePolicyForServer(server: String) -> NSURLCacheStoragePolicy {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.cacheStoragePolicy
    }
    
    /**
    * The function return the headers for the default server configuration
    *
    * no need params.
    *
    * @return Dictionary
    */
    
    func getHeaders() -> Dictionary<String, String> {
        return self.getHeadersForServer(kDefaultServerName)
    }
    
    /**
    * The function return the headers for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return Dictionary
    */
    
    func getHeadersForServer(server: String) -> Dictionary<String, String> {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.headers
    }
    
    /**
    * The function return the model path for the default server configuration
    *
    * @param path The path of the models in the api response.
    *
    * @return String
    */
    
    func getModelsPath() -> String {
        return self.getModelsPathForServer(kDefaultServerName)
    }
    
    /**
    * The function return the model path for the given server name
    *
    * @param path The path of the models in the api response.
    * @param name The name of the server to store the configuration.
    *
    * @return String
    */
    
    func getModelsPathForServer(server: String) -> String {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.modelsPath
    }
    
    /**
    * The function return the path items for the default server configuration
    *
    * no need params.
    *
    * @return Dictionary
    */
    
    func getPathItems() -> Dictionary<String, String> {
        return self.getPathItemsForServer(kDefaultServerName)
    }
    
    /**
    * The function return the path items for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return Dictionary
    */
    
    func getPathItemsForServer(server: String) -> Dictionary<String, String> {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.pathItems
    }
    
    /**
    * The function return the query items for the default server configuration
    *
    * no need params.
    * @param key The name for the query field.
    *
    * @return Dictionary
    */
    
    func getQueryItems() -> Dictionary<String, String> {
        return self.getQueryItemsForServer(kDefaultServerName)
    }
    
    /**
    * The function return the query items for the given server name
    *
    * no need params.
    *
    * @return Dictionary
    */
    
    func getQueryItemsForServer(server: String) -> Dictionary<String, String> {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.queryItems
    }
    
    /**
    * The function return the response type for a server configuration
    *
    * @param no need params.
    *
    * @return ResponseType
    */
    
    func getResponseType() -> ResponseType {
        return self.getResponseTypeForServer(kDefaultServerName)
    }
    
    /**
    * The function return the response type for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return ResponseType
    */
    
    func getResponseTypeForServer(server: String) -> ResponseType {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        return configuration.responseType
    }
    
    /**
    * The function set a body for the default server configuration
    *
    * @param item The item value for the body.
    * @param key The value for the body field.
    *
    */
    
    func setBodyItem(item: AnyObject, forKey key: String) {
        self.setBodyItem(item, forKey: key, serverName: kDefaultServerName)
    }
    
    /**
    * The function set a body for a server configuration
    *
    * @param item The item value for the body.
    * @param key The value for the body field.
    * @param name The name of the server to store the configuration.
    *
    */
    
    func setBodyItem(item: AnyObject, forKey key: String, serverName server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.bodyItems[key] = item
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set the body items for the default server configuration
    *
    * @param items The items values for the body.
    *
    */
    
    func setBodyItems(items: Dictionary<String, AnyObject>) {
        self.setBodyItems(items, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the body items for a server configuration
    *
    * @param items The items values for the body.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setBodyItems(items: Dictionary<String, AnyObject>, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.bodyItems = NSMutableDictionary(dictionary: items)
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set the cache request policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCachePolicy(policy: NSURLRequestCachePolicy) {
        self.setCachePolicy(policy, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setCachePolicy(policy: NSURLRequestCachePolicy, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.cachePolicy = policy
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set the cache storage policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCacheStoragePolicy(policy: NSURLCacheStoragePolicy) {
        self.setCacheStoragePolicy(policy, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setCacheStoragePolicy(policy: NSURLCacheStoragePolicy, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.cacheStoragePolicy = policy
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function store the endpoint in the local dictionary
    *
    * @param endpoint The given endpoint to store
    *
    */
    
    func setEndpoint(endpoint: ApiEndpoint) {
        self.setEndpoint(endpoint, forServer: kDefaultServerName)
    }
    
    /**
    * The function store the endpoint for a given server name in the local dictionary
    *
    * @param endpoint The given endpoint to store
    * @param server The name of the server to store the endpoint.
    *
    */
    
    func setEndpoint(endpoint: ApiEndpoint, forServer server: String) {
        if let serverEndpoints: NSMutableDictionary = self.endPoints[server] as? NSMutableDictionary {
             serverEndpoints[endpoint.key()] = endpoint
        } else {
            var serverEndpoints: NSMutableDictionary = NSMutableDictionary.dictionary()
            serverEndpoints.setObject(endpoint, forKey: endpoint.key())
            self.__endPoints[server] = serverEndpoints
        }
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
        self.setFileData(data, forName: name, fileName: file, mimeType: mime, serverName: kDefaultServerName)
    }
    
    /**
    * The function set the data for a given image
    *
    * @param data The data with the contents of the image.
    * @param name The name for the image in the body.
    * @param file The file name for the image in the body.
    * @param mime The mime type of the image.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setFileData(data: NSData, forName name: String, fileName file: String, mimeType mime: String, serverName server: String) {
        assert(file != nil, "You should provide the file name for the file", file: __FILE__, line: __LINE__)
        assert(name != nil, "You should provide a name for the file", file: __FILE__, line: __LINE__)
        assert(mime != nil, "You should provide a mime type for the file", file: __FILE__, line: __LINE__)
        assert(server != nil, "You should provide a server type for the file", file: __FILE__, line: __LINE__)
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.bodyItems[kDefaultImageKeyData] =  ["data": data, "fileName": file, "name": name, "mimeType": mime]
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set a headers for the default server configuration
    *
    * @param header The value for the header.
    * @param key The value for the header field.
    *
    */
    
    func setHeader(header: String, forKey key: String) {
        self.setHeader(header, forKey: key, serverName: kDefaultServerName)
    }
    
    /**
    * The function set a headers for the default server configuration
    *
    * @param header The value for the header.
    * @param key The value for the header field.
    * @param name The name of the server to store the configuration.
    *
    */
    
    func setHeader(header: String, forKey key: String, serverName name: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(name) as ApiStoreConfiguration
        configuration.headers[key] = header
        self.setConfiguration(configuration, forKey: name)
    }
    
    /**
    * The function set the headers for the default server configuration
    *
    * @param headers The dictionary with the headers.
    *
    */
    
    func setHeaders(headers: Dictionary<String, String>) {
        self.setHeaders(headers, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the headers for the given server name
    *
    * @param headers The dictionary with the headers.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setHeaders(headers: Dictionary<String, String>, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.headers += headers
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set the model path for the default server configuration
    *
    * @param path The path of the models in the api response.
    *
    */
    
    func setModelsPath(path: String) {
        self.setModelsPath(path, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the model path for the given server name
    *
    * @param path The path of the models in the api response.
    * @param name The name of the server to store the configuration.
    *
    */
    
    func setModelsPath(path: String, forServer name: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(name) as ApiStoreConfiguration
        configuration.modelsPath = path
        self.setConfiguration(configuration, forKey: name)
    }
    
    /**
    * The function set a path items for the default server configuration
    *
    * @param header The value for the path.
    * @param key The name for the path field.
    *
    */
    
    func setPathItem(item: String, forKey key: String) {
        self.setPathItem(item, forKey: key, serverName: kDefaultServerName)
    }
    
    /**
    * The function set a path item for the given server name
    *
    * @param item The value for the path.
    * @param key The name for the path field.
    * @param name The name for the server to store the configuration.
    *
    */
    
    func setPathItem(item: String, forKey key: String, serverName name: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(name) as ApiStoreConfiguration
        configuration.pathItems[key] = item
        self.setConfiguration(configuration, forKey: name)
    }
    
    /**
    * The function set the path items for the default server configuration
    *
    * @param items The dictionary with the path items.
    *
    */
    
    func setPathItems(items: Dictionary<String, String>) {
        self.setPathItems(items, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the path items for the given server name
    *
    * @param items The dictionary with the path items.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setPathItems(items: Dictionary<String, String>, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.pathItems += items
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set a query item for the default server configuration
    *
    * @param header The value for the header.
    * @param key The name for the query field.
    *
    */
    
    func setQueryItem(item: String, forKey key: String) {
        self.setQueryItem(item, forKey: key, serverName: kDefaultServerName)
    }
    
    /**
    * The function set a query item for the given server name
    *
    * @param item The value for the path.
    * @param key The value for the query field.
    * @param name The name for the server to store the configuration.
    *
    */
    
    func setQueryItem(item: String, forKey key: String, serverName name: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(name) as ApiStoreConfiguration
        configuration.queryItems[key] = item
        self.setConfiguration(configuration, forKey: name)
    }
    
    /**
    * The function set the query items for the default server configuration
    *
    * @param items The dictionary with the query items.
    *
    */
    
    func setQueryItems(items: Dictionary<String, String>) {
        self.setQueryItems(items, forServer: kDefaultServerName)
    }
    
    /**
    * The function set a query item for the given server name
    *
    * @param items The dictionary with the query items.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setQueryItems(items: Dictionary<String, String>, forServer server: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.queryItems += items
        self.setConfiguration(configuration, forKey: server)
    }
    
    /**
    * The function set the response type for the server configuration
    *
    * @param type The type of the response.
    *
    */
    
    func setResponseType(type: ResponseType) {
        self.setResponseType(type, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the response type for the server configuration
    *
    * @param type The type of the response.
    * @param name The name for the server to store the configuration.
    *
    */
    
    func setResponseType(type: ResponseType, forServer name: String) {
        let configuration: ApiStoreConfiguration = self.configurationForKey(name) as ApiStoreConfiguration
        configuration.responseType = type
        self.setConfiguration(configuration, forKey: name)
    }
    
    /**
    * The function set the data for a given file
    *
    * @param data The data with the contents of the file.
    *
    */
    
    func setTextData(data: String) {
        self.setTextData(data, forServerName: kDefaultServerName)
    }
    
    /**
    * The function set the data for a given file
    *
    * @param data The data with the contents of the file.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setTextData(data: String, forServerName server: String) {
        assert(server != nil, "You should provide a server type for the file", file: __FILE__, line: __LINE__)
        let configuration: ApiStoreConfiguration = self.configurationForKey(server) as ApiStoreConfiguration
        configuration.bodyItems[kDefaultFileKeyData] =  data
        self.setConfiguration(configuration, forKey: server)
    }
    
//MARK: Singleton method
    
    class func defaultStore() -> ApiStore {
        dispatch_once(&Static.token, {
            Static.instace = ApiStore(config: ApiStoreConfiguration())
        })
        return Static.instace!
    }
    
}
