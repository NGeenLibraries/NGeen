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
    }
    
    /**
    * The function create and return the last query setted on the default server
    *
    * no need params.
    *
    * return ApiQuery
    */
    
    func createQuery() -> ApiQuery {
        return self.createQueryForSever(kDefaultServerName)
    }
    
    /**
    * The function create and return the query for the given key
    *
    * @param key The id for the query
    *
    * return ApiQuery
    */
    
    func createQueryForSever(server: String) -> ApiQuery {
        if let endPoints: [String: ApiEndpoint] = self.endPoints[server] {
            return ApiQuery(configuration: self.configurationForKey(server), endPoint: endPoints.values.last!)
        } else {
            assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
        }
    }
    
    /**
    * The function create and return a query for the default server configuration
    * and the given endopint path
    *
    * @param path The path of the endpoint.
    * @param method The http method type for the request.
    *
    * return ApiQuery
    */
    
    func createQueryForPath(path: String, httpMethod method: HttpMethod) -> ApiQuery {
        return self.createQueryForPath(path, httpMethod: method, server: kDefaultServerName)
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
    
    func createQueryForPath(path: String, httpMethod method: HttpMethod, server name: String) -> ApiQuery {
         if let endPoints = self.endPoints[name] {
            if let endPoint = endPoints[ApiEndpoint.keyForPath(path, httpMethod: method)] {
                return ApiQuery(configuration: self.configurationForKey(name), endPoint: endPoint)
            } else {
                assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
            }
        } else {
            assert(false, "The endpoint can't be null", file: __FILE__, line: __LINE__)
        }
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
    
    // MARK: Instance methods
    
    /**
    * The function return the endpoint for a given model class
    *
    * @param path The path key to search the endpoint
    * @param method The method for the endpoint
    *
    * return Endpoint
    */
    
    func endpointForPath(path: String, httpMethod method: HttpMethod) -> ApiEndpoint? {
         return self.endpointForPath(path, httpMethod: method, serverName: kDefaultServerName)
    }
    
    /**
    * The function return the endpoint for a given model class and server name
    *
    * @param path The path key to search the endpoint
    * @param method The method for the endpoint
    * @param name The name of the server for the endpoint
    *
    * return Endpoint
    */
    
    func endpointForPath(path: String, httpMethod method: HttpMethod, serverName name: String) -> ApiEndpoint? {
        return self.endPoints[name]?[ApiEndpoint.keyForPath(path, httpMethod: method)]
    }
   
    /**
    * The function get the authentication credentials the default server configuration
    *
    * no need params.
    *
    * return String
    */
    
    func getAuthenticationCredentials() -> String {
        return self.getAuthenticationCredentialsForServer(kDefaultServerName)
    }
    
    /**
    * The function get the authentication credentials for a given server configuration
    *
    * @param server The name of the server to store the configuration.
    *
    * return String
    */
    
    func getAuthenticationCredentialsForServer(server: String) -> String {
        var credentials: String?
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
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
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.sessionConfiguration.requestCachePolicy
    }
    
    /**
    * The function return the cache storage policy for the default server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLCacheStoragePolicy
    */
    
    func getCacheStoragePolicy() -> NSURLCacheStoragePolicy? {
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
    
    func getCacheStoragePolicyForServer(server: String) -> NSURLCacheStoragePolicy? {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.cacheStoragePolicy
    }
    
    /**
    * The function return the headers for the default server configuration
    *
    * no need params.
    *
    * @return Dictionary
    */
    
    func getHeaders() -> [String: String] {
        return self.getHeadersForServer(kDefaultServerName)
    }
    
    /**
    * The function return the headers for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return Dictionary
    */
    
    func getHeadersForServer(server: String) -> [String: String] {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.headers ?? Dictionary()
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
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.modelsPath ?? ""
    }
    
    /**
    * The function get the pinned certificates for the default api configuration
    *
    * no need params.
    *
    * return Array
    */
    
    func getPinnedCertificates() -> [AnyObject] {
        return self.getPinnedCertificatesForServer(kDefaultServerName)
    }
    
    /**
    * The function get the pinned certificates for the given server
    *
    * @param server The name of the server to store the configuration.
    *
    */
    
    func getPinnedCertificatesForServer(server: String) -> [AnyObject] {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.securityPolicy.certificates ?? Array()
    }
    
    /**
    * The function get the response disposition to the default configuration
    *
    * no need params.
    *
    * @return NSURLSessionResponseDisposition
    */
    
    func getResponseDisposition() -> NSURLSessionResponseDisposition? {
        return self.getResponseDispositionForServer(kDefaultServerName)
    }
    
    /**
    * The function get the response disposition to the default configuration
    *
    * @param server The Identifier of the configuration.
    *
    * @return NSURLSessionResponseDisposition
    */
    
    func getResponseDispositionForServer(server: String) -> NSURLSessionResponseDisposition? {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.responseDisposition
    }
    
    /**
    * The function return the response type for a server configuration
    *
    * @param no need params.
    *
    * @return ResponseType
    */
    
    func getResponseType() -> ResponseType? {
        return self.getResponseTypeForServer(kDefaultServerName)
    }
    
    /**
    * The function return the response type for a server configuration
    *
    * @param server The server to get the configuration.
    *
    * @return ResponseType
    */
    
    func getResponseTypeForServer(server: String) -> ResponseType? {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.responseType
    }
    
    /**
    * The function get the security policy for default server configuration
    *
    * no need params.
    *
    * return Policy
    */
    
    func getSecurityPolicy() -> Policy {
        return getSecurityPolicyForServer(kDefaultServerName)
    }
    
    /**
    * The function get the security policy for the given server
    *
    * @param server The name for the server to store the configuration.
    *
    * return Policy
    */
    
    func getSecurityPolicyForServer(server: String) -> Policy {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.securityPolicy.policy ?? Policy.none
    }
    
    /**
    * The function get the session configuration for the default server config
    *
    * @param sessionConfiguration The session Configuration.
    *
    * return NSURLSessionConfiguration
    */
    
    func getSessionConfiguration() -> NSURLSessionConfiguration? {
        return self.getSessionConfigurationForServer(kDefaultServerName)
    }
    
    /**
    * The function get the session configuration for the given server
    *
    * @param server The name for the server to get the configuration.
    *
    * return NSURLSessionConfiguration
    */
    
    func getSessionConfigurationForServer(server: String) -> NSURLSessionConfiguration? {
        let configuration = self.configurationForKey(server) as? ApiStoreConfiguration
        return configuration?.sessionConfiguration

    }
    
    /**
    * The function set the if the default server configuration accept invalid certificates
    *
    * @param allow The true or false.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAllowInvalidCertificates(allow: Bool) {
        self.setAllowInvalidCertificates(allow, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the if the given server configuration accept invalid certificates
    *
    * @param allow The true or false.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAllowInvalidCertificates(allow: Bool, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.securityPolicy.allowInvalidCertificates = allow
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the authentication credentials for the default server configuration
    *
    * @param user The user to the credential.
    * @param password The password to the credential.
    *
    */
    
    func setAuthenticationCredentials(user: String, password: String) {
        self.setAuthenticationCredentials(user, password: password, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the authentication credentials for the default server configuration
    *
    * @param user The user to the credential.
    * @param password The password to the credential.
    * @param method The authentication method for the session.
    *
    */
    
    func setAuthenticationCredentials(user: String, password: String, authenticationMethod method: String) {
        self.setAuthenticationCredentials(user, password: password, authenticationMethod: method, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the authentication credentials for a given server configuration
    *
    * @param user The user to the credential.
    * @param password The password to the credential.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setAuthenticationCredentials(user: String, password: String, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.credential = NSURLCredential(user: user, password: password, persistence: NSURLCredentialPersistence.ForSession)
            configuration.protectionSpace = NSURLProtectionSpace(host: configuration.host, port: 0, `protocol`: configuration.scheme, realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
            self.setConfiguration(configuration, forKey: server)
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
    
    func setAuthenticationCredentials(user: String, password: String, authenticationMethod method: String, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.credential = NSURLCredential(user: user, password: password, persistence: NSURLCredentialPersistence.ForSession)
            configuration.protectionSpace = NSURLProtectionSpace(host: configuration.host, port: 0, `protocol`: configuration.scheme, realm: nil, authenticationMethod: method)
            self.setConfiguration(configuration, forKey: server)
        }
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
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.sessionConfiguration.requestCachePolicy = policy
            self.setConfiguration(configuration, forKey: server)
        }
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
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.cacheStoragePolicy = policy
            self.setConfiguration(configuration, forKey: server)
        }
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
    * The function store the endpoints in the local dictionary
    *
    * @param endpoints The array with the endpoints for the server.
    *
    */
    
    func setEndpoints(var endpoints: Array<ApiEndpoint>) {
        self.setEndpoints(endpoints, forServer: kDefaultServerName)
    }
    
    /**
    * The function store the endpoint for a given server name in the local dictionary
    *
    * @param endpoints The array with the endpoints for the server.
    * @param server The name of the server to store the endpoint.
    *
    */
    
    func setEndpoints(var endpoints: Array<ApiEndpoint>, forServer server: String) {
        for endpoint in endpoints {
            self.setEndpoint(endpoint, forServer: server)
        }
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
        if let configuration: ApiStoreConfiguration = self.configurationForKey(name) as? ApiStoreConfiguration {
            configuration.headers[key] = header
            self.setConfiguration(configuration, forKey: name)
        }
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
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.headers += headers
            self.setConfiguration(configuration, forKey: server)
        }
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
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setModelsPath(path: String, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.modelsPath = path
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the pinned certificates for the api configuration
    *
    * @param certificates The array with the trusted certificates.
    *
    */
    
    func setPinnedCertificates(certificates: [NSData]) {
        self.setPinnedCertificates(certificates, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the pinned certificates for the api configuration
    *
    * @param certificates The array with the trusted certificates.
    * @param server The name of the server to store the configuration.
    *
    */
    
    func setPinnedCertificates(certificates: [NSData], forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.securityPolicy.certificates = certificates
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the request to redirect the http request
    *
    * @param redirection The request to redirect.
    *
    */
    
    func setRequestRedirection(redirection: NSURLRequest) {
        self.setRequestRedirection(redirection, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the request to redirect the http request
    *
    * @param redirection The request to redirect.
    * @param server The Identifier of the configuration.
    *
    */
    
    func setRequestRedirection(redirection: NSURLRequest, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.redirection = redirection
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the response disposition to the API Store
    *
    * @param disposition The disposition for the request.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition) {
        self.setResponseDisposition(disposition, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the response disposition to the API Store
    *
    * @param disposition The disposition for the request.
    * @param server The Identifier of the configuration.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.responseDisposition = disposition
            self.setConfiguration(configuration, forKey: server)
        }
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
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setResponseType(type: ResponseType, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.responseType = type
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the security policy for the auth chanllenge for the default 
    * server configuration
    *
    * @param policy The type of the policy.
    *
    */
    
    func setSecurityPolicy(policy: Policy) {
        self.setSecurityPolicy(policy, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the security policy for the auth chanllenge for the given server
    *
    * @param policy The type of the policy.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setSecurityPolicy(policy: Policy, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.securityPolicy.policy = policy
            self.setConfiguration(configuration, forKey: server)
        }
    }
    
    /**
    * The function set the session configuration for the default server config
    *
    * @param sessionConfiguration The session Configuration.
    *
    */
    
    func setSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration) {
        self.setSessionConfiguration(sessionConfiguration, forServer: kDefaultServerName)
    }
    
    /**
    * The function set the session configuration for the given server
    *
    * @param sessionConfiguration The session Configuration.
    * @param server The name for the server to store the configuration.
    *
    */
    
    func setSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration, forServer server: String) {
        if let configuration: ApiStoreConfiguration = self.configurationForKey(server) as? ApiStoreConfiguration {
            configuration.sessionConfiguration = sessionConfiguration
            self.setConfiguration(configuration, forKey: server)
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
