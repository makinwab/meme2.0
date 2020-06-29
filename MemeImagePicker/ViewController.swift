//
//  ViewController.swift
//  MemeImagePicker
//
//  Created by Olubukola Makinwa on 14.05.20.
//  Copyright © 2020 Makinwa. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var imagePickerView: UIImageView!
  @IBOutlet weak var cameraButton: UIBarButtonItem!

  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!

  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var headerToolbar: UIToolbar!
  @IBOutlet weak var footerToolbar: UIToolbar!
  
  let memeTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.strokeColor: UIColor.black,
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.font: UIFont(name: "impact", size: 40)!,
    NSAttributedString.Key.strokeWidth:  -3.0
  ]
  
  var isInitialText = true
  var isBottomText = false

  override func viewDidLoad() {
    configureTextField(textField: topTextField, withText: "TOP")
    configureTextField(textField: bottomTextField, withText: "BOTTOM")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
    
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
    self.tabBarController?.tabBar.isHidden = true

    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    shareButton.isEnabled = false
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
    self.tabBarController?.tabBar.isHidden = false
  }
  
  @IBAction func pickAnImageFromAlbum(_ sender: Any) {
    presentImagePickerWith(sourceType: .photoLibrary)
  }

  @IBAction func pickAnImageFromCamera(_ sender: Any) {
    presentImagePickerWith(sourceType: .camera)
  }
  
  @IBAction func shareMeme(_ sender: Any) {
    let memedImage = generateMemedImage()
    let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = self.view
    present(activityViewController, animated: true, completion: nil)
    
    activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
      if completed {
        self.save(memedImage)
        let sentMemesController = self.storyboard!.instantiateViewController(withIdentifier: "SentMemesTableViewController") as! SentMemesTableViewController
        self.navigationController!.pushViewController(sentMemesController, animated: true)

        return
      }
  
      if let sharedError = error {
        print("error while sharing: \(sharedError.localizedDescription)")
      }
      
      return
    }
  }

  @IBAction func cancelMemeEditor(_ sender: Any) {
    self.viewWillAppear(true)
  }
  
  func configureTextField(textField: UITextField, withText text: String) {
    textField.delegate = self
    textField.textAlignment = .center
    textField.defaultTextAttributes = memeTextAttributes
    textField.text = text
  }
  
  func presentImagePickerWith(sourceType: UIImagePickerController.SourceType) {
    let imagePicker = createImagePicker()
    imagePicker.sourceType = sourceType
  
    present(imagePicker, animated: true, completion: nil)
  }
  
  func save(_ memedImage: UIImage) {
   let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    // Add it to the memes array in the Application Delegate
    let object = UIApplication.shared.delegate
    let appDelegate = object as! AppDelegate
    appDelegate.memes.append(meme)
  }

  func generateMemedImage() -> UIImage {
    hideToolbars(true)

    //Render view to an image
    UIGraphicsBeginImageContext(self.view.frame.size)
    view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)

    let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
  
    hideToolbars(false)

    return memedImage
  }
  
  func hideToolbars(_ hide: Bool) {
    headerToolbar.isHidden = hide
    footerToolbar.isHidden = hide
  }

  func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  func unsubscribeFromKeyboardNotifications(){
    NotificationCenter.default.removeObserver(self)
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    if isBottomText {
      view.frame.origin.y -= getKeyboardHeight(notification)
    }
  }

  @objc func keyboardWillHide() {
    view.frame.origin.y = 0
  }

  func getKeyboardHeight(_ notification: Notification) -> CGFloat{
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
  
    return keyboardSize.cgRectValue.height
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    print("started typing")
    if textField.tag == 1 {
      isBottomText = true
    }

    textField.text = ""
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    isInitialText = false
    isBottomText = false
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func createImagePicker() -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self

    return imagePicker
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
      imagePickerView.contentMode = .scaleAspectFit
      imagePickerView.image = image
      shareButton.isEnabled = true
  
      dismiss(animated: true, completion: nil)
    }
  }
}
