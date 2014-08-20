//
//  AppDelegate.swift
//  NGeenTemplate
//
//  Created by Jorge Orjuela on 6/16/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        /*var headers: Dictionary<String, String> = ["X-Parse-Application-Id": "BgJnryEVJitvxnMKKMjJyMm6vrBwIgDFAARtVqXn", "X-Parse-REST-API-Key": "euJT7bCipxE82sx5j6L8sHTFXm0HxNUiiBvR03ug"]
        var apiStoreConfiguration: ApiStoreConfiguration = ApiStoreConfiguration(headers: headers, host: "api.parse.com", scheme: "https")
        ApiStore.defaultStore().setConfiguration(apiStoreConfiguration)
        let endPoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.multiPartForm, httpMethod: HttpMethod.post, path: "/1/classes/Task")
        ApiStore.defaultStore().setEndpoint(endPoint)
        ApiStore.defaultStore().setResponseType(ResponseType.string)
        let parameters = ["foo": "bar", "baz1": "1", "baz2": "2", "baz3": "3"]
        let apiQuery = ApiStore.defaultStore().createQueryForPath("/1/classes/Task", httpMethod: HttpMethod.post)
        apiQuery.execute(completionHandler: {(object, error) in
            println(object)
        })
        
        let docsDir: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let destination: NSURL = NSURL(fileURLWithPath: "\(docsDir)/download.zip")
        let dataTask: NSURLSessionDownloadTask = apiQuery.download(destination, progress: {(bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            println("progress")
        }, completionHandler: {(data, response, error) in
            println("DONE")
        })*/
    
        println(∑[1, 2, 3, 4, 5])
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

