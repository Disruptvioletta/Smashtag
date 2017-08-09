//
//  SmashTVC.swift
//  Smashtag
//
//  Created by Illarionova Violetta on 26/03/2017.
//  Copyright © 2017 Disruptvioletta LLC. All rights reserved.
//

import UIKit
import Twitter // never forget to  import third-party module
import CoreData

class SmashTVC: TweetTVC {
    
    //MODEL
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer  // having said that
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDataBase(with: newTweets)
    }
    
    private func updateDataBase(with tweets: [Twitter.Tweet]) {
        print("Started loading the DB")
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ =  try? TweetsEntity.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            print("Done loading the DB")
            self?.printDBStatistics()
        }
    }
    
    private func printDBStatistics() {
        if let context =  container?.viewContext {
            
            // ViewContext is the main queue context
            context.perform {
            
                if Thread.isMainThread {
                    print("on the main thread")
                } else {
                    print("off the main thread")
                }
                let request: NSFetchRequest<TweetsEntity> = TweetsEntity.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print("\(tweetCount) quantity of tweets")
                }
                if let twitterUserCount = try? context.count(for: TwitterUsersEntity.fetchRequest()) {
                    print("\(twitterUserCount) quantity of Users")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "People menthioned searchh term" {
            if let peopleWhoTweetedTVC = segue.destination as? PeopleWhoTweetedTableViewController {
                peopleWhoTweetedTVC.mention = searchText
                peopleWhoTweetedTVC.containerForPeople = container
            }
        }
    }

}
