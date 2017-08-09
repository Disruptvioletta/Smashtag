//
//  TweetsEntity.swift
//  Smashtag
//
//  Created by Illarionova Violetta on 26/03/2017.
//  Copyright © 2017 Disruptvioletta LLC. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TweetsEntity: NSManagedObject {
    
    static func findOrCreateTweet(matching twitterInfo: Twitter.Tweet, in context: NSManagedObjectContext) throws -> TweetsEntity {
        let request: NSFetchRequest<TweetsEntity> = TweetsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.identifier)
        
        do {
        let matchesInTheDataBase = try context.fetch(request)
            if matchesInTheDataBase.count > 0 {
                assert(matchesInTheDataBase.count == 1, "Tweets entity. FOCT DB inconsistency")
                return matchesInTheDataBase[0]
            }
        } catch {
            throw error
        }
        
        let oneTweetDB = TweetsEntity(context: context)
        oneTweetDB.unique =  twitterInfo.identifier
        oneTweetDB.created = twitterInfo.created as NSDate
        oneTweetDB.text = twitterInfo.text
        oneTweetDB.personWhoHadTweeted = try? TwitterUsersEntity.findOrCreateTwitterUser(matching: twitterInfo.user, in: context)
        return  oneTweetDB
    }
}
