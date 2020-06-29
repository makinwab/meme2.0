//
//  MemeDetailViewController.swift
//  MemeImagePicker
//
//  Created by Olubukola Makinwa on 27.06.20.
//  Copyright © 2020 Makinwa. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    var meme: Meme!

    @IBOutlet weak var memeImage: UIImageView!
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memeImage!.image = self.meme.memedImage
        self.tabBarController?.tabBar.isHidden = true
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

