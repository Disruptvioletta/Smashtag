//
//  PeopleWhoTweetedTableViewController.swift
//  Smashtag
//
//  Created by Illarionova Violetta on 27/03/2017.
//  Copyright © 2017 Disruptvioletta LLC. All rights reserved.
//

import UIKit
import CoreData

class PeopleWhoTweetedTableViewController: FetchedResultsTableViewController {

    var mention: String? {
        didSet {
            updateUI()
        }
    }
    
    var containerForPeople: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    fileprivate  var fetchedResultsController: NSFetchedResultsController<TwitterUsersEntity>?
    
    private func updateUI() {
        if let context = containerForPeople?.viewContext, mention != nil  {
            let request: NSFetchRequest<TwitterUsersEntity> = TwitterUsersEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = NSPredicate(format: "ANY quantityOfTweets.text contains[c] %@ ", mention!)
            fetchedResultsController = NSFetchedResultsController<TwitterUsersEntity>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
            }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUserCell", for: indexPath)
        
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = twitterUser.handle
            let tweetCount = tweetCountWithMentionBy(twitterUser)
            cell.detailTextLabel?.text = "\(tweetCount) tweet\((tweetCount == 1) ? "" : "s")"
        }
        return cell
    }
    
    private func tweetCountWithMentionBy(_ twitterUser: TwitterUsersEntity) -> Int {
        let request: NSFetchRequest<TweetsEntity> = TweetsEntity.fetchRequest()
        request.predicate = NSPredicate(format: "text contains[c] %@ and personWhoHadTweeted = %@", mention!, twitterUser)
        return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0
    }
    
    

} 

extension PeopleWhoTweetedTableViewController {
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
}
