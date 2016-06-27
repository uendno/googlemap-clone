//
//  PhotosViewController.swift
//  googlemap-clone
//
//  Created by Tran Viet Thang on 6/24/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import UIKit
import FBLikeLayout

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    

    
    override func viewDidLayoutSubviews() {
        if !self.collectionView.collectionViewLayout.isKindOfClass(FBLikeLayout) {
            let layout = FBLikeLayout()
            layout.minimumInteritemSpacing = 4
//            layout.singleCellWidth = (min(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)-self.collectionView.contentInset.left-self.collectionView.contentInset.right-8)/3.0;
            layout.maxCellSpace = 2;
//            layout.forceCellWidthForMinimumInteritemSpacing = true;
//            layout.fullImagePercentageOfOccurrency = 50;
            self.collectionView.collectionViewLayout = layout;
            
            self.collectionView.reloadData()
        }
    }

    
    
   override func viewDidLoad() {
        [super.viewDidLoad()]
    
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    
        self.collectionView.contentInset = UIEdgeInsets(top: 4,left: 4,bottom: 4,right: 4)
        self.collectionView.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "identifier")
        
        self.collectionView.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "identifier")

    }
    
    
    
    var photos: [UIImage] = [UIImage()]

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "identifier", forIndexPath: indexPath)
        
        view.backgroundColor = UIColor.whiteColor()
  
        return view
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        
        cell.backgroundColor = UIColor.whiteColor()
        
        cell.imageView.image = photos[indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let finalSize = photos[indexPath.item].size
        
        return finalSize
    }
    
    
}
