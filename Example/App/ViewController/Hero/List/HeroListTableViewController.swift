//
// HeroListTableViewController.swift
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

class HeroListTableViewController: UITableViewController, ApiQueryDelegate {
        
    @IBOutlet var datasource: HeroDatasource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.readHeros()
 }

//MARK: ApiQuery delegate
    
    func cachedResponseForUrl(url: NSURL, cachedData data: AnyObject) {
        println("Cached data ---> ", data)
    }
    
//MARK: Private methods
    
    private func readHeros() {
        let apiQuery: ApiQuery = ApiStore.defaultStore().createQueryForPath("/v1/public/characters", httpMethod: HttpMethod.get, server: kMarvelServer)
        apiQuery.delegate = self
        apiQuery.execute(completionHandler: {(object, error) in
            if let response: NSDictionary = object as? NSDictionary {
                if let heros: [Hero] = response.valueForKeyPath("models") as? [Hero] {
                    self.datasource.tableData = heros
                    self.tableView.reloadData()
                }
            }
        })
    }
    
}
