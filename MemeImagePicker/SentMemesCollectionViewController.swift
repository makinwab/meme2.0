//
//  SentMemesCollectionViewController.swift
//  MemeImagePicker
//
//  Created by Olubukola Makinwa on 27.06.20.
//  Copyright © 2020 Makinwa. All rights reserved.
//
import Foundation
import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
   @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
   var memes: [Meme]! {
       let object = UIApplication.shared.delegate
       let appDelegate = object as! AppDelegate
       return appDelegate.memes
   }

  override func viewDidLoad() {
     super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self

     let space:CGFloat = 1.0
     let width = (view.frame.size.width - (2 * space)) / 3.0

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = CGSize(width: width, height: width)
  }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.tabBarController?.tabBar.isHidden = false
      collectionView!.reloadData()
  }
  
  // MARK: Collection View Data Source
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.memes.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentMemesCollectionViewCell", for: indexPath) as! SentMemesCollectionViewCell
      let meme = self.memes[(indexPath as NSIndexPath).row]
      cell.memeImage?.image = meme.memedImage

      return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
      let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
      detailController.meme = self.memes[(indexPath as NSIndexPath).row]
      self.navigationController!.pushViewController(detailController, animated: true)
  }
}
