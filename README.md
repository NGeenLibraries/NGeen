NGeen
=====

NGeen is a delightful library for swift. It's built based on factory design pattern, extending the powerful high-level networking and database abstractions built into Cocoa.

Choose NGeen for your next project, or migrate over your existing projects—you'll be happy you did!

## How To Get Started

- [Download NGeen](https://github.com/NGeenLibraries/NGeen/archive/master.zip) and try out.

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Features

- Capacity to use the same code to read api and database
- Configure only one time your app 
- Caching regardless if the server return the cache content
- Capacity to define multiples servers
- URL / JSON Parameter Encoding
- Authentication with NSURLCredential

## Architecture

#### Base
- Constants
	- Constants
- DataTypes
	- DataTypes
- Protocols
	- Protocols	

#### Cache
- DiskCache
	- DiskCache
- Entity
	- Entity
- Cache

#### Model

- Model

#### Network
- Request	
	- Request

#### Query
- Api	
	- ApiQuery
- DataBase	
	- DataBaseQuery

#### Store
- Api	
	- Config
		- ApiStoreConfiguration	
	- Endpoint
		- ApiEndpoint
	- ApiStore
- DataBase	
	- DataBaseStore
	

## Usage

### Configuration

Configure only one time your app and thats it :) .

#### Basic configuration

```swift 
let apiStoreConfiguration = ApiStoreConfiguration(headers: headers, host: "example.com", httpProtocol: "https")
ApiStore.defaultStore().setConfiguration(apiStoreConfiguration)
```

#### Setting basic authentication

```swift
 ApiStore.defaultStore().setAuthenticationCredentials("foo", password: "bar")
```

Supported Authentication Schemes

- HTTP Basic

#### Setting cache policy

The library provides cache for requests based on sqlite and files, regardless if the server returns the cache content in the headers, to allow this capacity you have to implement the ApiQueryDelegate and add the following code to the configuration.

```swift 
ApiStore.defaultStore().setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
ApiStore.defaultStore().setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
```

#### Setting the endpoints

```swift 
let taskEndpoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: "/1/classes/Task")
let exampleEndpoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: "/1/classes/Example")
```

#### Setting models serialization from server response

```swift 
ApiStore.defaultStore().setModelsPath("results")
ApiStore.defaultStore().setResponseType(ResponseType.models)
```

#### Setting response type

```swift 
ApiStore.defaultStore().setResponseType(ResponseType.dictionary)
```

Supported responses:

```swift
enum ResponseType: Int {
    case data
    case dictionary
    case models
    case string
}
```

### GET Request

```swift 
let apiQuery = ApiStore.defaultStore().createQueryForPath("/1/classes/Task", httpMethod: HttpMethod.get)
apiQuery.read(completionHandler: {(object, error) in
 })
```
#### With Parameters

```swift 
apiQuery.read(["foo": "bar"], completionHandler: {(object, error) in
})
```

### HTTP Methods

```swift
enum HttpMethod: String {
    case delete = "DELETE"
    case head = "HEAD"
    case get = "GET"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}
```

### POST Request

```swift
let parameters = ["foo": "bar", "baz1": "1", "baz2": "2", "baz3": "3"]  
apiQuery.setBodyItems(parameters)
apiQuery.create(completionHandler: {(object, error) in
 })
```
#### With Parameters

```swift
let parameters = ["foo": "bar", "baz1": "1", "baz2": "2", "baz3": "3"]
apiQuery.create(parameters, completionHandler: {(object, error) in
 })
```
Depends of the configuration setted in the api store config the body should be enconding in the supported formats:

- JSON
- URI form encoded
- MultiPart form


### Downloading 

Supported Upload Types

- Resume Data

#### Downloading a File

```swift
apiQuery.download(destination, progress: {(bytesRead, totalBytesRead, totalBytesExpectedToRead) in
    println(bytesRead)
 }, completionHandler: {(error) in
    println("DONE!!")
})
```

### Uploading 

Supported Upload Types

- File
- Data
- Stream

#### Uploading a File 


```swift
let data = "Lorem ipsum dolor sit amet".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
apiQuery.upload(data, progress: {(bytesWriten, totalBytesWriten, totalBytesExpectedToWrite) in
    println(bytesRead)
 }, completionHandler: {(error) in
	println("DONE")
})
```
### Parameter Encoding

```swift
enum ContentType: String {
    case json = "application/json"
    case multiPartForm = "multipart/form-data"
    case urlEnconded = "application/x-www-form-urlencoded"
}
```

## License

NGeen is available under the MIT license. See the LICENSE file for more info.