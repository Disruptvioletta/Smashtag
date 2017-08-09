//
//  TwitterUsersEntity.swift
//  Smashtag
//
//  Created by Illarionova Violetta on 26/03/2017.
//  Copyright © 2017 Disruptvioletta LLC. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TwitterUsersEntity: NSManagedObject {
    
    static func findOrCreateTwitterUser(matching twitterInfo: Twitter.User, in context: NSManagedObjectContext) throws -> TwitterUsersEntity {
        let request: NSFetchRequest<TwitterUsersEntity> = TwitterUsersEntity.fetchRequest()
        request.predicate = NSPredicate(format: "handle = %@", twitterInfo.screenName)
        
        do {
            let matchesInTheDataBase = try context.fetch(request)
            if matchesInTheDataBase.count > 0 {
                assert(matchesInTheDataBase.count == 1, " FOCTU TUEntity -- DB inconsistency")
                return matchesInTheDataBase[0]
            }
        } catch {
            throw error
        }
        
        let oneUserDB = TwitterUsersEntity(context: context)
        oneUserDB.handle = twitterInfo.screenName
        oneUserDB.name = twitterInfo.name
        
        return oneUserDB
    }
    
}
