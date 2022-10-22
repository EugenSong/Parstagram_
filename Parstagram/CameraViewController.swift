//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Eugene Song on 10/14/22.
//

import UIKit
import AlamofireImage
import Parse    // create objects into table

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageTakenView: UIImageView!
    
    @IBOutlet weak var commentsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitTextFieldPressed(_ sender: UIButton) {
        
        // ** HOW TO CREATE PARSE SCHEMA : IMPORTANT !!! ***
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentsTextField.text!
        post["author"] = PFUser.current()!
        
        
        
        
        // need image URL to insert into Parse... save the photo into a separate table to use later
        let imageData = imageTakenView.image!.pngData()
            // becomes binary object of the image.. carries url
        let file = PFFileObject(name:"image.png", data: imageData!)
        
        post["Image"] = file
        
        
            
        post.saveInBackground { (success, error) in
            if success {
                // self.dismiss is to return to previous view
                self.dismiss(animated: true, completion: nil)
                print("success")
        } else {
        print("Error!")
            
        }
        }
    }
    
    @IBAction func takePicturePressed(_ sender: Any) {
        // how to bring up camera.. the easy way..of 2 ways
        let picker = UIImagePickerController()
        picker.delegate = self  // when user is done taking photo, let me know what they took ( call me back on teh function that has the photo
        picker.allowsEditing = true // presents 2nd screen to user to allow them to tweak photo before submitting
        
        // need to include as a check to see if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            // for simulator
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    
    }
    
    // function needed to use image selected by user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // image comes at dictionary
        let image = info[.editedImage] as! UIImage
        
        // scale image using alamofireimage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageTakenView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
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
