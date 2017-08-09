//
//  ViewController.swift
//  Smashtag
//
//  Created by Illarionova Violetta on 22/03/2017.
//  Copyright © 2017 Disruptvioletta LLC. All rights reserved.
//

import UIKit
import Twitter

class TweetTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(refreshControl)
        
    }
    
    //MARK: Refresh control
    
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TweetTVC.refreshTableView),for: .valueChanged)
        return refreshControl
    }()
    
    func refreshTableView(_ refreshControlLet: UIRefreshControl) {
        searchForTweets()
    }
    
  
    //MARK: TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
             searchText = searchTextField.text
        }
        return true
    }
    
    
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            print(tweets)
        }
    }
    
    var  searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query  = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at:0)
        self.tableView.insertSections([0], with: .fade)
         // In order to make it  more subclassable
        
    }
    
    //MARK: Search for tweets
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets{ [weak self] newTweets  in
                DispatchQueue.main.async {
                    //main queue
                    if request == self?.lastTwitterRequest {
                        self?.insertTweets(newTweets) // In order to making it  more subclassable
                        
                    }
                    self?.refreshControl.endRefreshing()
                }
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "kek"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

}

