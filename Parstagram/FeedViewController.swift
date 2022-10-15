//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Eugene Song on 10/14/22.
//

import UIKit
import Parse
import AlamofireImage

// delcare UITableViewDelegate AND UITableViewDataSource when creating a TableView
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // table view
    @IBOutlet weak var postTableView: UITableView!
    
    
    // need to create an array to hold Posts just like array of movies or array of tweets
    var posts = [PFObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NEED TO INCLUDE BOTH when creating UITableView
        postTableView.delegate = self
        postTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // create query using Parse documentation under "Queries"
    
        let query = PFQuery(className: "Posts")
        // fetches pointer from "author" query in Parse
        query.includeKey("author")
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell as PostTableViewCell from Cocoacpods file we made / linked
        let cell = postTableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        // use indexPath.row to grab particular post
        let post = posts[indexPath.row]
        
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
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
