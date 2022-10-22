//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Eugene Song on 10/14/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

// delcare UITableViewDelegate AND UITableViewDataSource when creating a TableView
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    // table view
    @IBOutlet weak var postTableView: UITableView!
    
    // instance of MessageInputBar
    let commentBar = MessageInputBar()
    
    var showCommentsBar = false
    
    var selectedPost: PFObject!
    
    // need to create an array to hold Posts just like array of movies or array of tweets
    var posts = [PFObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NEED TO INCLUDE BOTH when creating UITableView
        postTableView.delegate = self
        postTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        // dismiss keyboard by dragging
        postTableView.keyboardDismissMode = .interactive
        
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
    }
    
    // crazy block that tells.. "Hey I want to reserve an event and when that event happens, hide keyboard
    @objc func keyboardWillBeHidden (note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentsBar = false
        becomeFirstResponder()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // create query using Parse documentation under "Queries"
    
        let query = PFQuery(className: "Posts")
        // fetches pointer from "author" query in Parse
        query.includeKeys(["author", "comments", "comments.author"])
        
        query.limit = 20
        
        // PATTERN: GET THE QUERY --> STORE THE DATA --> RELOAD TABLE VIEW
        query.findObjectsInBackground { posts, error in
            // if I was able to find stuff in here
            if posts != nil {
                self.posts = posts!
                self.postTableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        
        selectedPost = post
        
        // i have a comment --> what the comment says , what post it belongs to --> who the comment belongs to
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showCommentsBar = true
            becomeFirstResponder()
            
            // Responder means "focus"
            commentBar.inputTextView.becomeFirstResponder()
    
        }
    
        

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        
        // nil coalescing operator... if nil do first else do the second
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // one for comments and one for add comment cell
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // use indexPath.row to grab particular post
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == 0 {
            // get cell as PostTableViewCell from Cocoacpods file we made / linked
            let cell = postTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
            // this is a PF user
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            
            // steps to take to insert image after fetching data... get the cell as an object
            // 1) use object. method to call url
            // 2) convert url from string --> URL
            // 3) insert image
            
            let imageFile = post["Image"] as! PFFileObject
            let urlString = imageFile.url!
            
            let url = URL(string: urlString)!
            
            cell.picture.af.setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            
            cell.nameLabel.text = user.username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        
        // clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showCommentsBar = false
        becomeFirstResponder()
        
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in if success {
            print("Comment saved")
        } else {
            print("Error trying to save comment")
        }
            
        }
        
        postTableView.reloadData()
        
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func pressedLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    
    // random functions to generate and "hack" the iOS framework to create message bars
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentsBar
    }
}



