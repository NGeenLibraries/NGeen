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
    
    internal var configurations: [String: ConfigurationStoreProtocol]
    private struct Static {
        static var instace: ApiStore? = nil
        static var token: dispatch_once_t = 0
    }
    private(set) var endPoints: [String: [String: ApiEndpoint]]
    
    // MARK: Constructor
    
    init(config: ConfigurationStoreProtocol) {
        self.configurations = Dictionary()
        self.configurations[kDefaultServerName] = config
        self.endPoints = Dictionary()
    }
    
    // MARK: Configurable store protocol
    
    /**
    * The function returns a configuration from API Store
    *
    * @param key The Identifier of the configuration in dictionary
    *
    */
    
    func configuration(forServer server: String = kDefaultServerName) -> ConfigurationStoreProtocol {
        if let configuration: ConfigurationStoreProtocol = self.configurations[server] {
            return configuration
        } else {
            assert(false, "The configuration can't be null", file: __FILE__, line: __LINE__)
        }
    }
    
    /**
    * The function create and return the query for the given key
    *
    * @param key The id for the query
    *
    * return ApiQuery
    */
    
    func createQuery(forServer server: String = kDefaultServerName) -> ApiQuery {
        if let endPoints: [String: ApiEndpoint] = self.endPoints[server] {
            return ApiQuery(configuration: self.configuration(forServer: server), endPoint: endPoints.values.last!)
        } else {
            assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
        }
    }
    
    /**
    * The function create and return the query for the given key
    *
    * @param path The path of the endpoint.
    * @param method The http method type for the request.
    * @param name The name of the server to get the endpoints.
    *
    * return ApiQuery
    */
    
    func createQueryForPath(path: String, httpMethod method: HttpMethod, server name: String = kDefaultServerName) -> ApiQuery {
         if let endPoints = self.endPoints[name] {
            if let endPoint = endPoints[ApiEndpoint.keyForPath(path, httpMethod: method)] {
                return ApiQuery(configuration: self.configuration(forServer: name), endPoint: endPoint)
            } else {
                assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
            }
        } else {
            assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
        }
    }
    
    /**
    * The function add a configuration to the API Store
    *
    * @param config The Object with server configuration
    * @param key The Identifier of the configuration
    *
    */
    
    func setConfiguration(configuration: ConfigurationStoreProtocol, forServer server: String = kDefaultServerName) {
        self.configurations[server] = configuration
    }
    
    // MARK: Instance methods
    
    /**
    * The function return the endpoint for a given model class and server name
    *
    * @param path The path key to search the endpoint
    * @param method The method for the endpoint
    * @param name The name of the server for the endpoint
    *
    * return Endpoint
    */
    
    func endpointForPath(path: String, httpMethod method: HttpMethod, serverName name: String = kDefaultServerName) -> ApiEndpoint? {
        return self.endPoints[name]?[ApiEndpoint.keyForPath(path, httpMethod: method)]
    }
   
    /**
    * The function get the authentication credentials for a given server configuration
    *
    * @param server The name of the server to store the configuration.
    *
    * return String
    */
    
    func getAuthenticationCredentials(forServer server: String = kDefaultServerName) -> String {
        var credentials: String?
        if let configuration: ApiStoreConfiguration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            if let credential: NSURLCredential = configuration.credential {
                credentials = "\(credential.user):\(credential.password)"
            }
        }
        return credentials ?? ""
    }

    /**
    * The function return the cache policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCachePolicy() -> NSURLRequestCachePolicy? {
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
    
    func getCachePolicyForServer(server: String) -> NSURLRequestCachePolicy? {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.sessionConfiguration.requestCachePolicy
    }
    
    /**
    * The function return the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    * @return NSURLCacheStoragePolicy
    */
    
    func getCacheStoragePolicy(forServer server: String = kDefaultServerName) -> NSURLCacheStoragePolicy? {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.cacheStoragePolicy
    }
    
    /**
    * The function return the headers for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return Dictionary
    */
    
    func getHeaders(forServer server: String = kDefaultServerName) -> [String: String] {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.headers ?? Dictionary()
    }
    
    /**
    * The function return the model path for the given server name
    *
    * @param path The path of the models in the api response.
    * @param name The name of the server to store the configuration.
    *
    * @return String
    */
    
    func getModelsPath(forServer server: String = kDefaultServerName) -> String {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.modelsPath ?? ""
    }
    
    /**
    * The function get the pinned certificates for the given server
    *
    * @param server The name of the server to store the configuration.
    *
    */
    
    func getPinnedCertificates(forServer server: String = kDefaultServerName) -> [AnyObject] {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.securityPolicy.certificates ?? Array()
    }
    
    /**
    * The function get the response disposition to the default configuration
    *
    * @param server The Identifier of the configuration.
    *
    * @return NSURLSessionResponseDisposition
    */
    
    func getResponseDisposition(forServer server: String = kDefaultServerName) -> NSURLSessionResponseDisposition? {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.responseDisposition
    }
    
    /**
    * The function return the response type for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return ResponseType
    */
    
    func getResponseType(forServer server: String = kDefaultServerName) -> ResponseType? {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.responseType
    }
    
    /**
    * The function get the security policy for the given server
    *
    * @param server The name for the server to store the configuration.
    *
    * return Policy
    */
    
    func getSecurityPolicy(forServer server: String = kDefaultServerName) -> Policy {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.securityPolicy.policy ?? Policy.none
    }
    
    /**
    * The function get the session configuration for the given server
    *
    * @param server The name for the server to get the configuration.
    *
    * return NSURLSessionConfiguration
    */
    
    func getSessionConfiguration(forServer server: String = kDefaultServerName) -> NSURLSessionConfiguration? {
        let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration
        return configuration?.sessionConfiguration

    }
    
    /**
    * The function set the if the given server configuration accept invalid certificates
    *
    * @param allow The true or false.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAllowInvalidCertificates(allow: Bool, forServer server: String = kDefaultServerName) {
        if let configuration: ApiStoreConfiguration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.securityPolicy.allowInvalidCertificates = allow
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the authentication credentials for a given server configuration
    *
    * @param user The user to the credential.
    * @param password The password to the credential.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAuthenticationCredentials(user: String, password: String, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.credential = NSURLCredential(user: user, password: password, persistence: NSURLCredentialPersistence.ForSession)
            configuration.protectionSpace = NSURLProtectionSpace(host: configuration.host, port: 0, `protocol`: configuration.scheme, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the authentication credentials for a given server configuration
    *
    * @param user The user to the credential.
    * @param password The password to the credential.
    * @param method The authentication method for the session.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAuthenticationCredentials(user: String, password: String, authenticationMethod method: String, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.credential = NSURLCredential(user: user, password: password, persistence: NSURLCredentialPersistence.ForSession)
            configuration.protectionSpace = NSURLProtectionSpace(host: configuration.host, port: 0, `protocol`: configuration.scheme, realm: nil, authenticationMethod: method)
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setCachePolicy(policy: NSURLRequestCachePolicy, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.sessionConfiguration.requestCachePolicy = policy
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setCacheStoragePolicy(policy: NSURLCacheStoragePolicy, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.cacheStoragePolicy = policy
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function store the endpoint for a given server name in the local dictionary
    *
    * @param endpoint The given endpoint to store
    * @param server The name of the server to store the endpoint.
    *
    */
    
    func setEndpoint(endpoint: ApiEndpoint, forServer server: String = kDefaultServerName) {
        var endPoints: [String: ApiEndpoint] = Dictionary()
        if let serverEndpoints: [String: ApiEndpoint] = self.endPoints[server] {
            endPoints = serverEndpoints
            endPoints[endpoint.key()] = endpoint
        } else {
            endPoints[endpoint.key()] = endpoint
        }
        self.endPoints[server] = endPoints
    }
    
    
    /**
    * The function store the endpoint for a given server name in the local dictionary
    *
    * @param endpoints The array with the endpoints for the server.
    * @param server The name of the server to store the endpoint.
    *
    */
    
    func setEndpoints(var endpoints: Array<ApiEndpoint>, forServer server: String = kDefaultServerName) {
        for endpoint in endpoints {
            self.setEndpoint(endpoint, forServer: server)
        }
    }

    /**
    * The function set a headers for the default server configuration
    *
    * @param header The value for the header.
    * @param key The value for the header field.
    * @param name The name of the server to store the configuration.
    *
    */
    
    func setHeader(header: String, forKey key: String, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.headers[key] = header
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the headers for the given server name
    *
    * @param headers The dictionary with the headers.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setHeaders(headers: Dictionary<String, String>, forServer server: String = kDefaultServerName) {
        if let configuration: ApiStoreConfiguration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.headers += headers
            self.setConfiguration(configuration, forServer: server)
        }
    }

    /**
    * The function set the model path for the given server name
    *
    * @param path The path of the models in the api response.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setModelsPath(path: String, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.modelsPath = path
            self.setConfiguration(configuration, forServer: server)
        }
    }

    /**
    * The function set the pinned certificates for the api configuration
    *
    * @param certificates The array with the trusted certificates.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setPinnedCertificates(certificates: [NSData], forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.securityPolicy.certificates = certificates
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the request to redirect the http request
    *
    * @param redirection The request to redirect.
    * @param server The Identifier of the configuration.
    *
    */
    
    func setRequestRedirection(redirection: NSURLRequest, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.redirection = redirection
            self.setConfiguration(configuration, forServer: server)
        }
    }

    /**
    * The function set the response disposition to the API Store
    *
    * @param disposition The disposition for the request.
    * @param server The Identifier of the configuration.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.responseDisposition = disposition
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the response type for the server configuration
    *
    * @param type The type of the response.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setResponseType(type: ResponseType, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.responseType = type
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the security policy for the auth chanllenge for the given server
    *
    * @param policy The type of the policy.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setSecurityPolicy(policy: Policy, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.securityPolicy.policy = policy
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    /**
    * The function set the session configuration for the given server
    *
    * @param sessionConfiguration The session Configuration.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration, forServer server: String = kDefaultServerName) {
        if let configuration = self.configuration(forServer: server) as? ApiStoreConfiguration {
            configuration.sessionConfiguration = sessionConfiguration
            self.setConfiguration(configuration, forServer: server)
        }
    }
    
    // MARK: Singleton method
    
    class func defaultStore() -> ApiStore {
        dispatch_once(&Static.token, {
            Static.instace = ApiStore(config: ApiStoreConfiguration())
        })
        return Static.instace!
    }
    
}
