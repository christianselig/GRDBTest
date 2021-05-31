//
//  ViewController.swift
//  GRDBTest
//
//  Created by Christian Selig on 2021-05-31.
//

import UIKit
import GRDB

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            // Insert first, then comment out and uncomment read
//            self.insert()
            self.read()
        }
    }
    
    private func insert() {
        let items = self.itemsFromJSON()

        let startTime = CFAbsoluteTimeGetCurrent()
        
        try! dbQueue.inTransaction(.deferred, { db in
            for item in items {
                var subreddit = Subreddit(id: item, subscribers: 3466293)
                try! subreddit.insert(db)
            }

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed: \(timeElapsed) s.")

            return .commit
        })
    }
    
    private func read() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        try! dbQueue.read({ db in
            let matches = try! Subreddit.askMatches().limit(7).fetchAll(db)
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed: \(timeElapsed) s.")

            print(matches.count)
        })
    }
    
    private func itemsFromJSON() -> [String] {
        let json = try! JSONSerialization.jsonObject(with: try! Data(contentsOf: Bundle.main.url(forResource: "input", withExtension: "json")!), options: []) as! [String]
        return json
    }
}

