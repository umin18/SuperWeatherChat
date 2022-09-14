//
//  PostCollecCell.swift
//  EarlyWarningSystem
//
//  Created by Eric Cha on 12/26/18.
//  Copyright © 2018 Eric Cha. All rights reserved.
//

import UIKit
import TWMessageBarManager

@objc protocol PostCollecDelegate {
    @objc func removePost(index : Int)
}

class PostCollecCell: UICollectionViewCell {
    
    var userID : String?
    var postId : String?
    var index : Int?
    var delegate : PostCollecDelegate?
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var commentTxt: UILabel!
    @IBOutlet weak var removePostButton: UIButton!
    
    
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        userImgView.layer.borderWidth = 5
        userImgView.layer.borderColor = #colorLiteral(red: 1, green: 0.6112429371, blue: 0.6917650963, alpha: 0.5)
        userImgView.layer.cornerRadius = userImgView.frame.size.width / 2
        userImgView.clipsToBounds = true
        postImgView.clipsToBounds = true
        
    }
    
    func hideRemoveButton() {
        let currentUserID = FireBaseServices.shared.getUserId()
        if userID != currentUserID {
            removePostButton.isHidden = true
        }
        if userID == currentUserID {
            removePostButton.isHidden = false
        }
    }
    
    func updateCell(postID : String, index : Int, userImg : UIImage, postImg : UIImage, userName : String, id : String, comment : String) {

        self.userImgView.image = userImg
        self.postId = postID
        self.postImgView.image = postImg
        self.userNameLbl.text = userName
        self.userID = id
        self.index = index
        self.commentTxt.text = comment
        hideRemoveButton()
    }
    
    @IBAction func removePost(_ sender: Any) {
        guard let id = userID
            else {
                TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Error retreiving user's ID", comment: ""), type: .error, duration: 5)
                return
        }
        guard let pid = postId
            else {
                TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Error retreiving post ID", comment: ""), type: .error, duration: 5)
                return
        }
        FireBaseServices.shared.removePost(postId : pid, id: id) { (error) in
            if error == nil {
                TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Success", comment: ""), description: NSLocalizedString("The post has been removed successfully", comment: ""), type: .success, duration: 5)
                guard let row = self.index else {return}
                self.delegate?.removePost(index : row)
            } else {
                TWMessageBarManager().showMessage(withTitle: NSLocalizedString("Error", comment: ""), description: NSLocalizedString("Post could not be removed from User's feed", comment: ""), type: .error, duration: 5)
            }
        }
    }
}
