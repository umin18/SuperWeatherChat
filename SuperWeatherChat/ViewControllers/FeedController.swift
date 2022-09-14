//
//  FeedController.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/26/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit
import TWMessageBarManager
import SVProgressHUD
import ViewAnimator

class FeedController: BaseViewController, PostCollecDelegate {

    @IBOutlet weak var feedCollecView: UICollectionView!
    
    var data = [[String:Any]]()
    var refresher : UIRefreshControl!
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        
        feedCollecView.delegate = self
        feedCollecView.dataSource = self
        feedCollecView.addSubview(refresher)
        getPostsStart()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getPosts), userInfo: nil, repeats: true)
        animateCollection()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateCollection()
    }
    
    func animateCollection() {
        feedCollecView?.reloadData()
        let fromAnimation = AnimationType.from(direction: .bottom, offset: 200.0)
        let zoomAnimation = AnimationType.zoom(scale: 1)
        
        feedCollecView?.performBatchUpdates({
            UIView.animate(views: feedCollecView.visibleCells,
            animations: [zoomAnimation, fromAnimation],
            duration: 1)
        }, completion: nil)
    }
    
    func removePost(index : Int) {
        data.remove(at: index)
        feedCollecView.reloadData()
    }
    
    @objc func getPostsStart() {
        SVProgressHUD.show()
        getPosts()
        SVProgressHUD.dismiss()
    }
 
    @objc func getPosts() {
        FireBaseServices.shared.getPosts { (posts) in
            if posts != nil {
                let sortedPosts = (posts as! NSArray).sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]) as! [[String:AnyObject]]
                self.data = sortedPosts
                self.feedCollecView.reloadData()
                self.refresher.endRefreshing()
            } else {
                self.refresher.endRefreshing()
                self.data.removeAll()
                self.feedCollecView.reloadData()
            }
        }
    }

  
}

extension FeedController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostCollecCell
        let user = data[indexPath.row]["user"] as! UserModel?
        let postImg = data[indexPath.row]["postImg"] as! UIImage?
        let comment = data[indexPath.row]["comment"] as! String
        var userImg : UIImage?
        var userName : String?
        var userId : String?
        let postId = data[indexPath.row]["postID"] as! String
        if user != nil {
            if user!.image != nil {
                userImg = user!.image!
            }
            userName = "\(user!.fname) \(user!.lname)"
            userId = user!.userID
            cell.updateCell(postID: postId, index: indexPath.row,userImg: userImg ?? UIImage(imageLiteralResourceName:"logo"), postImg: postImg ?? UIImage(), userName: userName!, id: userId!, comment: comment)
        }
        
        return cell
    }
    
    
}
