//
//  AthleteNewsViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/30/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import SideMenu
import FeedKit



class AthleteNewsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var articles = [Article]()
    var feed: RSSFeed?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var isDismissed:Bool = false
    
    var refreshControl: UIRefreshControl!
    
    let feedStrings = [
//        "http://www.womentalksports.com/feed/",
//        "http://www.excellesports.com/feed",
//        "http://athenasportsnet.com/feed/",
        "http://www.fifa.com/womensolympic/news/rss.xml",
        "http://www.womenshealthandfitness.com.au/component/obrss/fitness",
        "http://www.sportsister.com/feed/",
//        "http://www.ncaa.com/news/basketball-women/d1/rss.xml",        
        "http://www.xysports.com/main/rss/feed?status=1"
    ]
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuFadeStatusBar = false

        // Show activity indicator while fetching articles
        self.tableView.tableFooterView = UIView()
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            self.showArticles()
        }
        
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        // Move to a background thread to do some long running work
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.showArticles()
//        }
        refreshControl.endRefreshing()
    }
    
    func showArticles(){
        
        if Reachability.isConnectedToNetwork(){
            
            for feedString in self.feedStrings{
                // Return if the view controller is dismissed
                if self.isDismissed == true {
                    return
                }
                
                let feedURL = URL(string: feedString)!
                guard let temp =  FeedParser(URL: feedURL) else{
                    print(">>>Failed to parse feed: \(feedURL)")
                    continue
                }
                let result = temp.parse()
                
                guard let items = result.rssFeed?.items else {return}
                
                for item in items {
                    let title = item.title ?? "[no title]"
                    var text:String = ""
                    do {
                        let attrStr = try NSAttributedString(
                            data: (item.description?.data(using: String.Encoding.unicode, allowLossyConversion: true)!)!,
                            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                            documentAttributes: nil)
                        text = attrStr.string
                    } catch _ {
                        
                    }
                    let link = item.link
                    let insertIndex = self.articles.count//0
                    DispatchQueue.main.async {
                        if self.activityIndicator.isHidden == false{
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                        self.articles.insert(Article(title: title, link: link!, text: text), at: insertIndex)
                        self.tableView.insertRows(at: [IndexPath(row: insertIndex, section: 0)], with: .right)
                    }
                }
                
            }
            refreshControl.endRefreshing()
            
        }else{
            DispatchQueue.main.async {
                if self.activityIndicator.isHidden == false{
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
            showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                
            }, cancelAction: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isDismissed = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to AthleteArticleVC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AthleteArticleViewController") as! AthleteArticleViewController
        vc.link = self.articles[indexPath.row].link
        self.present(vc, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        cell.lblTitle.text = self.articles[indexPath.row].title
        cell.lblDescription.text = self.articles[indexPath.row].text
        
        return cell
    }

}

extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
}
