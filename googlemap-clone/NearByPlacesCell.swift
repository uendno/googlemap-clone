//
//  NearByPlacesCell.swift
//  googlemap-clone
//
//  Created by Tran Viet Thang on 6/25/16.
//  Copyright © 2016 Thang Tran. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher

class NearByPlacesCell: UITableViewCell {
	@IBOutlet var collectionView: UICollectionView!
	var nearbyPlaces: [NearbyPlaceResponse]?
}

extension NearByPlacesCell: UICollectionViewDataSource {
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (nearbyPlaces?.count)!
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlaceCell", forIndexPath: indexPath) as! PlaceCell
		
		// name
		cell.nameLabel.text = self.nearbyPlaces![indexPath.item].name
		
		// photo
		// get reviews and nearby places
		
		if let photoRef = self.nearbyPlaces![indexPath.item].photoRef {
			
            cell.photo.kf_setImageWithURL(NSURL(string: "http://128.199.151.182:3000/places/photo/\(photoRef)")!, placeholderImage: UIImage.init(named: "avatar"))
        } else {
            cell.photo.image = UIImage.init(named: "avatar")
        }
        
		return cell
		
	}
	
}

extension NearByPlacesCell: UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let itemPerRow: CGFloat = 3
		let hardCodedPadding: CGFloat = 5
		let itemWidth = (collectionView.bounds.width / itemPerRow) - hardCodedPadding
		let itemHeight: CGFloat = 149
		return CGSize(width: itemWidth, height: itemHeight)
		
	}
}
