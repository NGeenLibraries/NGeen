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
        let headers: Dictionary<String, String> = ["X-Parse-Application-Id": "BgJnryEVJitvxnMKKMjJyMm6vrBwIgDFAARtVqXn", "X-Parse-REST-API-Key": "euJT7bCipxE82sx5j6L8sHTFXm0HxNUiiBvR03ug"]
        let apiStoreConfiguration = ApiStoreConfiguration(headers: headers, host: "httpbin.org", scheme: "http")
        //let taskEndpoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.get, path: "/1/classes/Task")
        let downloadEnpoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.patch, path: "/patch")
        ApiStore.defaultStore().setConfiguration(apiStoreConfiguration)
        ApiStore.defaultStore().setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
        ApiStore.defaultStore().setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        ApiStore.defaultStore().setEndpoint(downloadEnpoint)
        ApiStore.defaultStore().setModelsPath("results")
        ApiStore.defaultStore().setResponseType(ResponseType.dictionary)
        let parameters = ["foo": "bar", "baz1": "1", "baz2": "2", "baz3": "3"]
        //ApiStore.defaultStore().setBodyItem("jorge", forKey: "name")
        //ApiStore.defaultStore().setBodyItem("jorge", forKey: "type")
        let apiQuery = ApiStore.defaultStore().createQueryForPath("/patch", httpMethod: HttpMethod.patch)
        ApiStore.defaultStore().setAuthenticationCredentials("foo", password: "bar")
        apiQuery.patch(parameters, completionHandler: {(object, error) in
            println(object)
        })
        
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

