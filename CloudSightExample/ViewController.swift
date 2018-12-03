//
//  ViewController.swift
//  CloudSightExample
//

import UIKit
import CloudSight

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CloudSightQueryDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var bin: UILabel!
    var cloudsightQuery: CloudSightQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CloudSightConnection.sharedInstance().consumerKey = "EUVIyy2Rp_OGH7pm8z9oxA";
        CloudSightConnection.sharedInstance().consumerSecret = "xqgUfGKc4SfKUW9CSeZeXw";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {

         //self.printMessagesForUser()
        // Check to see if the Camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()

            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false

            // Show the UIImagePickerController view
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Cannot access the camera");
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Dismiss the UIImagePickerController
        self.dismiss(animated: true, completion: nil)
        
        // Assign the image reference to the image view to display
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        
        // Create JPG image data from UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        cloudsightQuery = CloudSightQuery(image: imageData,
                                          atLocation: CGPoint.zero,
                                          withDelegate: self,
                                          atPlacemark: nil,
                                          withDeviceId: "device-id")
        cloudsightQuery.start()
        activityIndicatorView.startAnimating()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func cloudSightQueryDidFinishUploading(_ query: CloudSightQuery!) {
        print("cloudSightQueryDidFinishUploading")
    }
    
    func cloudSightQueryDidFinishIdentifying(_ query: CloudSightQuery!) {
        print("cloudSightQueryDidFinishIdentifying")
        
        func printMessagesForUser() -> Void {
            let json = ["apiresult":query.name()]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                let url = NSURL(string: "http://2a7523e8.ngrok.io")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(String(describing: error))")
                        return
                    }
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:String]
                        print("Result -> \(String(describing: result))")
                        
                        DispatchQueue.main.async {
                            
                            for (_, value) in result! {
                                self.bin.text = value
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                        
                    } catch {
                        print("Error -> \(error)")
                    }
                }
                
                task.resume()
            } catch {
                print(error)
            }
        }

        // CloudSight runs in a background thread, and since we're only
        // allowed to update UI in the main thread, let's make sure it does.
        DispatchQueue.main.async {
            self.resultLabel.text = query.name()
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func cloudSightQueryDidFail(_ query: CloudSightQuery!, withError error: Error!) {
        print("CloudSight Failure: \(error)")
    }
    
    
}
